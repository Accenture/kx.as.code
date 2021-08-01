node('local') {
    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
        vmWareDiskUtilityPath="/System/Volumes/Data/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
        jqDownloadPath="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
        vmWareDiskUtilityPath=""
        jqDownloadPath="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
    } else {
        echo "Running on Windows"
        os="windows"
        vmWareDiskUtilityPath="c:/Program Files (x86)/VMware/VMware Workstation/vmware-vdiskmanager.exe"
        jqDownloadPath="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe"
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

        stage('Clone the repository'){
            steps {
                script {
                    dir(shared_workspace) {
                        checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GIT_KX.AS.CODE_SOURCE', url: '${git_source_url}']]])
                    }
                }
            }
        }

        stage('Execute Vagrant Action'){
            steps {
                script {
                    dir(shared_workspace) {
                        sh """
                        if [[ ! -f ./jq* ]]; then
                            curl -o jq ${jqDownloadPath}
                        fi
                        export kx_version=\$(cat version.json | ./jq -r '.version')
                        echo \${kx_version}
                        export kxMainBoxLocation=${kx_main_box_location}
                        export kxWorkerBoxLocation=${kx_worker_box_location}
                        echo \${kxMainBoxLocation}
                        echo \${kxWorkerBoxLocation}
                        if [[ -f kx.as.code_main-ip-address ]]; then
                            rm -f kx.as.code_main-ip-address
                        fi
                        cd profiles/vagrant-vmware-desktop-demo1
                        vagrant up --provider vmware_desktop
                        """
                    }
                }
            }
        }
    }
}