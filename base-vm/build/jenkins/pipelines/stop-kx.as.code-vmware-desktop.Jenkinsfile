node('local') {
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
        os="windows"
        vmWareDiskUtilityPath="c:/Program Files (x86)/VMware/VMware Workstation/vmware-vdiskmanager.exe"
        packerOsFolder="windows"
    }
}

pipeline {

    agent {
        node {
            label "local"
            customWorkspace "${shared_workspace}"
        }
    }

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
        stage('Set Build Environment') {
          steps {
            script {
                functions = load "base-vm/build/jenkins/pipelines/shared-pipeline-functions.groovy"
                println(functions)
                (kx_version, kube_version) = functions.setBuildEnvironment()
            }
          }
        }
        stage('Execute Vagrant Action'){
            steps {
                script {
                    sh """
                    cd profiles/vagrant-vmware-desktop
                    if [ -z \$(vagrant plugin list | grep "vagrant-vmware-desktop" ) ]; then
                        vagrant plugin install vagrant-vmware-desktop
                    fi
                    vagrant halt
                    """
                }
            }
        }
    }
}