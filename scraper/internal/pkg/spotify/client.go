package spotify

import (
	"animusic/internal/pkg/types"
	"fmt"

	"github.com/agnivade/levenshtein"
	"github.com/zmb3/spotify"
)

const (
	letterBytes           = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" // 52 possibilities
	letterIdxBits         = 6                                                      // 6 bits to represent 64 possibilities / indexes
	letterIdxMask         = 1<<letterIdxBits - 1                                   // All 1-bits, as many as letterIdxBits
	maximumStringDistance = 5                                                      //Maximum string distance to be considered a song match
)

//State we are going to use for setting up the client. This must not be reused.
var state string

func init() {
	state = secureRandomAlphaString(10)
}

var auth = spotify.NewAuthenticator("http://localhost:3939", spotify.ScopeUserReadPrivate)

type SpotifyMusicSource struct {
	//Number of song search attempts.
	//The actual number of requests to Spotify is much greater, because different combinations of names and artists are attempted to improve hit rate
	AttemptedSearches int
	//Number of song searches that resulted in at least 1 search result
	SuccessfulHits int
	client         *spotify.Client
}

//SearchSong takes scraped song data and returns its corresponding Spotify Search Result.
func (s *SpotifyMusicSource) SearchSong(song types.ScrapedSongData) (types.SongSearchResult, error) {
	fmt.Println("Searching Spotify for: ", song.Name)
	s.AttemptedSearches++
	queryStrings := BuildSpotifyQueryStrings(song)

	for i := 0; i < len(queryStrings); i++ {
		results, err := s.client.Search(queryStrings[i], spotify.SearchTypeTrack)

		if err != nil {
			return types.SongSearchResult{}, err
		}

		if len(results.Tracks.Tracks) == 0 {
			//Try the next query string
			continue
		}

		//TODO: Suggest human intervention for searches that return more than one track
		track := results.Tracks.Tracks[0]

		//The last two query strings are going to be attempts without artists, so we need to check the string distance
		if i < len(queryStrings)-2 {
			s.SuccessfulHits++
			return types.SongSearchResult{
				SongId:      song.Id,
				URI:         string(track.URI),
				Name:        track.Name,
				Source:      "Spotify",
				Relation:    song.Relation,
				ExternalUrl: track.ExternalURLs["spotify"],
			}, nil
		} else if distance := levenshtein.ComputeDistance(song.Name, track.Name); distance < maximumStringDistance {
			s.SuccessfulHits++
			return types.SongSearchResult{
				SongId:      song.Id,
				URI:         string(track.URI),
				Name:        track.Name,
				Source:      "Spotify",
				Relation:    song.Relation,
				ExternalUrl: track.ExternalURLs["spotify"],
			}, nil
		}
	}

	if len(song.Artists) > 0 {
		return types.SongSearchResult{}, fmt.Errorf("Could not find name: %s artist: %s year: %s", song.Name, song.Artists[0].Name, song.Year)
	} else {
		return types.SongSearchResult{}, fmt.Errorf("Could not find name: %s year: %s", song.Name, song.Year)
	}
}

//ReportStats prints the final hit rate referring to the number of songs searched and the number of songs that ended up with a Spotify result
func (s *SpotifyMusicSource) ReportStats() string {
	return fmt.Sprintf("Spotify: %d/%d songs matched. Hit rate %f%%", s.SuccessfulHits, s.AttemptedSearches, (float32(s.SuccessfulHits)/float32(s.AttemptedSearches))*100)
}
