package animusic_applemusic

import (
	"animusic/internal/pkg/types"
	"context"
	"fmt"
	
	"github.com/minchao/go-apple-music"
)

var appleMusicToken string = ""

type AppleMusicMusicSource struct {
	AttemptedSearches int
	SuccessfulHits int
	client *applemusic.Client
 }

func NewClient(token string) *AppleMusicMusicSource {
	tp := applemusic.Transport{Token: token}
	client := AppleMusicMusicSource{
		client: applemusic.NewClient(tp.Client()),
	}
	return &client
}

func BuildAppleMusicSearchOptions(song types.ScrapedSongData) []applemusic.SearchOptions {
	result := make([]string, 0)
	for i := 0; i < len(song.Artists); i++ {
		result = append(result, fmt.Sprintf("%s artist:%s  ", song.Name, song.Artists[i].Name ))
		result = append(result, fmt.Sprintf("%s artist:%s  ", song.Name, song.Artists[i].NameEn ))
		result = append(result, fmt.Sprintf("%s artist:%s  ", song.NameEn, song.Artists[i].Name ))
		result = append(result, fmt.Sprintf("%s artist:%s  ", song.NameEn, song.Artists[i].NameEn ))
	}

	//If we fail to retrieve anything using the artist strings, last ditch attempt to search using only the name and year
	result = append(result, fmt.Sprintf("%s  ", song.Name ))
	result = append(result, fmt.Sprintf("%s  ", song.NameEn ))

	allOptions := make([]applemusic.SearchOptions, 0)
	for i := 0; i < len(result); i++ {
		searchOptions := applemusic.SearchOptions {
			Term: result[i],
			Language: "ja",
		}
		allOptions = append(allOptions, searchOptions)
	}
	return allOptions
}

func (s *AppleMusicMusicSource) SearchSong(song types.ScrapedSongData) (types.SongSearchResult, error) {
	fmt.Println("Searching AppleMusic for: ", song.Name)
	s.AttemptedSearches++

	searchOptions := BuildAppleMusicSearchOptions(song)

	for i := 0; i < len(searchOptions); i++ {
		// MARK TODO - create search method for AppleMusicSearch
		results, _, err := s.client.Catalog.Search(context.TODO(), "jp", &searchOptions[i])
		fmt.Println("searching using ", &searchOptions[i])
		if err != nil {
			return types.SongSearchResult{}, err
		}
	
		if results.Results.Songs == nil {
			//Try the next query string
			continue
		}

		// convert Results.Songs to SongSearchResult
		//TODO: Suggest human intervention for searches that return more than one track
		track := results.Results.Songs.Data[0]
		attributes := track.Attributes
		fmt.Println("\nsong name we are searching for ", song.Name)
		fmt.Println("attributes.Name ", attributes.Name)
		fmt.Println("attributes.artist ", attributes.ArtistName)
		s.SuccessfulHits++
		return types.SongSearchResult{
			SongId:      song.Id,
			URI:         track.Href,
			Name:        attributes.Name,
			Source:      "AppleMusic",
			Relation:    song.Relation,
			ExternalUrl: attributes.URL,
		}, nil
	}

	if len(song.Artists) > 0 {
		return types.SongSearchResult{}, fmt.Errorf("Could not find name: %s artist: %s year: %s", song.Name, song.Artists[0].Name, song.Year)
	} else {
		return types.SongSearchResult{}, fmt.Errorf("Could not find name: %s year: %s", song.Name, song.Year)
	}
}

//ReportStats prints the final hit rate referring to the number of songs searched and the number of songs that ended up with a Spotify result
func (s *AppleMusicMusicSource) ReportStats() string {
	return fmt.Sprintf("AppleMusic: %d/%d songs matched. Hit rate %f%%", s.SuccessfulHits, s.AttemptedSearches, (float32(s.SuccessfulHits)/float32(s.AttemptedSearches))*100)
}