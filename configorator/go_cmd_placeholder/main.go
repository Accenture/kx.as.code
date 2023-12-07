package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	directory := "../../base-vm/templates"

	if err := os.Chdir(directory); err != nil {
		fmt.Println("Error changing directory:", err)
		return
	}

	cmd := exec.Command("vagrant", "up")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	err := cmd.Run()
	if err != nil {
		fmt.Println("Error running 'vagrant up':", err)
		return
	}

	fmt.Println("Vagrant up completed successfully.")
}
