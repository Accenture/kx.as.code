node('packer') {
    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
        vmWareDiskUtilityPath="/System/Volumes/Data/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
        vmWareDiskUtilityPath=""
    } else {
        echo "Running on Windows"
        vmWareDiskUtilityPath="c:/Program Files (x86)/VMware/VMware Workstation/vmware-vdiskmanager.exe"
        packerOsFolder="windows"
    }
}

pipeline {

    agent { label "packer" }

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

    parameters {
        choice(choices: ['up', 'halt', 'resume', 'suspend', 'destroy'], name: 'vagrant_action', description: 'Selection vagrant action to execute')
        string(name: 'git_repo_url', defaultValue: "github.com/Accenture/kx.as.code.git", description: "Source Github repository")
        string(name: 'git_source_branch', defaultValue: "main", description: "Source Github branch to build from and clone inside VM")

    }

    stages {

        stage('Clone the repository'){
            when {
                allOf {
                  expression{vagrant_action == 'up'}
                }
            }
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: 'https://${git_repo_url}']]])
                }
            }
        }

        stage('Execute Vagrant Action'){
            steps {
                script {
                    sh """
                    env
                    cd profiles/vagrant-vmware-desktop-demo1
                    ls -altR
                    if [[ "${vagrant_action}" == "destroy" ]]; then
                        vagrant halt
                        vagrant ${vagrant_action} -f
                    else
                        vagrant ${vagrant_action}
                    fi
                    """
                }
            }
        }
    }
}