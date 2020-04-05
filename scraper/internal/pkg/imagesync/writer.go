package imagesync

import (
	"animusic/internal/pkg/types"
	"bytes"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"cloud.google.com/go/storage"
	firebase "firebase.google.com/go"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"golang.org/x/oauth2/jwt"
	"google.golang.org/api/iterator"
	"google.golang.org/api/option"
)

//Writer provides the functionality for syncing scraped anime cover images onto AniDB
type Writer struct {
	client     *firebase.App
	bucket     *storage.BucketHandle
	sitename   string
	conf       *jwt.Config
	httpClient *http.Client
}

type versionCreateResponse struct {
	Name   string `json:"name"`
	Status string `json:"status"`
}

type fileList struct {
	Files map[string]string `json:"files"`
}

type fileListResponse struct {
	UploadRequiredHashes []string `json:"uploadRequiredHashes"`
	UploadUrl            string   `json:"uploadUrl"`
}

type finalizeResponse struct {
	Name         string            `json:"name"`
	Status       string            `json:"status"`
	CreateTime   string            `json:"createTime"`
	CreateUser   map[string]string `json:"createUser"`
	FinalizeTime string            `json:"finalizeTime"`
	FinalizeUser map[string]string `json:"finalizeUser"`
	FileCount    string            `json:"fileCount"`
	VersionBytes string            `json:"versionBytes"`
}

type releaseResponse struct {
	Name        string         `json:"name"`
	Version     releaseVersion `json:"version"`
	ReleaseType string         `json:"type"`
	ReleaseTime string         `json:"releaseTime"`
}

type releaseVersion struct {
	Name   string `json:"name"`
	Status string `json:"status"`
}

func (w *Writer) Output(animeSeries []types.AnimeSeries, season types.Season) {
	defer postCleanUp()

	w.uploadNewFilesToFirebaseStorage(animeSeries)

	fmt.Println("Getting ready to deploy image assets onto Firebase Hosting...")
	w.syncLocalCache()
	versionId := w.createNewVersion()
	fileList := w.getRequiredUploadList(w.sitename, versionId)
	w.uploadRequiredFiles(fileList)
	w.finalizeNewVersion(w.sitename, versionId)
	w.releaseNewVersion(w.sitename, versionId)
}

func (w *Writer) createNewVersion() string {
	fmt.Println("Creating new version for Firebase Hosting...")
	res, err := w.httpClient.Post(fmt.Sprintf("https://firebasehosting.googleapis.com/v1beta1/sites/%s/versions", w.sitename),
		"application/json",
		bytes.NewBufferString(`{
		"config": {
		  "headers": [{
			"glob": "**",
			"headers": {
			  "Cache-Control": "max-age=1800"
			}
		  }]
		}
	  }`))

	if err != nil || res.StatusCode != 200 {
		fmt.Printf("An error occurred while creating a new version: %s", err.Error())
		os.Exit(1)
	}

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Printf("An error occurred while creating a new version: %s", err.Error())
		os.Exit(1)
	}
	defer res.Body.Close()

	var response versionCreateResponse
	if err := json.Unmarshal(body, &response); err != nil {
		fmt.Printf("An error occurred while creating a new version: %s", err.Error())
		os.Exit(1)
	}
	versionId := response.Name[strings.LastIndex(response.Name, "/")+1:]
	fmt.Println("Created version: " + versionId)

	return versionId
}

func (w *Writer) getRequiredUploadList(sitename string, versionId string) fileListResponse {
	fmt.Println("Getting required file upload list")
	fileListReq := fileList{Files: w.buildLocalHashList()}
	byteReq, err := json.Marshal(fileListReq)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	res, err := w.httpClient.Post(fmt.Sprintf("https://firebasehosting.googleapis.com/v1beta1/sites/%s/versions/%s:populateFiles", w.sitename, versionId),
		"application/json", bytes.NewBuffer(byteReq))
	if err != nil || res.StatusCode != 200 {
		fmt.Printf("An error occurred while getting the required file list: %s", err.Error())
		os.Exit(1)
	}

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Printf("An error occurred while getting the required file list: %s", err.Error())
		os.Exit(1)
	}
	res.Body.Close()

	var fileListResponse fileListResponse
	if err := json.Unmarshal(body, &fileListResponse); err != nil {
		fmt.Printf("An error occurred while getting the required file list: %s", err.Error())
		os.Exit(1)
	}
	return fileListResponse
}

func (w *Writer) releaseNewVersion(sitename string, versionId string) {
	fmt.Println("Releasing new version...")
	res, err := w.httpClient.Post(fmt.Sprintf("https://firebasehosting.googleapis.com/v1beta1/sites/%s/releases?versionName=sites/%s/versions/%s", sitename, sitename, versionId), "application/json", nil)
	if err != nil || res.StatusCode != 200 {
		fmt.Printf("An error occurred while releasing %s: %s", versionId, err.Error())
		os.Exit(1)
	}

	body, err := ioutil.ReadAll(res.Body)
	defer res.Body.Close()
	var releaseResponse releaseResponse
	if err := json.Unmarshal(body, &releaseResponse); err != nil {
		fmt.Printf("An error occurred while releasing %s: %s", versionId, err.Error())
		os.Exit(1)
	}
}

