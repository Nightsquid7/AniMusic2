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
	buf := make(map[string][]types.AnimeSeries)
	fmt.Fprintln(os.Stdout, "Writing output to: ", w.writePath)
	json, _ := json.MarshalIndent(buf, "", "\t")
	ioutil.WriteFile(w.writePath, json, 0644)
}

func CreateNewJsonWriter(writePath string) *Writer {
	w := Writer{
		writePath: writePath,
	}
	return &w
}
