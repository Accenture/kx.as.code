def setBuildEnvironment() {
    sh """
    if [ ! -f ./jq* ]; then
        curl -L -o jq ${jqDownloadPath}
        chmod +x ./jq
    fi
    """
    sh "pwd; ls -l"
    kx_version = sh (script: "cat versions.json | ./jq -r '.kxascode'", returnStdout: true).trim()
    println ("Current KX.AS.CODE Version: ${kx_version}")
    kube_version = sh (script: "cat versions.json | ./jq -r '.kubernetes'", returnStdout: true).trim()
    println ("Current Kubernetes Version: ${kube_version}")
    gitShortCommitId = sh (script: "git rev-parse --short HEAD", returnStdout: true).trim()
    try {
        if ( currentBuild.number > 1 ) {
            currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${gitShortCommitId}"
            println(currentBuild.displayName)
            def lastCompletedBuildName = Jenkins.instance.getItemByFullName(env.JOB_NAME).lastCompletedBuild.displayName
            println(lastCompletedBuildName)
            def (oldBuildNumber, oldKxVersion, oldKubeVersion, oldGitShortCommitId) = lastCompletedBuildName.split('_')
            println(oldBuildNumber)
            println ("Previous KX.AS.CODE Version: ${oldKxVersion}")
            if ( oldKxVersion != "v${kx_version}" ) {
                println("KX.AS.CODE version has changed since the last build, ${oldKxVersion} --> v${kx_version}")
            } else {
                println("KX.AS.CODE version has not changed since the last build - v${kx_version}")
            }
            println(oldKubeVersion)
            println ("Previous Kubernetes Version: ${oldKubeVersion}")
            if (oldKubeVersion !=  "v${kube_version}") {
                println("Kube version has changed since the last build, ${oldKubeVersion} --> v${kube_version}")
            } else {
                println("Kube version has not changed since the last build - v${kube_version}")
            }
            println(oldGitShortCommitId)
            //sh "git diff ${oldGitShortCommitId}..${gitShortCommitId}"
            gitDiff = sh (script: "git log ${oldGitShortCommitId}..${gitShortCommitId} --oneline --graph --decorate --no-merges", returnStdout: true).trim()
            currentBuild.description = gitDiff
        } else {
            currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${gitShortCommitId}"
        }
    } catch(Exception e) {
        // Do not fail the build because there was an error setting the build name
        println("Exception: ${e}")
    }
    return [ "${kx_version}", "${kube_version}" ]
}

return this