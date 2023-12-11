package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
)

type ConfigData struct {
	Config map[string]interface{}
}

func getFormData() (string, error) {
	file, err := os.ReadFile("./profile-config-template.json")
	if err != nil {
		return "", fmt.Errorf("Error reading JSON file: %s", err)
	}

	var data map[string]interface{}
	err = json.Unmarshal(file, &data)
	if err != nil {
		return "", fmt.Errorf("Error parsing JSON: %s", err)
	}

	configData := ConfigData{
		Config: data["config"].(map[string]interface{}),
	}

	jsonData, err := json.Marshal(configData)
	if err != nil {
		return "", fmt.Errorf("Error encoding JSON: %s", err)
	}

	fmt.Println("getFormData called")
	fmt.Println("File:", file)
	fmt.Println("Data:", string(file))

	return string(jsonData), nil
}

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

// Expose GetFormData method
func (a *App) GetFormData() (string, error) {
	return getFormData()
}
