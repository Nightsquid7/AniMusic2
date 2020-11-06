package json

import (
	"animusic/internal/pkg/types"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

type Writer struct {
	writePath string
}

func (w *Writer) Output(animeSeries []types.AnimeSeries, season types.Season) {
	buf := make(map[string]types.AnimeSeries)
	for _, anime := range animeSeries {
		buf[anime.Id] = anime
	}
	
	fmt.Fprintln(os.Stdout, "Writing output to: ", w.writePath)
	json, _ := json.MarshalIndent(buf, "", "\t")
	err := ioutil.WriteFile(w.writePath, json, 0700)
	if err != nil {
		fmt.Println("found err while tryingToWriteFile", err)
	}
}

func CreateNewJsonWriter(writePath string) *Writer {
	w := Writer{
		writePath: writePath,
	}
	return &w
}
