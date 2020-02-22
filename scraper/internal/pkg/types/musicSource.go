package types

type MusicSource interface {
	SearchSong(song ScrapedSongData) (SongSearchResult, error)
	ReportStats() string
}
