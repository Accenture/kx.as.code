package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"sync"
)

// App struct
type App struct {
	ctx      context.Context
	output   string
	outputMu sync.Mutex
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

func (a *App) UpdateJsonFile(data string) error {
	if data == "" {
		return errors.New("empty JSON string provided")
	}

	var jsonString string
	if err := json.Unmarshal([]byte(data), &jsonString); err == nil {
		if err := os.WriteFile("./frontend/src/assets/config/config.json", []byte(jsonString), 0644); err != nil {
			return fmt.Errorf("error writing to file: %v", err)
		}
		return nil
	}

	var jsonData map[string]interface{}
	if err := json.Unmarshal([]byte(data), &jsonData); err != nil {
		return fmt.Errorf("error unmarshaling JSON: %v", err)
	}

	jsonDataStr, err := json.MarshalIndent(jsonData, "", "    ")
	if err != nil {
		return fmt.Errorf("error marshaling JSON: %v", err)
	}

	if err := os.WriteFile("./frontend/src/assets/config/config.json", jsonDataStr, 0644); err != nil {
		return fmt.Errorf("error writing to file: %v", err)
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
