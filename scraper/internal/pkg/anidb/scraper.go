package anidb

import (
	"animusic/internal/pkg/cache"
	. "animusic/internal/pkg/types"
	"encoding/json"
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gocolly/colly"
	"github.com/gocolly/colly/extensions"
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
	var artistBuffer = make([]ScrapedArtist, 0)
	var songDetailsBuffer = make(map[string]string)
	var artistDetailsBuffer = make(map[string]string)

	c := colly.NewCollector(colly.MaxDepth(1))
	extensions.RandomUserAgent(c)
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
	seriesDetails := c.Clone()
	songDetails := c.Clone()
	artistDetails := c.Clone()

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

		seriesDetails.Visit(buf.Ref)
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

	seriesDetails.OnScraped(func(r *colly.Response) {
		id := getIDFromURL(*r.Request.URL)
		fmt.Printf("Grabbed %d songs for anime id: %s\n", len(songBuffer), id)

		buf := result[id]
		for _, song := range songBuffer {
			song.Year = buf.Year
			song.Name = songDetailsBuffer[song.Id]
			for _, artist := range artistBuffer {
				if song.Id == artist.SongId && song.Relation == artist.Relation {
					artist.Name = artistDetailsBuffer[artist.Id]
					song.Artists = append(song.Artists, artist)
				}
			}
			buf.Songs = append(buf.Songs, song)
		}

		result[id] = buf

		songBuffer = nil
		artistBuffer = nil
		songDetailsBuffer = make(map[string]string)
		artistDetailsBuffer = make(map[string]string)
		cache.SaveToCache(&buf)
		json, _ := json.MarshalIndent(result[id], "", "\t")
		fmt.Println(string(json))
		output <- result[id]
	})

	seriesDetails.OnRequest(func(r *colly.Request) {
		fmt.Println("Visiting", r.URL)
	})

	seriesDetails.OnHTML("table#songlist", func(e *colly.HTMLElement) {
		fmt.Println("Looking for songs in: ", e.Request.URL)
		currentRelation := ""
		e.DOM.Find("tr").Each(func(i int, s *goquery.Selection) {
			if len(strings.TrimSpace(s.Find("td.reltype").First().Text())) > 0 {
				currentRelation = strings.TrimSpace(s.Find("td.reltype").First().Text())
			}

			s.Find("td.name.song").Each(func(i int, ss *goquery.Selection) {
				song := ScrapedSongData{}
				song.AnimeId = getIDFromURL(*e.Request.URL)
				song.NameEn = strings.TrimSpace(ss.Text())
				href, _ := ss.Find("a").Attr("href")
				idx := strings.LastIndex(strings.TrimSpace(href), "/")
				song.Id = href[idx+1:]
				song.Relation = currentRelation
				song.Ref = fmt.Sprintf("http://anidb.net%s", href)
				fmt.Println("Looking for song details in: ", song.Ref)
				songDetails.Visit(song.Ref)

				s.Find("td.name.creator").Each(func(i int, s *goquery.Selection) {
					s.Find("a").Each(func(k int, ss *goquery.Selection) {
						href, _ := ss.Attr("href")
						artist := ScrapedArtist{}
						idx := strings.LastIndex(href, "/")
						artist.Id = href[idx+1:]
						artist.SongId = song.Id
						artist.NameEn = ss.Text()
						artist.Relation = song.Relation
						artist.Ref = fmt.Sprintf("http://anidb.net%s", href)
						artistBuffer = append(artistBuffer, artist)
						fmt.Println("Looking for artist details in: ", artist.Ref)
						artistDetails.Visit(artist.Ref)
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

	songDetails.OnHTML("label[itemprop=\"alternateName\"]", func(e *colly.HTMLElement) {
		songNameJp := e.DOM.First().Text()
		songDetailsBuffer[getIDFromURL(*e.Request.URL)] = songNameJp
	})

	artistDetails.OnHTML("label[itemprop=\"alternateName\"]", func(e *colly.HTMLElement) {
		artistNameJp := e.DOM.First().Text()
		artistDetailsBuffer[getIDFromURL(*e.Request.URL)] = artistNameJp
	})

	return c, output, done
}

func getIDFromURL(url url.URL) string {
	idx := strings.LastIndex(url.String(), "/")
	return url.String()[idx+1:]
}

func constructAniDbSourceURL(s Season) string {
	return fmt.Sprintf("http://anidb.net/anime/season/?do=calendar&do.last.anime=Show&h=1&last.anime.month=%d&last.anime.year=%s", s.GetAniDbSeasonNumber(), s.Year)
}
