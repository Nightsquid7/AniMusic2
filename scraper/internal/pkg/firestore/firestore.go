package firestore

import (
	"animusic/internal/pkg/types"
	"fmt"
	"os"

	"golang.org/x/net/context"

	fs "cloud.google.com/go/firestore"
	firebase "firebase.google.com/go"

	"google.golang.org/api/option"
)

type Writer struct {
	client *firebase.App
}

//Output starts the write action to Firestore
func (f *Writer) Output(animeSeries []types.AnimeSeries, season types.Season) {
	fmt.Println("Writing to Firestore...")
	firestore, _ := f.client.Firestore(context.Background())
	batches := make([]*fs.WriteBatch, 0)
	var currentBatch *fs.WriteBatch

	for idx, anime := range animeSeries {
		//Only a maximum of 500 writes are allowed per batch, so we have to create a new batch
		if idx%500 == 0 {
			batch := firestore.Batch()
			batches = append(batches, batch)
			currentBatch = batch
		}

		if len(anime.Songs) == 0 {
			continue
		}
		
		ref := firestore.Collection(season.String()).Doc(anime.Id)
		currentBatch.Set(ref, anime)
	}

	

	for _, batch := range batches {
		result, err := batch.Commit(context.Background())
		if err != nil {
			fmt.Println("err", err)
			os.Exit(1)
		}

		seasonEntry := types.NewSeasonEntryFromSeasonWithCount(season, len(animeSeries))
		_, err = firestore.Collection("Seasons-List").Doc(season.String()).Set(context.Background(), seasonEntry)
		
		if err != nil {
			fmt.Println("error writing entry to Seasons-List: ", err)
		}
		fmt.Println("wrote to Seasons-List", seasonEntry)
		
		fmt.Println("result: ", result)
	}
}

//CreateFirestoreOutputWriter creates a new instance of Firestore output writer for writing song information to Firestpre
func CreateFirestoreOutputWriter(firebaseCredPath string) *Writer {
	//Initialize Firebase admin sdk
	opt := option.WithCredentialsFile(firebaseCredPath)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		//Error is unrecoverable, so exit
		e := fmt.Errorf("Error initializing Firestore output writer: %v", err)
		fmt.Println(e)
		os.Exit(1)
	}
	// fmt.Println("Successfully initialized Firebase admin sdk")
	f := Writer{
		client: app,
	}
	return &f
}
