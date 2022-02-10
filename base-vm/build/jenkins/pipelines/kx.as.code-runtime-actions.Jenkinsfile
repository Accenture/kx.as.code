def functions
def kx_version
def kube_version

node('master') {
    dir(shared_workspace) {
        echo shared_workspace
        functions = load "${shared_workspace}/base-vm/build/jenkins/pipelines/shared-pipeline-functions.groovy"
        println(functions)
        (kx_version, kube_version) = functions.setBuildEnvironment()
    }
}

pipeline {

    agent {
        node {
            label "master"
            customWorkspace shared_workspace
        }
    }

    parameters {
        string(name: 'kx_main_version', defaultValue: '', description: '')
        string(name: 'kx_node_version', defaultValue: '', description: '')
        string(name: 'environment_prefix', defaultValue: '', description: '')
        string(name: 'dockerhub_email', defaultValue: '', description: '')
        string(name: 'profile', defaultValue: '', description: '')
        string(name: 'profile_path', defaultValue: '', description: '')
        string(name: 'vagrant_action', defaultValue: '', description: '')
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
        stage('Execute Vagrant Action'){
            steps {
                script {
                    sh """
                    export mainBoxVersion=${kx_main_version}
                    export nodeBoxVersion=${kx_node_version}
                    export environmentPrefix=${environment_prefix}
                    echo "Profile path: ${profile_path}"
                    echo "Vagrant action: ${vagrant_action}"
                    echo "Environment prefix: ${environment_prefix}"
                    echo "Current directory \$(pwd)"
                    cd profiles/vagrant-${profile}
                    VBoxManage list vms
                    vagrant ${vagrant_action} --provider ${profile}
                    VBoxManage list vms
                    """
                }
            }
        }
    }
}
