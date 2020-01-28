package main

import (
	"animusic/internal/pkg/anidb"
	"animusic/internal/pkg/types"
	"fmt"
	"time"
)

func main() {
	season := types.NewSeason(time.Now())
	fmt.Println(season)
	a := anidb.NewAniDbScraper(*season)
	a.Start()
}
