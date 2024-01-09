//go:build windows

package platform

import (
	"log/slog"
	"os/exec"

	"github.com/iwdgo/sigintwindows"
)

func Packer() (string, string) {
	const (
		url = "https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_windows_amd64.zip"
		app = "packer.exe"
	)
	return url, app
}

func Terminate(cmd *exec.Cmd) {
	if err := sigintwindows.SendCtrlBreak(cmd.Process.Pid); err != nil {
		slog.Error("Could not terminate child", "err", err)
	}
	if err := cmd.Wait(); err != nil {
		slog.Info("Non-zero exit code by Packer command, includes build cancels", slog.String("err", err.Error()))
	}
}
