installDebianPackage() {

    local package=${1}

    if [[ -z "$(apt -qq list ${package} | grep installed)" ]]; then
        log_debug "Installing package \"${package}\""
        apt-get install -y ${package}
    else
        log_debug "${package} is already installed. Skipping"
    fi

}