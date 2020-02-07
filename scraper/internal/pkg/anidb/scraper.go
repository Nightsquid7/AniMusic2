package anidb

import (
	"animusic/internal/pkg/cache"
	. "animusic/internal/pkg/types"
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gocolly/colly"
)

//AniDbScraper is a scraper implementation that will harvest anime title and song data from AniDB
type AniDbScraper struct {
	c      *colly.Collector
	URL    string
	Output chan ScrapedAnimeSeries
	Done   chan bool
}

func (a *AniDbScraper) Start() {
	if cache.CacheEnabled == true {
		for _, series := range cache.ReadSeasonFromCache() {
			a.Output <- series
		}

		a.Done <- true
		close(a.Output)
		close(a.Done)
		return
	}

	a.c.Visit(a.URL)
}

func (a *AniDbScraper) GetOutputChannel() <-chan ScrapedAnimeSeries {
	return a.Output
}

func (a *AniDbScraper) GetDoneChannel() <-chan bool {
	return a.Done
}

func NewAniDbScraper(s Season) *AniDbScraper {
	collector, output, done := createCollector(s)
	a := AniDbScraper{
		c:      collector,
		URL:    constructAniDbSourceURL(s),
		Output: output,
		Done:   done,
	}

	return &a
}

func createCollector(s Season) (*colly.Collector, chan ScrapedAnimeSeries, chan bool) {
	var result = make(map[string]ScrapedAnimeSeries)
	var songBuffer = make([]ScrapedSongData, 0)
	c := colly.NewCollector(colly.MaxDepth(1))
	output := make(chan ScrapedAnimeSeries)
	done := make(chan bool)

	c.Limit(&colly.LimitRule{
		// Filter domains affected by this rule
		DomainGlob:  "anidb.net",
		Parallelism: 1,
		// Set a delay between requests to these domains
		Delay: 5 * time.Second,
		// Add an additional random delay
		RandomDelay: 2 * time.Second,
	})
	songDetails := c.Clone()
	songDetails.Limit(&colly.LimitRule{
		// Filter domains affected by this rule
		DomainGlob:  "anidb.net",
		Parallelism: 1,
		// Set a delay between requests to these domains
		Delay: 5 * time.Second,
		// Add an additional random delay
		RandomDelay: 2 * time.Second,
	})

	// Find and visit all links
	c.OnHTML("div .data", func(e *colly.HTMLElement) {
		buf := ScrapedAnimeSeries{}
		buf.Year = s.Year
		buf.Season = s.Name
		e.DOM.Find(".name").Each(func(i int, s *goquery.Selection) {
			s.Find("a").Each(func(i int, s *goquery.Selection) {
				href, _ := s.Attr("href")
				buf.Ref = fmt.Sprintf("http://anidb.net%s", href)
			})
			buf.Name = strings.TrimSpace(s.Text())
		})

		e.DOM.Find(".general").Each(func(i int, s *goquery.Selection) {
			typeString := strings.TrimSpace(s.Text())
			if idx := strings.Index(typeString, ","); idx != -1 {
				buf.Format = typeString[0:idx]
			} else {
				buf.Format = typeString
			}
		})
		idx := strings.LastIndex(buf.Ref, "/")
		buf.Id = buf.Ref[idx+1:]
		result[buf.Id] = buf

		songDetails.Visit(buf.Ref)
	})

	c.OnRequest(func(r *colly.Request) {
		fmt.Println("Visiting", r.URL)
	})

	c.OnScraped(func(r *colly.Response) {
		fmt.Println("Finished", r.Request.URL)
		done <- true
		close(output)
		close(done)
	})

	songDetails.OnScraped(func(r *colly.Response) {
		id := getAnimeIDFromURL(*r.Request.URL)
		fmt.Printf("Grabbed %d songs for anime id: %s\n", len(songBuffer), id)

		buf := result[id]
		for _, song := range songBuffer {
			song.Year = buf.Year
			buf.Songs = append(buf.Songs, song)
		}
		result[id] = buf

		songBuffer = nil
		cache.SaveToCache(&buf)
		output <- result[id]
	})

	songDetails.OnRequest(func(r *colly.Request) {
		fmt.Println("Visiting", r.URL)
	})

	songDetails.OnHTML("table#songlist", func(e *colly.HTMLElement) {
		fmt.Println("Looking for songs in: ", e.Request.URL)
		currentRelation := ""
		e.DOM.Find("tr").Each(func(i int, s *goquery.Selection) {
			if len(strings.TrimSpace(s.Find("td.reltype").First().Text())) > 0 {
				currentRelation = strings.TrimSpace(s.Find("td.reltype").First().Text())
			}

			s.Find("td.name.song").Each(func(i int, ss *goquery.Selection) {
				song := ScrapedSongData{}
				song.AnimeId = getAnimeIDFromURL(*e.Request.URL)
				song.Name = strings.TrimSpace(ss.Text())
				href, _ := ss.Find("a").Attr("href")
				idx := strings.LastIndex(strings.TrimSpace(href), "/")
				song.Id = href[idx+1:]
				song.Relation = currentRelation

				s.Find("td.name.creator").Each(func(i int, s *goquery.Selection) {
					s.Find("a").Each(func(k int, ss *goquery.Selection) {
						song.Artists = append(song.Artists, ss.Text())
					})
				})

				//e.g. 154-178, OP7a-OP7b, OP2
				s.Find("td.eprange").Each(func(i int, ss *goquery.Selection) {
					rangeStrings := strings.Split(strings.TrimSpace(ss.Text()), ",")
					for _, rangeString := range rangeStrings {
						if strings.Contains(rangeString, "-") {
							eps := strings.Split(rangeString, "-")
							start, err := strconv.Atoi(strings.TrimSpace(eps[0]))
							if err != nil {
								//This is not a range, this is the classification
								song.Classification = strings.TrimSpace(rangeString)
							} else {
								epRange := EpisodeRange{}
								epRange.Start = start
								epRange.End, _ = strconv.Atoi(eps[1])
								song.Ranges = append(song.Ranges, epRange)
							}
						} else {
							num, err := strconv.Atoi(rangeString)
							if err != nil {
								//This is not a range, this is the classification
								song.Classification = strings.TrimSpace(rangeString)
							} else {
								//This is a single episode range
								epRange := EpisodeRange{}
								epRange.Start = num
								epRange.End = num
								song.Ranges = append(song.Ranges, epRange)
							}
						}
					}
				})

				songBuffer = append(songBuffer, song)
			})

		})
	})
	return c, output, done
}

func getAnimeIDFromURL(url url.URL) string {
	idx := strings.LastIndex(url.String(), "/")
	return url.String()[idx+1:]
}
func constructAniDbSourceURL(s Season) string {
	return fmt.Sprintf("http://anidb.net/anime/season/?do=calendar&do.last.anime=Show&h=1&last.anime.month=%d&last.anime.year=%s", s.GetAniDbSeasonNumber(), s.Year)
}
