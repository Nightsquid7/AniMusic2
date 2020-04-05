package types

type ScrapedAnimeSeries struct {
	Id             string            `json:"id"`
	Name           string            `json:"name"`
	TitleImageName string            `json:"titleImageName"`
	Ref            string            `json:"ref"`
	Format         string            `json:"format"`
	Season         string            `json:"season"`
	Year           string            `json:"year"`
	Songs          []ScrapedSongData `json:"songs"`
}

type ScrapedSongData struct {
	Id             string          `json:"id"`
	AnimeId        string          `json:"animeId"`
	Name           string          `json:"name"`
	NameEn         string          `json:"nameEn"`
	Ranges         []EpisodeRange  `json:"ranges"`
	Classification string          `json:"classification"`
	Artists        []ScrapedArtist `json:"artists"`
	Relation       string          `json:"relation"`
	Year           string          `json:"year"`
	Ref            string          `json:"ref"`
}

type ScrapedArtist struct {
	Id       string `json:"id"`
	SongId   string `json:"songId"`
	Relation string `json:"relation"`
	Name     string `json:"name"`
	NameEn   string `json:"nameEn"`
	Ref      string `json:"ref"`
}

type EpisodeRange struct {
	Start int `json:"start"`
	End   int `json:"end"`
}

//TODO: Flesh out this type to have what we actually need for the client app
type SongSearchResult struct {
	//Opening, ending, insert, etc.
	Relation string
	//AniDB Id of this song
	SongId      string
	URI         string
	Name        string
	ExternalUrl string
	Source      string
}

//Final result!
//TODO: Flesh out what to include in the final result as well
type AnimeSeries struct {
	Id             string
	Name           string
	TitleImageName string
	AniDbUri       string
	Format         string
	Season         string
	Year           string
	Songs          map[string]AnimeSong
}

//Final Song result
//TODO: Flesh out what to include in the final result as well
type AnimeSong struct {
	Id             string
	Name           string
	NameEn         string
	Ranges         []EpisodeRange
	Classification string
	Artists        []AnimeArtist
	Relation       string
	Sources        map[string]SongSearchResult
}

type AnimeArtist struct {
	Id     string
	Name   string
	NameEn string
}

func NewAnimeSeriesFromScrapedData(series *ScrapedAnimeSeries, songSearchResults map[string]map[string]SongSearchResult) AnimeSeries {
	animeSeries := AnimeSeries{
		Id:             series.Id,
		Name:           series.Name,
		TitleImageName: series.TitleImageName,
		AniDbUri:       series.Ref,
		Format:         series.Format,
		Season:         series.Season,
		Year:           series.Year,
		Songs:          make(map[string]AnimeSong),
	}

	for _, song := range series.Songs {
		animeSong := AnimeSong{
			Id:             song.Id,
			Name:           song.Name,
			NameEn:         song.NameEn,
			Ranges:         song.Ranges,
			Classification: song.Classification,
			Relation:       song.Relation,
			Sources:        make(map[string]SongSearchResult),
		}

		for _, artist := range song.Artists {
			animeArtist := AnimeArtist{
				Id:     artist.Id,
				Name:   artist.Name,
				NameEn: artist.NameEn,
			}
			animeSong.Artists = append(animeSong.Artists, animeArtist)
		}

		if songSearchResults != nil {
			if val, ok := songSearchResults[animeSong.Id+"-"+animeSong.Relation]; ok {
				animeSong.Sources = val
			}
		}
		animeSeries.Songs[animeSong.Id+"-"+animeSong.Relation] = animeSong
	}

	return animeSeries
}
