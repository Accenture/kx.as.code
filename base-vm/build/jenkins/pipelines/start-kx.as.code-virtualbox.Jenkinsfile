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
        stage('Execute Vagrant Action'){
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_ACCOUNT', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUsername')]) {
                        sh """
                        if [ ! -f ./jq* ]; then
                            curl -L -o jq ${jqDownloadPath}
                            chmod +x ./jq
                        fi
                        export kxMainBoxLocation=${kx_main_box_location}
                        export kxNodeBoxLocation=${kx_node_box_location}
                        export dockerHubEmail=${dockerhub_email}
                        echo \${kxMainBoxLocation}
                        echo \${kxNodeBoxLocation}
                        echo \${dockerHubEmail}
                        cd profiles/vagrant-virtualbox
                        if [ -f kx.as.code_main-ip-address ]; then
                            rm -f kx.as.code_main-ip-address
                        fi
                        vagrant up --provider virtualbox
                        VBoxManage list vms
                        """
                    }
                }
            }
        }
    }
}