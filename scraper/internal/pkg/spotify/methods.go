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

func BuildSpotifyQueryString(song types.ScrapedSongData) string {
	yearInt, _ := strconv.Atoi(song.Year)
	yearString := fmt.Sprintf("%d-%d", yearInt, yearInt+1)
	return fmt.Sprintf("%s artist:%s year:%s", song.Name, song.Artists[0], yearString)
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
		fmt.Println("Received callback on localhost:8080")
		token, err := auth.Token(state, r)
		if err != nil {
			fmt.Println(err)
			http.Error(w, "Couldn't get token", http.StatusNotFound)
			return
		}
		// create a client using the specified token
		done <- token

	})
	http.ListenAndServe(":3939", nil)
	// if err != nil {
	// 	fmt.Println("Error trying to start http server for OAuth2 callback. Please stop any other process listening on port 3939")
	// 	//We are not in a recoverable state, so exit
	// 	os.Exit(1)
	// }
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
