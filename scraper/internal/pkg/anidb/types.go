package anidb

type AnimeSeries struct {
	Id     string
	Name   string
	Ref    string
	Format string
	Season string
	Year   string
	Songs  []Song
}

type Song struct {
	Id             string
	AnimeId        string
	Name           string
	Range          []EpisodeRange
	Classification string
	Artists        []string
	Relation       string
}

type EpisodeRange struct {
	Start int
	End   int
}
