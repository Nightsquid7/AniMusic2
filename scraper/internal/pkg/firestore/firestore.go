package firestore

import (
	"animusic/internal/pkg/types"
	"fmt"
	"os"
	"time"
	"golang.org/x/net/context"
	

	fs "cloud.google.com/go/firestore"
	firebase "firebase.google.com/go"

	"google.golang.org/api/option"
)

type Writer struct {
	client *firebase.App
}

//Output starts the write action to Firestore
func (f *Writer) Output(animeSeries []types.AnimeSeries, season types.Season) {
	fmt.Println("Writing to Firestore...")
	firestore, _ := f.client.Firestore(context.Background())
	batches := make([]*fs.WriteBatch, 0)
	var currentBatch *fs.WriteBatch

	for idx, anime := range animeSeries {
		//Only a maximum of 500 writes are allowed per batch, so we have to create a new batch
		if idx%500 == 0 {
			batch := firestore.Batch()
			batches = append(batches, batch)
			currentBatch = batch
		}

		if len(anime.Songs) == 0 {
			continue
		}
		
		ref := firestore.Collection(season.String()).Doc(anime.Id)
		currentBatch.Set(ref, anime)
	}

	

	for _, batch := range batches {
		_, err := batch.Commit(context.Background())
		if err != nil {
			fmt.Println("err", err)
			os.Exit(1)
		}

		seasonEntry := types.NewSeasonEntryFromSeasonWithCount(season, len(animeSeries), time.Now())
		_, err = firestore.Collection("Seasons-List").Doc(season.String()).Set(context.Background(), seasonEntry)
		
		if err != nil {
			fmt.Println("error writing entry to Seasons-List: ", err)
		}
		fmt.Println("wrote to Seasons-List", seasonEntry, "with count", len(animeSeries))
	}
}

//CreateFirestoreOutputWriter creates a new instance of Firestore output writer for writing song information to Firestpre
func CreateFirestoreOutputWriter(firebaseCredPath string) *Writer {
	//Initialize Firebase admin sdk
	opt := option.WithCredentialsFile(firebaseCredPath)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		//Error is unrecoverable, so exit
		e := fmt.Errorf("Error initializing Firestore output writer: %v", err)
		fmt.Println(e)
		os.Exit(1)
	}
	fmt.Println("Successfully initialized Firebase admin sdk")
	f := Writer{
		client: app,
	}
	return &f
}

type FirestoreScraper struct {
	client *firebase.App
	s      types.Season
	Output chan types.ScrapedAnimeSeries
	Done   chan bool
}

func (f* FirestoreScraper) Start() {
	fmt.Println("Getting anime from firestore for season", f.s.String())
	firebaseAnime, err := f.ReadSeasonsFromFirebase(f.s)
	if err != nil {
		fmt.Println("err in FirestoreScraper", err)
	}
	for _, series := range firebaseAnime {
		f.Output <- series
	}

	f.Done <-  true 
	close(f.Output)
	close(f.Done)
	return
}

func (f *FirestoreScraper) GetOutputChannel() <-chan types.ScrapedAnimeSeries {
	return f.Output
}

func (f *FirestoreScraper) GetDoneChannel() <-chan bool {
	return f.Done
}

func NewFirestoreScraper(s types.Season, firebaseCredPath string) *FirestoreScraper {
	//Initialize Firebase admin sdk
	opt := option.WithCredentialsFile(firebaseCredPath)
	output := make(chan types.ScrapedAnimeSeries)
	done := make(chan bool)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		//Error is unrecoverable, so exit
		e := fmt.Errorf("Error initializing Firestore output writer: %v", err)
		fmt.Println(e)
		os.Exit(1)
	}
	f := FirestoreScraper{
		client: app,
		s:      s,
		Output: output,
		Done:   done,
	}
	return &f
}

func (f *FirestoreScraper) ReadSeasonsFromFirebase(s types.Season) ([]types.ScrapedAnimeSeries, error) {
	var  results []types.ScrapedAnimeSeries
	firestore, _ := f.client.Firestore(context.Background())
	collectionRef := firestore.Collection(s.String())
	animeRefs, err := collectionRef.DocumentRefs(context.Background()).GetAll()
	if err != nil {
		fmt.Println("err", err)
	}
	
	for _, animeReference := range animeRefs {
		if err != nil {
			fmt.Println("err", err)
		}
		animeSnapshots := animeReference.Snapshots(context.Background())
		
		next,err := animeSnapshots.Next()
		if err != nil {
			fmt.Println("err", err)
		}
		animeSeriesData := next.Data()

		songsData := animeSeriesData["Songs"].(map[ string ]interface{})
		foundSongs := []types.ScrapedSongData{}
		// TODO: create a method in types NewScrapedSeriesFrom(data)
		for _, data   := range songsData {
			songData := data.(map[ string ]interface{})
			foundArtists := []types.ScrapedArtist{}
			artists := songData["Artists"]
			if artists != nil {
				for _, artistArray := range artists.([]interface{}) {
					artistData := artistArray.(map[string]interface{})
					artist := types.ScrapedArtist {
						Id:        artistData["Id"].(string),
						Name:      artistData["Name"].(string),
						NameEn:    artistData["NameEn"].(string),
					}
					foundArtists = append(foundArtists, artist)
				}
			}
			songRanges := songData["Ranges"]
			foundRanges := []types.EpisodeRange{}
			if songRanges != nil {
				for _, rangesArray := range songRanges.([]interface{}) {
					rangeData := rangesArray.(map[string]interface{})
					episodeRange := types.EpisodeRange {
						Start: int(rangeData["Start"].(int64)),
						End:   int(rangeData["Start"].(int64)),
					}
					foundRanges = append(foundRanges, episodeRange)
				}
			}
			// fmt.Println("songData: \n", songData)
			song := types.ScrapedSongData {
				Id:              songData["Id"].(string),
				AnimeId:         animeSeriesData["Id"].(string),
				Name:            songData["Name"].(string),
				NameEn:          songData["NameEn"].(string),
				Ranges:          foundRanges,
				Classification:  songData["Classification"].(string),
				Artists:         foundArtists,
				Relation:        songData["Relation"].(string),
				Year:            animeSeriesData["Year"].(string), 
				Ref:             fmt.Sprintf("https://anidb.net/song/%s", songData["Id"].(string)),
			}
			foundSongs = append(foundSongs, song)
		}

		firebaseAnime := types.ScrapedAnimeSeries{
			Id               :animeSeriesData["Id"].(string),
			Name             :animeSeriesData["Name"].(string),
			TitleImageName   :animeSeriesData["TitleImageName"].(string),
			Ref              :animeSeriesData["AniDbUri"].(string),      
			Format           :animeSeriesData["Format"].(string),        
			Season           :animeSeriesData["Season"].(string),        
			Year             :animeSeriesData["Year"].(string),          
			Songs            :foundSongs,
		}
		results = append(results, firebaseAnime)
	}
	return results, nil
}