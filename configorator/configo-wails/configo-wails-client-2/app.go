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
	"sync"
)

// App struct
type App struct {
	ctx          context.Context
	mu           sync.Mutex
	cmd          *exec.Cmd
	currentStage string
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

func (a *App) ExeBuild() string {
	a.SetCurrentBuildStage("stage 1")
	a.StopExe()

	a.mu.Lock()
	defer a.mu.Unlock()

	outfile, err := os.Create("./frontend/src/assets/buildOutput.txt")
	if err != nil {
		log.Printf("Failed to create output file: %v", err)
		return fmt.Sprintf("An error occurred: %v", err)
	}

	var packerBinaryPath string

	switch runtime.GOOS {
	case "darwin", "linux":
		// currentUser, userErr := user.Current()
		// if userErr != nil {
		// 	log.Printf("Failed to get user information: %v", userErr)
		// 	return fmt.Sprintf("An error occurred while getting user information: %v", userErr)
		// }

		// packerBinaryPath = currentUser.HomeDir + "/kxascode-launcher/packer"
		packerBinaryPath = "./frontend/src/assets/packer/packer"
		if _, err := os.Stat(packerBinaryPath); os.IsNotExist(err) {
			if err := downloadPackerBinary(packerBinaryPath); err != nil {
				log.Printf("Failed to download Packer: %v", err)
				return fmt.Sprintf("An error occurred while downloading Packer: %v", err)
			}

			chmodCmd := exec.Command("chmod", "+x", packerBinaryPath)
			if chmodErr := chmodCmd.Run(); chmodErr != nil {
				log.Printf("Failed to set execute permissions: %v", chmodErr)
				return fmt.Sprintf("An error occurred while setting execute permissions: %v", chmodErr)
			}
		}
	default:
		log.Printf("Unsupported operating system: %v", runtime.GOOS)
		return fmt.Sprintf("Unsupported operating system: %v", runtime.GOOS)
	}

	// a.cmd = exec.Command(packerBinaryPath, "version")
	a.cmd = exec.Command(packerBinaryPath, "build", "-force",
		"-on-error=abort",
		"-only", "kx-main-virtualbox",
		"-var", "compute_engine_build=false",
		"-var", "memory=8192",
		"-var", "cpus=2",
		"-var", "video_memory=128",
		"-var", "hostname=kx-main",
		"-var", "domain=kx-as-code.local",
		"-var", "version=0.8.8",
		"-var", "kube_version=1.21.3-00",
		"-var", "vm_user=kx.hero",
		"-var", "vm_password=L3arnandshare",
		"-var", "git_source_url=https://github.com/Accenture/kx.as.code.git",
		"-var", "git_source_branch=main",
		"-var", "git_source_user=username",
		"-var", "git_source_token=token",
		"-var", "base_image_ssh_user=vagrant",
		"./frontend/src/assets/config/build/darwin-linux/kx-main-local-profiles.json")
	a.cmd.Stdout = outfile

	if err := a.cmd.Start(); err != nil {
		log.Printf("Failed to start command: %v", err)
		return fmt.Sprintf("An error occurred: %v", err)
	}

	go func() {
		log.Printf("Waiting for build to finish...")
		if waitErr := a.cmd.Wait(); waitErr != nil {
			log.Printf("Build finished with error: %v", waitErr)
		}

		// Close file after build has finished
		outfile.Close()
	}()

	return "Build executed successfully"
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

func downloadFile(url, destination string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to download: %s", resp.Status)
	}

	out, err := os.Create(destination)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	return err
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