func (w *Writer) finalizeNewVersion(sitename string, versionId string) {
	fmt.Println("Finalizing new version...")
	req, _ := http.NewRequest("PATCH",
		fmt.Sprintf("https://firebasehosting.googleapis.com/v1beta1/sites/%s/versions/%s?update_mask=status", sitename, versionId),
		bytes.NewBufferString("{\"status\": \"FINALIZED\"}"))
	res, err := w.httpClient.Do(req)

	if err != nil || res.StatusCode != 200 {
		fmt.Printf("An error occurred while finalizing %s: %s", versionId, err.Error())
		os.Exit(1)
	}
	body, err := ioutil.ReadAll(res.Body)
	defer res.Body.Close()
	var finalizeResponse finalizeResponse
	if err := json.Unmarshal(body, &finalizeResponse); err != nil {
		fmt.Printf("An error occurred while finalizing %s: %s", versionId, err.Error())
		os.Exit(1)
	}
}

func (w *Writer) uploadRequiredFiles(fileListResponse fileListResponse) {
	for idx, requiredFile := range fileListResponse.UploadRequiredHashes {
		fmt.Printf("Uploading File %d/%d\n", idx+1, len(fileListResponse.UploadRequiredHashes))
		f, err := os.Open(".cache/buffer/" + requiredFile + ".gz")
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		res, err := w.httpClient.Post(fileListResponse.UploadUrl+"/"+requiredFile, "gzip", f)
		res.Body.Close()
	}
}

func (w *Writer) buildLocalHashList() map[string]string {
	result := make(map[string]string)
	//GZIP all the files
	os.MkdirAll(".cache/buffer/", 0700)
	items, _ := ioutil.ReadDir(".cache/images")
	for _, item := range items {
		f, err := ioutil.ReadFile(".cache/images/" + item.Name())
		if err != nil {
			continue
		}

		var buf bytes.Buffer
		zw := gzip.NewWriter(&buf)
		_, err = zw.Write(f)

		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		if err := zw.Close(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		hash := sha256.Sum256(buf.Bytes())
		hexString := hex.EncodeToString(hash[:])
		result["/"+item.Name()] = hexString
		ioutil.WriteFile(".cache/buffer/"+hexString+".gz", buf.Bytes(), 0700)

	}

	return result
}

//Makes sure the current state of the local cache matches the state in Firebase Storage
//Otherwise we will lose files when we deploy to Firebase Hosting
func (w *Writer) syncLocalCache() {
	fmt.Println("Syncing local cache with current Firebase Storage...")
	os.MkdirAll(".cache/images/", 0777)
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, time.Second*10)
	defer cancel()
	it := w.bucket.Objects(ctx, &storage.Query{
		Prefix:    "titleImage/",
		Delimiter: "/",
	})

	counter := 0
	for {
		attrs, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		//Download the file if not exists
		p := filepath.Base(attrs.Name)
		if _, err := os.Stat(".cache/images/" + p); err != nil {
			if os.IsNotExist(err) {
				counter++
				ctx := context.Background()
				ctx, cancel := context.WithTimeout(ctx, time.Second*50)
				defer cancel()
				rc, err := w.bucket.Object(attrs.Name).NewReader(ctx)
				if err != nil {
					fmt.Println(err)
					os.Exit(1)
				}
				defer rc.Close()

				data, err := ioutil.ReadAll(rc)
				if err != nil {
					fmt.Println(err)
					os.Exit(1)
				}
				ioutil.WriteFile(".cache/images/"+p, data, 0700)
			}
		}
	}
	fmt.Printf("Synced %d files\n", counter)
}

func (w *Writer) uploadNewFilesToFirebaseStorage(animeSeries []types.AnimeSeries) {
	fmt.Println("Writing to Firebase Storage...")
	for _, anime := range animeSeries {
		f, err := os.Open(".cache/images/" + anime.TitleImageName)
		if err != nil {
			fmt.Println(err)
			return
		}
		defer f.Close()

		ctx := context.Background()
		ctx, cancel := context.WithTimeout(ctx, time.Second*50)
		defer cancel()
		wc := w.bucket.Object(fmt.Sprintf("titleImage/%s", anime.TitleImageName)).NewWriter(ctx)
		if _, err = io.Copy(wc, f); err != nil {
			fmt.Println(err)
		}
		if err := wc.Close(); err != nil {
			fmt.Println(err)
		}
	}
}

func postCleanUp() {
	err := os.RemoveAll(".cache/buffer")
	if err != nil {
		fmt.Println(err)
	}
}

//CreateImageSyncWriter creates an output writer that will automatically run through a process to make the images available
//on Firebase hosting
func CreateImageSyncWriter(firebaseCredPath string, storageBucket string, sitename string) *Writer {
	config := &firebase.Config{
		StorageBucket: storageBucket,
	}
	//Initialize Firebase admin sdk
	opt := option.WithCredentialsFile(firebaseCredPath)
	app, err := firebase.NewApp(context.Background(), config, opt)
	if err != nil {
		//Error is unrecoverable, so exit
		e := fmt.Errorf("Error initializing image sync writer: %v", err)
		fmt.Println(e)
		os.Exit(1)
	}

	storage, err := app.Storage(context.Background())
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	bucket, err := storage.DefaultBucket()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	data, err := ioutil.ReadFile(firebaseCredPath)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	conf, err := google.JWTConfigFromJSON(data, "https://www.googleapis.com/auth/firebase")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	f := Writer{
		client:     app,
		bucket:     bucket,
		conf:       conf,
		sitename:   sitename,
		httpClient: conf.Client(oauth2.NoContext),
	}
	return &f
}
