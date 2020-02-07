package types

type AnimeScraper interface {
	Start()
	GetOutputChannel() <-chan ScrapedAnimeSeries
	GetDoneChannel() <-chan bool
}
