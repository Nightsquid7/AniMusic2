package types

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"
)

//Season represents an anime season
type Season struct {
	start time.Time
	end   time.Time
	Name  string
	Year  string
}

// SeasonEntry represents an entry of a season in the Seasons-List collection
// todo: update seasons list to use Season struct
type SeasonEntry struct {
	Count  string
	Season string
	Year   string
	Time   time.Time
}

func NewSeasonEntryFromSeasonWithCount(season Season, count int, time time.Time) SeasonEntry {

	seasonEntry := SeasonEntry{
		Count:  strconv.Itoa(count),
		Season: season.Name,
		Year:   season.Year,
		Time:   time,
	}
	
	return seasonEntry
}

//GetAniDbSeasonNumber returns an integer that should go into the last.anime.month parameter on the aniDB anime season page
func (s *Season) GetAniDbSeasonNumber() int {
	return int(s.end.Month()) + 10
}

func (s *Season) String() string {
	return fmt.Sprintf("%s-%s", s.Name, s.Year)
}

func NewSeasonFromString(seasonString string) (*Season, error) {
	values := strings.Split(seasonString, " ")
	if len(values) != 2 {
		return nil, errors.New("Improper season string format")
	}

	var year int
	if v, err := strconv.Atoi(values[1]); v > time.Now().Year() || err != nil {
		return nil, errors.New("Improper season string format")
	} else {
		year = v
	}

	s := Season{}
	switch strings.ToUpper(values[0]) {
	case "WINTER":
		s.start = time.Date(year, 1, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(year, 3, 31, 0, 0, 0, 0, time.UTC)
		s.Name = "Winter"
		s.Year = strconv.Itoa(year)
	case "SPRING":
		s.start = time.Date(year, 4, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(year, 6, 30, 0, 0, 0, 0, time.UTC)
		s.Name = "Spring"
		s.Year = strconv.Itoa(year)
	case "SUMMER":
		s.start = time.Date(year, 7, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(year, 9, 30, 0, 0, 0, 0, time.UTC)
		s.Name = "Summer"
		s.Year = strconv.Itoa(year)
	case "AUTUMN":
		fallthrough
	case "FALL":
		s.start = time.Date(year, 10, 1, 0, 0, 0, 0, time.UTC)
		s.end = time.Date(year, 12, 31, 0, 0, 0, 0, time.UTC)
		s.Name = "Autumn"
		s.Year = strconv.Itoa(year)
	}

	return &s, nil
}

// NewSeason returns a new season struct representing the anime season that the specified start time belongs to
func NewSeasonFromTime(start time.Time) *Season {
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
