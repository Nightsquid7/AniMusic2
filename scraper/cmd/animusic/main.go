package main

import (
	"animusic/internal/pkg/anidb"
	"animusic/internal/pkg/cache"
	"animusic/internal/pkg/spotify"
	"animusic/internal/pkg/types"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
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
var spotifyClientID string
var spotifyClientSecret string
var seasonString string
var season *types.Season
var useCache bool

func init() {
	flag.StringVar(&spotifyClientID, "sid", "", "Client Id for Spotify OAuth2 client")
	flag.StringVar(&spotifyClientSecret, "ss", "", "Client Secret for Spotify OAuth2 client")
	flag.StringVar(&seasonString, "s", "", "Season string e.g. Winter 2020. Infers season from current date if not specified")
	flag.BoolVar(&useCache, "cache", true, "Attempt to load anime data from local cache")
}

func main() {
	fmt.Println(logo)
	fmt.Println("Welcome to the Animusic Scraper")
	flag.Parse()

	//Decide what music sources to use based on the tokens/credentials provided
	if len(spotifyClientID) == 0 || len(spotifyClientSecret) == 0 {
		fmt.Println("Spotify credentials were not provided. Will not use Spotify for music search")
	} else {
		spotifyClient := spotify.NewClient(spotifyClientID, spotifyClientSecret)
		musicSources = append(musicSources, spotifyClient)
	}

	//TODO: Initialize Apple Music here

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
	fmt.Println("Done!")
	reportResults()
	json, _ := json.MarshalIndent(result, "", "\t")
	ioutil.WriteFile("output.json", json, 0644)
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
			fmt.Println("Found: ", searchResult)

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
