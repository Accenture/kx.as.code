package main

import (
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"os"

	"github.com/kirici/configorator/form"
)

//go:embed public
var emPub embed.FS

func main() {
	port := configPort()

	fs := *newServerFS()
	// TODO: go getBin(url) and writeBin(name)

	http.Handle("/", fs)
	http.HandleFunc("/submit", handleForm)
	// TODO: when go 1.22 hits use "POST /submit"

	fmt.Println("Starting server at", port)
	log.Fatal(http.ListenAndServe(port, nil))
}

func configPort() (port string) {
	os.Getenv("CONFIGOPORT")
	if port == "" {
		port = "8080"
	}
	port = ":" + port
	return port
}

func newServerFS() *http.Handler {
	staticFS := fs.FS(emPub)
	fsPublic, err := fs.Sub(staticFS, "public")
	if err != nil {
		log.Fatal(err)
	}
	fs := http.FileServer(http.FS(fsPublic))
	return &fs
}

func handleForm(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	formValues := form.ParseValues(r)
	writeJSON(formValues, "profile-config.json")

	submitPage, _ := emPub.ReadFile("public/submit.html")
	w.Write(submitPage)

	// execPipeline("./bin", "--help")
}

func writeJSON(c *form.Profile, filename string) {
	jsonData, err := json.MarshalIndent(c, "", " ")
	if err != nil {
		fmt.Printf("ERROR: %s", err)
	}
	f, err := os.Create(filename)
	if err != nil {
		fmt.Printf("ERROR: %s", err)
	}
	defer f.Close()

	f.Write(jsonData)
}
