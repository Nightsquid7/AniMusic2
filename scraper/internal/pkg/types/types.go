package types

import "strings"

type ScrapedAnimeSeries struct {
	Id     string            `json:id`
	Name   string            `json:name`
	Ref    string            `json:ref`
	Format string            `json:format`
	Season string            `json:season`
	Year   string            `json:year`
	Songs  []ScrapedSongData `json:songs`
}

type ScrapedSongData struct {
	Id             string         `json:id`
	AnimeId        string         `json:animeId`
	Name           string         `json:name`
	Ranges         []EpisodeRange `json:ranges`
	Classification string         `json:classification`
	Artists        []string       `json:artists`
	Relation       string         `json:relation`
	Year           string         `json:year`
}

type EpisodeRange struct {
	Start int `json:start`
	End   int `json:end`
}

//TODO: Flesh out this type to have what we actually need for the client app
type SongSearchResult struct {
	URI         string
	Name        string
	ExternalUrl string
	Source      string
}

//Final result!
//TODO: Flesh out what to include in the final result as well
type AnimeSeries struct {
	Id       string
	Name     string
	AniDbUri string
	Format   string
	Season   string
	Year     string
	Songs    map[string]AnimeSong
}

//Final Song result
//TODO: Flesh out what to include in the final result as well
type AnimeSong struct {
	Id             string
	Name           string
	Ranges         []EpisodeRange
	Classification string
	Artists        []string
	Relation       string
	Sources        map[string]SongSearchResult
}

func NewAnimeSeriesFromScrapedData(series *ScrapedAnimeSeries, songSearchResults map[string]map[string]SongSearchResult) AnimeSeries {
	animeSeries := AnimeSeries{
		Id:       series.Id,
		Name:     series.Name,
		AniDbUri: series.Ref,
		Format:   series.Format,
		Season:   series.Season,
		Year:     series.Year,
		Songs:    make(map[string]AnimeSong),
	}

	for _, song := range series.Songs {
		animeSong := AnimeSong{
			Id:             song.Id,
			Name:           song.Name,
			Ranges:         song.Ranges,
			Classification: song.Classification,
			Artists:        song.Artists,
			Relation:       song.Relation,
			Sources:        make(map[string]SongSearchResult),
		}
		if songSearchResults != nil {
			if val, ok := songSearchResults[strings.ToUpper(animeSong.Name)]; ok {
				animeSong.Sources = val
			}
		}
		animeSeries.Songs[animeSong.Name] = animeSong
	}

	return animeSeries
}
