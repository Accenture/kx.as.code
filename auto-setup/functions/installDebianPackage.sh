installDebianPackage() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    local package=${1}

    if [[ -z "$(apt -qq list ${package} | grep installed)" ]]; then
        log_debug "Installing package \"${package}\""
        apt-get install -y ${package}
    else
        log_debug "${package} is already installed. Skipping"
    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}