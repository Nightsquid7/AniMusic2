package types

import (
	"strconv"
	"time"
)

//Season represents an anime season
type Season struct {
	start time.Time
	end   time.Time
	Name  string
	Year  string
}

//GetAniDbSeasonNumber returns an integer that should go into the last.anime.month parameter on the aniDB anime season page
func (s *Season) GetAniDbSeasonNumber() int {
	return int(s.end.Month()) + 10
}

// NewSeason returns a new season struct representing the anime season that the specified start time belongs to
func NewSeason(start time.Time) *Season {
	s := Season{}
	switch start.Month() {
	case 1:
		fallthrough
	case 2:
		fallthrough
	case 3:
		s.start = time.Date(start.Year(), 1, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(start.Year(), 3, 31, 0, 0, 0, 0, time.UTC)
		s.Name = "Winter"
		s.Year = strconv.Itoa(start.Year())
	case 4:
		fallthrough
	case 5:
		fallthrough
	case 6:
		s.start = time.Date(start.Year(), 4, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(start.Year(), 6, 30, 0, 0, 0, 0, time.UTC)
		s.Name = "Spring"
		s.Year = strconv.Itoa(start.Year())
	case 7:
		fallthrough
	case 8:
		fallthrough
	case 9:
		s.start = time.Date(start.Year(), 7, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(start.Year(), 9, 30, 0, 0, 0, 0, time.UTC)
		s.Name = "Summer"
		s.Year = strconv.Itoa(start.Year())
		break
	case 10:
		fallthrough
	case 11:
		fallthrough
	case 12:
		s.start = time.Date(start.Year(), 10, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(start.Year(), 12, 31, 0, 0, 0, 0, time.UTC)
		s.Name = "Autumn"
		s.Year = strconv.Itoa(start.Year())
	}
	return &s
}
