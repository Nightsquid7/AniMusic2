package main

import (
	"animusic/internal/pkg/anidb"
	"animusic/internal/pkg/cache"
	"animusic/internal/pkg/firestore"
	"animusic/internal/pkg/json"
	"animusic/internal/pkg/spotify"
	"animusic/internal/pkg/types"
	"flag"
	"fmt"
	"os"
	"strings"
	"sync"
	"time"
)

const logo = `
_____         .__               .__           _________                                        
/  _  \   ____ |__| _____   _____|__| ____    /   _____/ ________________  ______   ___________ 
/  /_\  \ /    \|  |/     \ /  ___/  |/ ___\   \_____  \_/ ___\_  __ \__  \ \____ \_/ __ \_  __ \
/    |    \   |  \  |  Y Y  \\___ \|  \  \___   /        \  \___|  | \// __ \|  |_> >  ___/|  | \/
\____|__  /___|  /__|__|_|  /____  >__|\___  > /_______  /\___  >__|  (____  /   __/ \___  >__|   
	 \/     \/         \/     \/        \/          \/     \/           \/|__|        \/       
`

var animeSources []types.AnimeScraper
var musicSources []types.MusicSource
var outputWriters []types.OutputWriter
var spotifyClientID string
var spotifyClientSecret string
var seasonString string
var season *types.Season
var useCache bool
var firebaseCredPath string
var jsonWritePath string

func init() {
	flag.StringVar(&spotifyClientID, "sid", "", "Client Id for Spotify OAuth2 client")
	flag.StringVar(&spotifyClientSecret, "ss", "", "Client Secret for Spotify OAuth2 client")
	flag.StringVar(&seasonString, "s", "", "Season string e.g. Winter 2020. Infers season from current date if not specified")
	flag.BoolVar(&useCache, "cache", true, "Attempt to load anime data from local cache")
	flag.StringVar(&firebaseCredPath, "firebaseCredPath", "", "Location of the services.json for Firebase")
	flag.StringVar(&jsonWritePath, "writePath", "", "Output path for the json file")
}

func main() {
	fmt.Println(logo)
	fmt.Println("Welcome to the Animusic Scraper")
	flag.Parse()

	initializeMusicSources()
	initializeOutputWriters()

	//Figure out what season we need to be scraping
	if len(seasonString) != 0 {
		buf, err := types.NewSeasonFromString(seasonString)
		if err != nil {
			fmt.Println(err.Error())
			os.Exit(1)
		}
		season = buf
	} else {
		season = types.NewSeasonFromTime(time.Now())
	}
	fmt.Println("Season set to: ", season.String())

	cache.InitCache(season, useCache)

	// //Initialize all anime data sources
	a := anidb.NewAniDbScraper(*season)
	animeSources = append(animeSources, a)

	result := scrape()

	//Build output
	reportResults()

	for _, outputWriter := range outputWriters {
		outputWriter.Output(result, *season)
	}
	fmt.Println("Done!")
}

func scrape() []types.AnimeSeries {
	var wg sync.WaitGroup

	//TODO: Figure out how to synchronize multiple anime data sources here before feeding it into music sourcesearch
	for i := 0; i < len(animeSources); i++ {
		go animeSources[i].Start()
	}

	finalResult := make([]types.AnimeSeries, 0)
	for {
		select {
		case anime := <-animeSources[0].GetOutputChannel():
			wg.Add(1)
			var animeResult types.AnimeSeries
			if len(anime.Songs) > 0 {
				songSearchResults := searchSongs(anime.Songs)
				animeResult = types.NewAnimeSeriesFromScrapedData(&anime, songSearchResults)
			} else {
				animeResult = types.NewAnimeSeriesFromScrapedData(&anime, nil)
			}
			finalResult = append(finalResult, animeResult)
			wg.Done()
		case <-animeSources[0].GetDoneChannel():
			wg.Wait()
			return finalResult
		}
	}
}

func searchSongs(songs []types.ScrapedSongData) map[string]map[string]types.SongSearchResult {
	agg := make(chan types.SongSearchResult)
	err := make(chan error)
	for i := 0; i < len(musicSources); i++ {
		for j := 0; j < len(songs); j++ {
			musicSource := &musicSources[i]
			go func(agg chan<- types.SongSearchResult, err chan<- error, source types.MusicSource, idx int) {
				songSearchResult, searchErr := source.SearchSong(songs[idx])
				if searchErr != nil {
					err <- searchErr
				} else {
					agg <- songSearchResult
				}
			}(agg, err, *musicSource, j)
		}
	}

	output := make(map[string]map[string]types.SongSearchResult)
	//Expecting number of results equal to number of music sources * the number of songs
	//We have to reassemble the results as they come out of the channel
	for i := 0; i < len(musicSources)*len(songs); i++ {
		select {
		case searchResult := <-agg:
			fmt.Printf("Found %s: %s on %s \n", searchResult.Relation, searchResult.Name, searchResult.Source)

			if _, ok := output[searchResult.SongId+"-"+searchResult.Relation]; !ok {
				output[searchResult.SongId+"-"+searchResult.Relation] = make(map[string]types.SongSearchResult)
			}

			output[searchResult.SongId+"-"+searchResult.Relation][searchResult.Source] = searchResult
		case searchErr := <-err:
			fmt.Println("Error occurred: ", searchErr)
		}
	}

	return output
}

func reportResults() {
	for _, musicSource := range musicSources {
		fmt.Println(musicSource.ReportStats())
	}
}

func initializeMusicSources() {
	var sb strings.Builder
	sb.WriteString("Music sources initialized:")
	//Decide what music sources to use based on the tokens/credentials provided
	if len(spotifyClientID) != 0 || len(spotifyClientSecret) != 0 {
		spotifyClient := spotify.NewClient(spotifyClientID, spotifyClientSecret)
		musicSources = append(musicSources, spotifyClient)
		sb.WriteString(" Spotify")
	}

	//TODO: Initialize Apple Music here
	fmt.Println(sb.String())
}

func initializeOutputWriters() {
	var sb strings.Builder
	sb.WriteString("Output writers initialized:")
	//Decide what output writers to use based on the provided args
	if len(firebaseCredPath) != 0 {
		outputWriters = append(outputWriters, firestore.CreateFirestoreOutputWriter(firebaseCredPath))
		sb.WriteString(" Firestore")
	}

	if len(jsonWritePath) != 0 {
		outputWriters = append(outputWriters, json.CreateNewJsonWriter(jsonWritePath))
		sb.WriteString(" Json")
	}
	fmt.Println(sb.String())
}
