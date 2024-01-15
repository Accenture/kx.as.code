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

func (a *App) Greet(name string) string {
	return fmt.Sprintf("Hello %s, It's show time!", name)
}

func (a *App) UpdateJsonFile(data string, file string) error {
	fmt.Printf("UpdateJsonFile triggered %s!\n", data)
	if data == "" {
		return errors.New("empty JSON string provided")
	}

	var jsonData interface{}
	if err := json.Unmarshal([]byte(data), &jsonData); err != nil {
		return fmt.Errorf("error unmarshaling JSON: %v", err)
	}

	jsonDataStr, err := json.MarshalIndent(jsonData, "", "    ")
	if err != nil {
		return fmt.Errorf("error marshaling JSON: %v", err)
	}

	var filePath string

	// Choose file path based on the 'file' parameter
	switch file {
	case "profile":
		filePath = "./frontend/src/assets/config/config.json"
	case "users":
		filePath = "./frontend/src/assets/config/users.json"
	case "customVariables":
		filePath = "./frontend/src/assets/config/customVariables.json"
	default:
		return fmt.Errorf("unsupported file parameter: %s", file)
	}

	err = os.WriteFile(filePath, jsonDataStr, 0644)
	if err != nil {
		return fmt.Errorf("error writing to file %s: %v", filePath, err)
	}

	return nil
}

func (a *App) ExeceuteBuildCommand() error {
	// OS Checkup
	// VM Checkup

	return nil
}

func (a *App) ExeceuteDeployCommand() error {
	// OS Checkup
	// VM Checkup

	return nil
}

// func isCommandAvailable(name string) bool {
// 	cmd := exec.Command("/bin/sh", "-c", "command -v "+name)
// 	if err := cmd.Run(); err != nil {
// 			return false
// 	}
// }
