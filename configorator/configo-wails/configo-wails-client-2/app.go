package main

import (
	"archive/zip"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"sort"
	"sync"
	"time"
)

// App struct
type App struct {
	ctx          context.Context
	mu           sync.Mutex
	cmd          *exec.Cmd
	currentStage string
	buildId      int64
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

func (a *App) GetCurrentBuildStage() string {
	return a.currentStage
}

func (a *App) SetCurrentBuildStage(stage string) {
	a.currentStage = stage
	log.Printf("Current build stage set to: %s", stage)
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

func (a *App) IsVirtualizationToolInstalled(toolName string) bool {
	var cmd *exec.Cmd

	switch toolName {
	case "virtualbox":
		cmd = exec.Command("VBoxManage", "--version")
	case "parallels":
		cmd = exec.Command("prlctl", "--version")
	case "vmware-desktop":
		cmd = exec.Command("vmware", "--version")
	default:
		return false
	}

	err := cmd.Run()
	return err == nil
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
	case "applicationGroups":
		filePath = "./frontend/src/assets/templates/applicationGroups.json"
	default:
		return fmt.Errorf("unsupported file parameter: %s", file)
	}

	err = os.WriteFile(filePath, jsonDataStr, 0644)
	if err != nil {
		return fmt.Errorf("error writing to file %s: %v", filePath, err)
	}

	return nil
}

func (a *App) ExeBuild() string {

	a.buildId = time.Now().UnixNano()

	buildHistory := struct {
		ID        int64  `json:"id"`
		Timestamp string `json:"timestamp"`
		Status    string `json:"status"`
	}{
		ID:        int64(a.buildId),
		Timestamp: time.Now().Format(time.RFC3339),
		Status:    "success",
	}

	if _, err := os.Stat("./frontend/src/assets/build-history/"); os.IsNotExist(err) {
		if err := os.MkdirAll("./frontend/src/assets/build-history/", 0755); err != nil {
			log.Printf("Failed to create build history directory: %v", err)
			return fmt.Sprintf("An error occurred: %v", err)
		}
	}

	outfile, err := os.Create("./frontend/src/assets/buildOutput.txt")
	if err != nil {
		log.Printf("Failed to create output file: %v", err)
		return fmt.Sprintf("An error occurred: %v", err)
	}

	if err := outfile.Truncate(0); err != nil {
		log.Printf("Failed to truncate file: %v", err)
		return fmt.Sprintf("An error occurred: %v", err)
	}

	if _, err := outfile.Seek(0, 0); err != nil {
		log.Printf("Failed to seek file: %v", err)
		return fmt.Sprintf("An error occurred: %v", err)
	}

	writeStage := func(stageNumber int, stageName string) {
		timestamp := time.Now().Format(time.RFC3339)
		fmt.Fprintf(outfile, "[%s] [stage-%d] - %s\n", timestamp, stageNumber, stageName)
		// Data flushed to file
		outfile.Sync()
	}

	// Add stage details in build output file
	writeStage(1, "Initialize Build")
	// Set current stage. Will be returned to client with GetCurrentBuildStage()
	a.SetCurrentBuildStage("stage 1")
	time.Sleep(1 * time.Second)

	a.StopExe()

	a.mu.Lock()
	defer a.mu.Unlock()

	var packerBinaryPath string

	switch runtime.GOOS {
	case "darwin", "linux":
		writeStage(2, "Download Packer")
		a.SetCurrentBuildStage("stage 2")
		time.Sleep(1 * time.Second)

		packerBinaryPath = "./frontend/src/assets/packer/packer"
		if _, err := os.Stat(packerBinaryPath); os.IsNotExist(err) {
			buildHistory.Status = "failed"
			if err := downloadPackerBinary(packerBinaryPath); err != nil {
				buildHistory.Status = "failed"
				log.Printf("Failed to download Packer: %v", err)
				return fmt.Sprintf("An error occurred while downloading Packer: %v", err)
			}

			writeStage(3, "Install Packer")
			a.SetCurrentBuildStage("stage 3")
			time.Sleep(3 * time.Second)

			chmodCmd := exec.Command("chmod", "+x", packerBinaryPath)
			if chmodErr := chmodCmd.Run(); chmodErr != nil {
				buildHistory.Status = "failed"
				log.Printf("Failed to set execute permissions: %v", chmodErr)
				return fmt.Sprintf("An error occurred while setting execute permissions: %v", chmodErr)
			}
		} else {
			writeStage(3, "Install Packer")
			a.SetCurrentBuildStage("stage 3")
			time.Sleep(1 * time.Second)
		}
	default:
		log.Printf("Unsupported operating system: %v", runtime.GOOS)
		return fmt.Sprintf("Unsupported operating system: %v", runtime.GOOS)
	}

	writeStage(4, "Execute Packer")
	a.SetCurrentBuildStage("stage 4")
	time.Sleep(1 * time.Second)

	hclPath := "./frontend/src/assets/config/hcl/kx-main-local-profiles.pkr.hcl"

	a.cmd = exec.Command(packerBinaryPath, "init", hclPath, "&&", packerBinaryPath, "build", "-force", "-only", "-var", "git_source_branch=feature/debian12-upgrade", "vmware-iso.kx-main-virtualbox", hclPath)

	a.cmd.Stdout = outfile

	if err := a.cmd.Start(); err != nil {
		buildHistory.Status = "failed"
		log.Printf("Failed to start command: %v", err)
		return fmt.Sprintf("An error occurred: %v", err)
	} else {

	}

	// WaitGroup to synchronize the completion of cmd.Wait()
	var wg sync.WaitGroup
	wg.Add(1)

	go func() {
		log.Printf("Waiting for build to finish...")
		if waitErr := a.cmd.Wait(); waitErr != nil {
			log.Printf("Build finished with error: %v", waitErr)
			buildHistory.Status = "failed"
			log.Printf("Status set to 'failed'")
		} else {
			log.Printf("Build completed successfully")
			writeStage(5, "Build Completed")
			a.SetCurrentBuildStage("stage 5")
			time.Sleep(1 * time.Second)
		}

		// Signal that cmd.Wait() is completed
		wg.Done()
	}()

	// Wait for completion of cmd.Wait() before executing the deferred function
	wg.Wait()

	defer func() {
		jsonContent, jsonErr := json.MarshalIndent(buildHistory, "", "    ")
		if jsonErr != nil {
			log.Printf("Failed to marshal build history to JSON: %v", jsonErr)
			return
		}

		fileName := fmt.Sprintf("./frontend/src/assets/build-history/build-%d.json", a.buildId)

		// List of files in the build history directory
		files, err := os.ReadDir("./frontend/src/assets/build-history/")
		if err != nil {
			log.Printf("Failed to read build history directory: %v", err)
			return
		}

		if _, err := os.Stat("./frontend/src/assets/build-history/"); os.IsNotExist(err) {
			if err := os.MkdirAll("./frontend/src/assets/build-history/", 0755); err != nil {
				log.Printf("Failed to create build history directory: %v", err)
				return
			}
		}

		// If there are 10 files, delete the oldest file
		if len(files) >= 10 {
			sort.Slice(files, func(i, j int) bool {
				infoI, errI := files[i].Info()
				infoJ, errJ := files[j].Info()

				if errI != nil || errJ != nil {
					// Handle errors if needed
					return false
				}

				return infoI.ModTime().Before(infoJ.ModTime())
			})

			oldestFileName := files[0].Name()
			oldestFilePath := filepath.Join("./frontend/src/assets/build-history/", oldestFileName)

			if err := os.Remove(oldestFilePath); err != nil {
				log.Printf("Failed to delete the oldest file: %v", err)
			}
		}

		if writeErr := os.WriteFile(fileName, jsonContent, 0644); writeErr != nil {
			log.Printf("Failed to write build history to file: %v", writeErr)
		}

		log.Printf("Final buildHistory content: %s", jsonContent)
	}()

	return "Initialize Build..."
}

func downloadPackerBinary(destination string) error {
	var url string

	switch runtime.GOOS {
	case "darwin":
		if runtime.GOARCH == "amd64" {
			url = "https://releases.hashicorp.com/packer/1.10.1/packer_1.10.1_darwin_amd64.zip"
		} else if runtime.GOARCH == "arm64" {
			url = "https://releases.hashicorp.com/packer/1.10.1/packer_1.10.1_darwin_arm64.zip"
		} else if runtime.GOARCH == "arm" {
			url = "https://releases.hashicorp.com/packer/1.10.1/packer_1.10.1_darwin_arm.zip"
		} else {
			return fmt.Errorf("unsupported architecture: %s", runtime.GOARCH)
		}
	case "linux":
		return fmt.Errorf("unsupported architecture: %s", runtime.GOARCH)
	default:
		return fmt.Errorf("unsupported operating system: %s", runtime.GOOS)
	}

	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("failed to download Packer binary: %v", err)
	}
	defer resp.Body.Close()

	err = os.MkdirAll(filepath.Dir(destination), 0755)
	if err != nil {
		return fmt.Errorf("failed to create directory: %v", err)
	}

	file, err := os.Create(destination + ".zip")
	if err != nil {
		return fmt.Errorf("failed to create file: %v", err)
	}
	defer file.Close()

	_, err = io.Copy(file, resp.Body)
	if err != nil {
		return fmt.Errorf("failed to write to file: %v", err)
	}

	if err := unzipFile(file.Name(), filepath.Dir(destination)); err != nil {
		return fmt.Errorf("failed to unzip file: %v", err)
	}

	chmodCmd := exec.Command("chmod", "+x", destination)
	if err := chmodCmd.Run(); err != nil {
		return fmt.Errorf("failed to set execute permissions: %v", err)
	}

	return nil
}

