package main

import (
	"archive/zip"
	"embed"
	"errors"
	"flag"
	"io"
	"log/slog"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path"
	"syscall"
	"text/template"

	"github.com/Accenture/kx.as.code/launcher/platform"
	"github.com/cli/browser"
)

var (
	cleanup    = flag.String("cleanup", "cleanup", "packer's --on-error argument")
	kxNodeType = flag.String("nodetype", "kx-main-virtualbox", "usage")
	kxMemory   = flag.String("memory", "4096MB", "usage")
	kxCPUs     = flag.String("cpus", "2", "amount of cores to be used")
	kxHostname = flag.String("hostname", "kx-main", "usage")
	kxDomain   = flag.String("domain", "kx-as-code.local", "usage")
	kxVersion  = flag.String("version", "0.8.16", "usage")
	vmUser     = flag.String("vmuser", "kx.hero", "usage")
	vmPassword = flag.String("vmpassword", "L3earnandshare", "usage")
)

//go:embed templates/*
var content embed.FS

func main() {
	flag.Parse()
	f, err := os.OpenFile("launcher.log", os.O_CREATE|os.O_APPEND|os.O_RDWR, 0o666)
	if err != nil {
		slog.Error("Could not open log file", "err", err)
	}
	logger := slog.New(slog.NewTextHandler(io.MultiWriter(os.Stdout, f), nil))
	slog.SetDefault(logger)

	go findPacker()

	// Parse templates during server startup
	indexTpl, err := template.ParseFS(content, "templates/index.html", "templates/header.html")
	if err != nil {
		slog.Error("Could not parse template", "err", err)
		os.Exit(1)
	}
	submitTpl, err := template.ParseFS(content, "templates/submit.html", "templates/header.html")
	if err != nil {
		slog.Error("Could not parse template", "err", err)
		os.Exit(1)
	}

	// Requests to "/"
	http.HandleFunc("/", serveIndex(indexTpl))
	// POST "/submit"
	http.HandleFunc("/submit", submitHandler(submitTpl))

	// Start the server
	port := "8080"
	slog.Info("Starting server at http://127.0.0.1:" + port)
	browser.Stdout, browser.Stderr = io.Discard, io.Discard
	err = browser.OpenURL("http://127.0.0.1:" + port)
	if err != nil {
		slog.Error("Could not open browser", "err", err)
	}
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		slog.Error("Could not start server", "err", err)
		os.Exit(1)
	}
}

// Indirection of returning an http Handler to enable passing parameters
func serveIndex(tpl *template.Template) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := tpl.Execute(w, nil)
		if err != nil {
			slog.Error("Templating error", "err", err)
		}
	}
}

// submitHandler validates the request method and passes the sigterm channel parameter on to the child proc
func submitHandler(tpl *template.Template) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
			return
		}
		err := tpl.Execute(w, nil)
		if err != nil {
			slog.Error("Templating error", "err", err)
		}
		slog.Info("Launching Packer.")
		_, bin := platform.Packer() // TODO: Use existing binary, if existing
		err = execPacker(bin)
		if err != nil {
			slog.Error("Packer failed to launch.", "err", err)
		}
	}
}

func findPacker() {
	_, err := exec.LookPath("packer")
	if err != nil {
		slog.Info("Couldn't find packer", "err", err)

		l, _ := platform.Packer()
		const dst = "packer.zip"

		slog.Info("Fetching from remote", "url", l)
		if err := fetch(l, dst); err != nil {
			slog.Error("Could not fetch", "url", l, "err", err)
			// TODO: Offer manual input as alternative
			os.Exit(1)
		}
		if err := unzip(dst, "tools"); err != nil {
			slog.Error("Could not unzip"+dst, "err", err)
			os.Exit(1)
		}
	}
}

func fetch(url string, dst string) error {
	resp, err := http.Get(url)
	if err != nil {
		slog.Error("OS error", "err", err)
		return err
	}
	defer resp.Body.Close()

	out, err := os.Create(dst)
	if err != nil {
		slog.Error("OS error", "err", err)
		return err
	}
	defer out.Close()

	if _, err := io.Copy(out, resp.Body); err != nil {
		return err
	}
	return nil
}

func unzip(file string, out string) error {
	slog.Info("Unpacking Packer.")
	reader, err := zip.OpenReader(file)
	if err != nil {
		slog.Error("OS error", "err", err)
		return err
	}
	defer reader.Close()

	for _, file := range reader.File {
		src, err := file.Open()
		if err != nil {
			slog.Error("OS error", "err", err)
			return err
		}
		defer src.Close()

		relname := path.Join(out, file.Name)
		dir := path.Dir(relname)
		os.MkdirAll(dir, 0o777)
		dst, err := os.Create(relname)
		if err != nil {
			slog.Error("OS error", "err", err)
			return err
		}
		defer dst.Close()
		io.Copy(dst, src)

		err = os.Chmod(dst.Name(), 0o755)
		if err != nil {
			slog.Error("OS error", "err", err)
			return err
		}
	}
	return nil
}

func execPacker(bin string) error {
	sig := make(chan os.Signal, 2) // buffer should be equal to number of signals that can be sent
	signal.Notify(sig, os.Interrupt, syscall.SIGTERM)
	cmd := exec.Command("./tools/"+bin, "build", "-force", "-on-error="+*cleanup, "-only", *kxNodeType, "-var", "compute_engine_build=false", "-var", "memory="+*kxMemory, "-var", "cpus="+*kxCPUs, "-var", "video_memory=128", "-var", "hostname="+*kxHostname, "-var", "domain="+*kxDomain, "-var", "version="+*kxVersion, "-var", "kube_version=1.27.4-00", "-var", "vm_user="+*vmUser, "-var", "vm_password="+*vmPassword, "-var", "git_source_url=https://github.com/Accenture/kx.as.code.git", "-var", "git_source_branch=main", "-var", "git_source_user=", "-var", "git_source_token=", "-var", "base_image_ssh_user=vagrant", "./kx-main-local-profiles.json")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		slog.Error("OS error", "err", err)
		return err
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		slog.Error("OS error", "err", err)
		return err
	}
	err = cmd.Start()
	if err != nil {
		return errors.New(err.Error())
	}
	childLog, err := os.OpenFile("packer.log", os.O_CREATE|os.O_APPEND|os.O_RDWR, 0o666)
	if err != nil {
		slog.Error("OS error", "err", err)
		return err
	}

	go func() {
		<-sig
		slog.Info("Terminating Packer")
		platform.Terminate(cmd)
		os.Exit(127)
	}()
	// copy packer output to terminal and log file
	go io.Copy(io.MultiWriter(os.Stdout, childLog), stdout)
	go io.Copy(io.MultiWriter(os.Stderr, childLog), stderr)
	return nil
}
