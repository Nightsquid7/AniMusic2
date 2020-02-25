package cache

import (
	"animusic/internal/pkg/types"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

var memcache map[string]types.ScrapedAnimeSeries
var cacheSeason *types.Season
var CacheEnabled bool = false

func init() {
	os.MkdirAll(".cache", 0644)
}

//InitCache attempts to initialize the cache for the specified season by reading from disk when cacheEnabled is set to true
//Otherwise it will initialize an empty map, which will be used to overwrite any existing cache file
func InitCache(season *types.Season, cacheEnabled bool) {
	cacheSeason = season
	path := filepath.Join(".cache/", fmt.Sprintf("%s.json", season.String()))

	if _, err := os.Stat(path); os.IsNotExist(err) {
		memcache = make(map[string]types.ScrapedAnimeSeries)
	} else {
		if cacheEnabled == true {
			dat, err := ioutil.ReadFile(path)
			if err != nil {
				//Cache corruption
				os.Exit(1)
			}
			err = json.Unmarshal(dat, &memcache)

			if err != nil {
				//Cache corruption
				os.Exit(1)
			}
			CacheEnabled = cacheEnabled
		} else {
			memcache = make(map[string]types.ScrapedAnimeSeries)
		}
	}
}

func SaveToCache(scrapedSeries *types.ScrapedAnimeSeries) {
	memcache[scrapedSeries.Id] = *scrapedSeries

	//TODO: Redo this if it turns out to be a performance bottleneck
	file, _ := json.MarshalIndent(memcache, "", "\t")
	path := filepath.Join(".cache/", fmt.Sprintf("%s.json", cacheSeason.String()))
	_ = ioutil.WriteFile(path, file, 0644)
}

func ReadSeasonFromCache() []types.ScrapedAnimeSeries {
	var result = make([]types.ScrapedAnimeSeries, 0)
	for _, value := range memcache {
		result = append(result, value)
	}
	return result
}
