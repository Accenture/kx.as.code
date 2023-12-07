package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"net/http"
	"os"
	"path/filepath"
)

type TemplateData struct {
	Config map[string]interface{}
}

const (
	jsonFileName   = "profile-config-template.json"
	templateFolder = "templates"
	templateName   = "template.html"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Read the JSON file
		file, err := os.ReadFile(jsonFileName)
		if err != nil {
			handleError(w, "Error reading JSON file", err, http.StatusInternalServerError)
			return
		}

		// Unmarshal JSON data
		var data map[string]interface{}
		err = json.Unmarshal(file, &data)
		if err != nil {
			handleError(w, "Error parsing JSON", err, http.StatusInternalServerError)
			return
		}

		fmt.Println(string(file))

		// Load HTML template from file
		tmpl, err := loadTemplate(templateName)
		if err != nil {
			handleError(w, "Error loading template", err, http.StatusInternalServerError)
			return
		}

		// Execute template with data
		err = tmpl.Execute(w, TemplateData{Config: data["config"].(map[string]interface{})})
		if err != nil {
			handleError(w, "Error rendering form", err, http.StatusInternalServerError)
			return
		}
	})

	http.ListenAndServe(":8080", nil)
}

func loadTemplate(templateName string) (*template.Template, error) {
	// Get the current working directory
	dir, err := os.Getwd()
	if err != nil {
		return nil, err
	}

	// Construct the template file path
	templatePath := filepath.Join(dir, templateFolder, templateName)

	// Parse and return the template
	return template.ParseFiles(templatePath)
}

func handleError(w http.ResponseWriter, message string, err error, statusCode int) {
	http.Error(w, fmt.Sprintf("%s: %s", message, err.Error()), statusCode)
}