func unzipFile(source, destination string) error {
	r, err := zip.OpenReader(source)
	if err != nil {
		return err
	}
	defer r.Close()

	err = os.MkdirAll(destination, 0755)
	if err != nil {
		return err
	}

	for _, f := range r.File {
		rc, err := f.Open()
		if err != nil {
			return err
		}
		defer rc.Close()

		path := filepath.Join(destination, f.Name)

		f, err := os.Create(path)
		if err != nil {
			return err
		}
		defer f.Close()

		_, err = io.Copy(f, rc)
		if err != nil {
			return err
		}

	}

	return nil
}

func (a *App) StopExe() {
	log.Printf("Build stop...")
	a.mu.Lock()
	defer a.mu.Unlock()

	if a.cmd != nil && a.cmd.Process != nil {
		a.cmd.Process.Kill()
		a.cmd = nil
	}

	// Copy logs to build-logs
	logFileName := fmt.Sprintf("./frontend/src/assets/build-logs/build-log-%d.txt", a.buildId)
	if copyErr := copyFile("./frontend/src/assets/buildOutput.txt", logFileName); copyErr != nil {
		log.Printf("Failed to copy build output file to build logs: %v", copyErr)
	}

	// Truncate buildOutput.txt file
	if truncateErr := os.Truncate("./frontend/src/assets/buildOutput.txt", 0); truncateErr != nil {
		log.Printf("Failed to truncate build output file: %v", truncateErr)
	}

	// Delete content of log file
	os.Truncate("./frontend/src/assets/buildOutput.txt", 0)
}

func copyFile(src, dst string) error {
	sourceFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer sourceFile.Close()

	destinationFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer destinationFile.Close()

	_, err = io.Copy(destinationFile, sourceFile)
	if err != nil {
		return err
	}

	// Check the number of files in "build-logs" directory
	files, err := os.ReadDir("./frontend/src/assets/build-logs/")
	if err != nil {
		return err
	}

	// If there are already 10 files, delete the oldest file
	if len(files) >= 10 {
		sort.Slice(files, func(i, j int) bool {
			infoI, _ := files[i].Info()
			infoJ, _ := files[j].Info()
			return infoI.ModTime().Before(infoJ.ModTime())
		})

		oldestFileName := files[0].Name()
		oldestFilePath := filepath.Join("./frontend/src/assets/build-logs/", oldestFileName)

		if err := os.Remove(oldestFilePath); err != nil {
			log.Printf("Failed to delete the oldest file in build-logs: %v", err)
		}
	}

	return nil
}

func (a *App) OpenURL(url string) error {
	// cmd := exec.Command("xdg-open", url) // For Linux systems
	cmd := exec.Command("open", url) // For macOS
	// cmd := exec.Command("cmd", "/c", "start", url) // For Windows

	err := cmd.Run()
	return err
}
