package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"sync"
)

// App struct
type App struct {
	ctx context.Context
	mu  sync.Mutex
	cmd *exec.Cmd
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

func (a *App) ExeBuild() string {
	a.StopExe()

	a.mu.Lock()
	defer a.mu.Unlock()

	outfile, err := os.Create("./frontend/src/assets/buildOutput.txt")
	if err != nil {
		log.Fatal(err)
		return "An error occurred: " + err.Error()
	}
	defer outfile.Close()

	a.cmd = exec.Command("ping", "google.com")
	a.cmd.Stdout = outfile

	err = a.cmd.Start()
	if err != nil {
		return "An error occurred: " + err.Error()
	}

	go func() {
		log.Printf("Waiting for build to finish...")
		err = a.cmd.Wait()
		log.Printf("Build finished with error: %v", err)
	}()

	return "Build executed successfully"
}

func isPrintable(r rune) bool {
	return r >= 32 && r < 127
}

func filterPrintable(s string) string {
	var filtered string
	for _, r := range s {
		if isPrintable(r) {
			filtered += string(r)
		}
	}
	return filtered
}

func (a *App) StopExe() {
	log.Printf("Build stop...")
	a.mu.Lock()
	defer a.mu.Unlock()

	if a.cmd != nil && a.cmd.Process != nil {
		a.cmd.Process.Kill()
		a.cmd = nil
	}

	// Delete content of log file
	os.Truncate("./frontend/src/assets/buildOutput.txt", 0)
}
