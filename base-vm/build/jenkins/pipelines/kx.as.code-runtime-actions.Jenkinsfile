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
                    pwd
                    cd profiles/vagrant-$profile
                    VBoxManage list vms
                    #vagrant halt
                    #vagrant destroy -f
                    #VBoxManage list vms
                    echo "Profile path: $profile_path"
                    """
                }
            }
        }
    }
}