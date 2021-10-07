node('local') {
    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_DARWIN_DOWNLOAD_URL}"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_LINUX_DOWNLOAD_URL}"
    } else {
        echo "Running on Windows"
        os="windows"
        jqDownloadPath="${JQ_WINDOWS_DOWNLOAD_URL}"
        packerOsFolder="windows"
    }
}

pipeline {

    agent { label "local" }

    options {
        ansiColor('xterm')
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 3, unit: 'HOURS')
    }

    environment {
        RED="\033[31m"
        GREEN="\033[32m"
        ORANGE="\033[33m"
        BLUE="\033[34m"
        NC="\033[0m" // No Color
    }

    stages {
        stage('Execute Vagrant Action'){
            steps {
                script {
                    dir(shared_workspace) {
                        withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_ACCOUNT', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUsername')]) {
                            sh """
                            if [ ! -f ./jq* ]; then
                                curl -L -o jq ${jqDownloadPath}
                                chmod +x ./jq
                            fi
                            export kx_version=\$(cat versions.json | ./jq -r '.kxascode')
                            echo \${kx_version}
                            export kxMainBoxLocation=${kx_main_box_location}
                            export kxNodeBoxLocation=${kx_node_box_location}
                            export dockerHubEmail=${dockerhub_email}
                            echo \${kxMainBoxLocation}
                            echo \${kxNodeBoxLocation}
                            echo \${dockerHubEmail}
                            cd profiles/vagrant-parallels
                            if [ -f kx.as.code_main-ip-address ]; then
                                rm -f kx.as.code_main-ip-address
                            fi
                            vagrant up --provider parallels
                            """
                        }
                    }
                }
            }
        }
    }
}