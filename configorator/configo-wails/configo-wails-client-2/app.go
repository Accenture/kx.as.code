package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
)

// App struct
type App struct {
	ctx context.Context
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// Greet returns a greeting for the given name
func (a *App) Greet(name string) string {
	return fmt.Sprintf("Hello %s, It's show time!", name)
}

func (a *App) UpdateJsonFile(data string) error {
	// Check if the input data is an empty string
	if data == "" {
		return errors.New("empty JSON string provided")
	}

	// Attempt to unmarshal the data into a string directly
	var jsonString string
	if err := json.Unmarshal([]byte(data), &jsonString); err == nil {
		// If successful, write the string directly to the file
		if err := os.WriteFile("./frontend/src/assets/config/config.json", []byte(jsonString), 0644); err != nil {
			return fmt.Errorf("error writing to file: %v", err)
		}
		return nil
	}

	// If the direct unmarshal to string fails, assume it's a JSON object
	var jsonData map[string]interface{}
	if err := json.Unmarshal([]byte(data), &jsonData); err != nil {
		return fmt.Errorf("error unmarshaling JSON: %v", err)
	}

	// Convert the map to JSON
	jsonDataStr, err := json.MarshalIndent(jsonData, "", "    ")
	if err != nil {
		return fmt.Errorf("error marshaling JSON: %v", err)
	}

	// Write the JSON data to the file
	if err := os.WriteFile("./frontend/src/assets/config/config.json", jsonDataStr, 0644); err != nil {
		return fmt.Errorf("error writing to file: %v", err)
	}

	return nil
}
