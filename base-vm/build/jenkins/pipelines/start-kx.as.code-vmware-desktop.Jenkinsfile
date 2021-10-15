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
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 3, unit: 'HOURS')
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
                    withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_ACCOUNT', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUsername')]) {
                        sh """
                        if [ -z '\$(vagrant plugin list --machine-readable | grep "vagrant-vmware-desktop")' ]; then
                            vagrant plugin install vagrant-vmware-desktop
                        fi
                        if [ -f kx.as.code_main-ip-address ]; then
                            rm -f kx.as.code_main-ip-address
                        fi
                        cd profiles/vagrant-vmware-desktop
                        vagrant up --provider vmware_desktop
                        """
                    }
                }
            }
        }
    }
}
