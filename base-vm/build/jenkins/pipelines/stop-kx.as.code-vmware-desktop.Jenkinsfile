def functions
def kx_version
def kube_version

node('local') {
    dir(shared_workspace) {
        functions = load "base-vm/build/jenkins/pipelines/shared-pipeline-functions.groovy"
        println(functions)
        (kx_version, kube_version) = functions.setBuildEnvironment()
    }
}

pipeline {

    agent {
        node {
            label "local"
            customWorkspace shared_workspace
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