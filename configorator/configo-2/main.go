package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"net/http"
	"os"
)

type TemplateData struct {
	Config map[string]interface{}
}

const minimalTemplate = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Configuration Form</title>
</head>
<body>

    <h2>Profile Configuration Form</h2>
    
    <form method="post" action="/submit">
        {{ template "fields" .Config }}

        <input type="submit" value="Submit">
    </form>

    {{ define "fields" }}
        {{ range $key, $value := . }}
            {{ if or (eq (printf "%T" $value) "string") (eq (printf "%T" $value) "bool") }}
                <!-- If value is string or boolean, create an input field -->
                <label for="{{ $key }}">{{ $key }}:</label>
                {{ if eq (printf "%T" $value) "bool" }}
                    <input type="checkbox" id="{{ $key }}" name="{{ $key }}" {{ if $value }}checked{{ end }}><br>
                {{ else }}
                    <input type="text" id="{{ $key }}" name="{{ $key }}" placeholder="{{ $value }}"><br>
                {{ end }}
            {{ else if eq (printf "%T" $value) "[]interface {}" }}
                <!-- If value is a string array, create a dropdown select field -->
                <label for="{{ $key }}">{{ $key }}:</label>
                <select id="{{ $key }}" name="{{ $key }}">
                    {{ range $index, $item := $value }}
                        <option value="{{ $item }}">{{ $item }}</option>
                    {{ end }}
                </select><br>
            {{ else if eq (printf "%T" $value) "map[string]interface {}" }}
                <!-- If value is a nested map, recurse into it -->
                <div style="margin-left: 20px;">
                    <h3>{{ $key }}</h3>
                    {{ template "fields" $value }}
                </div>
            {{ end }}
        {{ end }}
    {{ end }}

</body>
</html>
`

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		file, err := os.ReadFile("profile-config-template.json")
		if err != nil {
			http.Error(w, "Error reading JSON file: "+err.Error(), http.StatusInternalServerError)
			return
		}

		var data map[string]interface{}
		err = json.Unmarshal(file, &data)
		if err != nil {
			http.Error(w, "Error parsing JSON: "+err.Error(), http.StatusInternalServerError)
			return
		}

		fmt.Println(string(file))

		tmpl, err := template.New("form").Parse(minimalTemplate)
		if err != nil {
			http.Error(w, "Error parsing template: "+err.Error(), http.StatusInternalServerError)
			return
		}

		err = tmpl.Execute(w, TemplateData{Config: data["config"].(map[string]interface{})})
		if err != nil {
			http.Error(w, "Error rendering form: "+err.Error(), http.StatusInternalServerError)
			return
		}
	})

	http.ListenAndServe(":8080", nil)
}
