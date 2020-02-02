package spotify

import (
	"animusic/internal/pkg/types"
	"fmt"

	"github.com/zmb3/spotify"
)

const (
	letterBytes   = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" // 52 possibilities
	letterIdxBits = 6                                                      // 6 bits to represent 64 possibilities / indexes
	letterIdxMask = 1<<letterIdxBits - 1                                   // All 1-bits, as many as letterIdxBits
)

//State we are going to use for setting up the client. This must not be reused.
var state string

func init() {
	state = secureRandomAlphaString(10)
}

var auth = spotify.NewAuthenticator("http://localhost:3939", spotify.ScopeUserReadPrivate)

type SpotifyMusicSource struct {
	client *spotify.Client
}

func (s *SpotifyMusicSource) SearchSong(song types.ScrapedSongData) (types.SongSearchResult, error) {
	fmt.Println("Searching Spotify for: ", song.Name)
	queryString := BuildSpotifyQueryString(song)
	results, err := s.client.Search(queryString, spotify.SearchTypeTrack)

	if err != nil {
		return types.SongSearchResult{}, err
	}

	if len(results.Tracks.Tracks) == 0 {
		return types.SongSearchResult{}, fmt.Errorf("Could not find name: %s artist: %s year: %s", song.Name, song.Artists[0], song.Year)
	}

	//TODO: Suggest human intervention for searches that return more than one track
	fmt.Println(results.Tracks.Tracks)
	track := results.Tracks.Tracks[0]
	return types.SongSearchResult{
		URI:         string(track.URI),
		Name:        track.Name,
		Source:      "Spotify",
		ExternalUrl: track.ExternalURLs["spotify"],
	}, nil
}
