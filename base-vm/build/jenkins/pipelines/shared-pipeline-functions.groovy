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
        if ( currentBuild.displayName > 1 ) {
            currentBuild.displayName = "#${currentBuild.number}-v${kx_version}-v${kube_version}-${gitShortCommitId}"
            println(currentBuild.displayName)
            def lastSuccessBuildName = Jenkins.instance.getItem(env.JOB_NAME).lastSuccessfulBuild.displayName
            println(lastSuccessBuildName)
            def (oldBuildNumber, oldKxVersion, oldKubeVersion, oldGitShortCommitId) = lastSuccessBuildName.split('-')
            println(oldBuildNumber)
            println(oldKxVersion)
            if ( oldKxVersion != kx_version ) {
                println("KX.AS.CODE version has changed since the last build, ${oldKxVersion} --> ${kx_version}")
            } else {
                println("KX.AS.CODE version has not changed since the last build - ${kx_version}")
            }
            println(oldKubeVersion)
            if (oldKubeVersion !=  kube_version) {
                println("Kube version has changed since the last build, ${oldKubeVersion} --> ${kube_version}")
            } else {
                println("Kube version has not changed since the last build - ${kube_version}")
            }
            println(oldGitShortCommitId)
            sh "git diff ${oldGitShortCommitId}..${gitShortCommitId}"
        } else {
            currentBuild.displayName = "#${currentBuild.number}-v${kx_version}-v${kube_version}-${gitShortCommitId}"
        }
    } catch(Exception e) {
        println("Exception: ${e}")
        throw e
    }
}

return this