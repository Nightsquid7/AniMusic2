package spotify

import (
	"animusic/internal/pkg/types"
	"crypto/rand"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"time"

	"golang.org/x/oauth2"

	"github.com/zmb3/spotify"
)

func NewClient(clientID string, clientSecret string) *SpotifyMusicSource {
	client := SpotifyMusicSource{
		client: createSpotifyClient(clientID, clientSecret),
	}
	return &client
}

//Returns an array of Spotify query strings to try to search.
//Includes a permutation for every artists and their romaji and kanji names because Spotify artist filter does not allow the OR operator
func BuildSpotifyQueryStrings(song types.ScrapedSongData) []string {
	yearInt, _ := strconv.Atoi(song.Year)
	yearString := fmt.Sprintf("%d-%d", yearInt, yearInt+1)
	result := make([]string, 0)

	for i := 0; i < len(song.Artists); i++ {
		result = append(result, fmt.Sprintf("%s artist:%s year:%s", song.Name, song.Artists[i].Name, yearString))
		result = append(result, fmt.Sprintf("%s artist:%s year:%s", song.Name, song.Artists[i].NameEn, yearString))
		result = append(result, fmt.Sprintf("%s artist:%s year:%s", song.NameEn, song.Artists[i].Name, yearString))
		result = append(result, fmt.Sprintf("%s artist:%s year:%s", song.NameEn, song.Artists[i].NameEn, yearString))
	}

	//If we fail to retrieve anything using the artist strings, last ditch attempt to search using only the name and year
	result = append(result, fmt.Sprintf("%s year:%s", song.Name, yearString))
	result = append(result, fmt.Sprintf("%s year:%s", song.NameEn, yearString))
	return result
}

func createSpotifyClient(clientID string, clientSecret string) *spotify.Client {
	fmt.Println("Initializing Spotify Client...")
	done := startCallbackOAuthServer()
	auth.SetAuthInfo(clientID, clientSecret)
	url := auth.AuthURL(state)
	openBrowser(url)
	//Block here until OAuth is complete because we can't do anything
	//Without the token
	select {
	case token := <-done:
		client := auth.NewClient(token)
		client.AutoRetry = true
		fmt.Println("Successfully initialized Spotify Client")
		return &client
	case <-time.After(15 * time.Second):
		fmt.Println("Timed out trying to get Spotify OAuth token. Try checking your Spotify Developer account settings")
		os.Exit(1)
	}

	return nil
}

func startCallbackOAuthServer() <-chan *oauth2.Token {
	c := make(chan *oauth2.Token)
	go startHttpServer(c, state)
	return c
}

func startHttpServer(done chan<- *oauth2.Token, state string) {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("Received callback on localhost:3939")
		token, err := auth.Token(state, r)
		if err != nil {
			fmt.Println(err)
			http.Error(w, "Couldn't get token", http.StatusInternalServerError)
			return
		}
		// create a client using the specified token
		done <- token
		close(done)
	})
	http.ListenAndServe(":3939", nil)
}

func openBrowser(url string) {
	var err error

	switch runtime.GOOS {
	case "linux":
		err = exec.Command("xdg-open", url).Start()
	case "windows":
		err = exec.Command("rundll32", "url.dll,FileProtocolHandler", url).Start()
	case "darwin":
		err = exec.Command("open", url).Start()
	default:
		err = fmt.Errorf("unsupported platform")
	}
	if err != nil {
		log.Fatal(err)
	}
}

func secureRandomAlphaString(length int) string {
	result := make([]byte, length)
	bufferSize := int(float64(length) * 1.3)
	for i, j, randomBytes := 0, 0, []byte{}; i < length; j++ {
		if j%bufferSize == 0 {
			randomBytes = secureRandomBytes(bufferSize)
		}
		if idx := int(randomBytes[j%length] & letterIdxMask); idx < len(letterBytes) {
			result[i] = letterBytes[idx]
			i++
		}
	}

	return string(result)
}

// SecureRandomBytes returns the requested number of bytes using crypto/rand
func secureRandomBytes(length int) []byte {
	var randomBytes = make([]byte, length)
	_, err := rand.Read(randomBytes)
	if err != nil {
		log.Fatal("Unable to generate random bytes")
	}
	return randomBytes
}
