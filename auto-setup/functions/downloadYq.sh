downloadYq() {

    # There are two version of yq. This one is for the pretty print option - /usr/bin/yq. 
    # There is another yq which wraps jq and is installed to /usr/local/bin/yq (default on path)
    local yqVersion="v4.2.0"
    local yqBinary="yq_linux_amd64"
    local yqChecksum="58e0e38d197eafdd03572bf21c302c585cc802fd099c26938189356717833962"

    # Install yq if not present
    if [[ ! -f /usr/local/bin/yq ]]; then
        downloadFile "https://github.com/mikefarah/yq/releases/download/${yqVersion}/${yqBinary}.tar.gz" \
            "${yqChecksum}" \
            "${installationWorkspace}/${yqBinary}.tar.gz"
        tar xvzf ${installationWorkspace}/${yqBinary}.tar.gz
        mv ${installationWorkspace}/${yqBinary} /usr/bin/yq
        chmod +x /usr/bin/yq
    fi

}