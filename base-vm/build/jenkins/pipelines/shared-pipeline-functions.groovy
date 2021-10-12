def setBuildEnvironment() {
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
            gitDiff = sh (script: '''
                header=\$(echo '<!DOCTYPE html PUBLIC"-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head><style> table { font-family: mono; font-size: 10px; border-style: solid;  border-width: 0px; border-color: #8ebf42; background-color: #ffffff;} tr { padding-bottom: 1em; solid black;} td {  vertical-align: top; text-align: left; padding: 3px; border:0px solid #1c87c9; </style><body><table>')
                gitLog=\$(git log -n 10 --oneline --no-merges --stat --pretty='format:%C(auto)%<(15,trunc)%h ### %<(15,trunc)%ar ### %<(20,trunc)%cn ###  %C(Cyan)%<(100,trunc)%s%C(reset)' | sed 's/</\\&lt\\;/g' | sed 's/>/\\&gt\\;/g' | rev | sed -e ':b; /###/! s/^\\([^|]*\\)*\\-/\\1§/; tb;' | rev | sed 's/§/<span style="color: red">-<\\/span>/g' | rev | sed -e ':b; /###/! s/^\\([^|]*\\)*+/\\1§/; tb;' | rev | sed 's/§/<span style="color: green">-<\\/span>/g' | sed '/###/! s/^/<td colspan="4">/g' |  sed '/###/ s/^/<tr><td style="background-color: lightgrey; color: blue">/g' | sed 's/###/<\\/td><td style="background-color: lightgrey; color: blue">/g' | sed 's/$/<\\/td><\\/tr>/g')  
                footer=\$(echo "</table></body></html>")  
                echo "\${header} \${gitLog} \${footer}"
            ''', returnStdout: true).trim()
            currentBuild.description = '<span style=font-family: monospace;">' + gitDiff + '</span>'
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