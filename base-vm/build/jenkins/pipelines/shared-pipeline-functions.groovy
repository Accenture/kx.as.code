def setBuildEnvironment() {

    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_DARWIN_DOWNLOAD_URL}"
        vmWareDiskUtilityPath="/System/Volumes/Data/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_LINUX_DOWNLOAD_URL}"
        vmWareDiskUtilityPath=""
    } else {
        echo "Running on Windows"
        os="windows"
        packerOsFolder="windows"
        jqDownloadPath="${JQ_WINDOWS_DOWNLOAD_URL}"
        vmWareDiskUtilityPath="c:/Program Files (x86)/VMware/VMware Workstation/vmware-vdiskmanager.exe"
    }

    sh """
    if [ ! -f ./jq* ]; then
        curl -L -o jq ${jqDownloadPath}
        chmod +x ./jq
    fi
    """

    kx_version = sh (script: "cat versions.json | ./jq -r '.kxascode'", returnStdout: true).trim()
    kube_version = sh (script: "cat versions.json | ./jq -r '.kubernetes'", returnStdout: true).trim()
    gitShortCommitId = sh (script: "git rev-parse --short HEAD", returnStdout: true).trim()
    try {
        if ( currentBuild.number > 1 ) {
            currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${gitShortCommitId}"
            def lastCompletedBuildName = Jenkins.instance.getItemByFullName(env.JOB_NAME).lastCompletedBuild.displayName
            def (oldBuildNumber, oldKxVersion, oldKubeVersion, oldGitShortCommitId) = lastCompletedBuildName.split('_')
            if ( oldKxVersion != "v${kx_version}" ) {
                println("KX.AS.CODE version has changed since the last build, ${oldKxVersion} --> v${kx_version}")
            } else {
                println("KX.AS.CODE version has not changed since the last build - v${kx_version}")
            }
            if (oldKubeVersion !=  "v${kube_version}") {
                println("Kube version has changed since the last build, ${oldKubeVersion} --> v${kube_version}")
            } else {
                println("Kube version has not changed since the last build - v${kube_version}")
            }
            if ( os == "windows" ) {
                println("Getting Git-Log on ${os}")
                gitDiff = sh(script: """  
                         git log ${oldGitShortCommitId}..${gitShortCommitId} --oneline --no-merges --stat --pretty='format:<a style=\"color: #ff8c00\" href=\"\$(echo '${git_source_url}' | sed \'s/\\.git//g\')/commit/%h\">%h%<(15,trunc)</a> ### %<(15,trunc)%ar ### %<(20,trunc)%cn ### <span style=\"color: green\"> %<(100,trunc)%s </span>' | sed 's/<br>/\\&lt\\;br\\&gt\\;/g' | sed 's/<p>/\\&lt\\;p\\&gt\\;/g' | sed 's/§/<span style=\"color: red\">-<\\/span>/g' | sed 's/\$/<br>/g' | sed 's/§/<span style=\"color: green\">-<\\/span>/g' | sed 's/###/|/g'
                    """, returnStdout: true).trim()
            } else {
                println("Getting Git-Log on ${os}")
                gitDiff = sh(script: '''    
                         git log ${oldGitShortCommitId}..${gitShortCommitId} --oneline --no-merges --stat --pretty='format:<a style="color: #ff8c00" href="${git_source_url}/commit/%h">%h%<(15,trunc)</a> ### %<(15,trunc)%ar ### %<(20,trunc)%cn ### <span style="color: green"> %<(100,trunc)%s </span>' | sed 's/<br>/\\\\&lt\\\\;br\\\\&gt\\\\;/g' | sed 's/<p>/\\\\&lt\\\\;p\\\\&gt\\\\;/g' | rev | sed -e ':b; /###/! s/^\\\\([^|]*\\\\)*\\\\-/\\\\1§/; tb;' | rev | sed 's/§/<span style="color: red">-<\\\\/span>/g' | rev | sed -e ':b; /###/! s/^\\\\([^|]*\\\\)*+/\\\\1§/; tb;' | rev | sed 's/\\$/<br>/g' | sed 's/§/<span style="color: green">-<\\\\/span>/g' | sed 's/###/|/g'
                    ''', returnStdout: true).trim()
            }
            header = '<!DOCTYPE html PUBLIC"-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head><div style="font-family:monospace,Courier;font-size:12px">'
            footer = "</div></html>"
            htmlBuildDescription = header + gitDiff + footer
            println(htmlBuildDescription)
            currentBuild.description = htmlBuildDescription
        } else {
            currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${gitShortCommitId}"
        }
    } catch(Exception e) {
        // Do not fail the build because there was an error setting the build name
        println("Exception: ${e}")
    }
    return [ kx_version, kube_version ]
}

return this