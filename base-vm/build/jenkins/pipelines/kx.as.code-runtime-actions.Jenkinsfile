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
        string(name: 'num_kx_main_nodes', defaultValue: '', description: '')
        string(name: 'num_kx_worker_nodes', defaultValue: '', description: '')
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
                    dir(shared_workspace) {
                        sh """
                        export mainBoxVersion=${kx_main_version}
                        export nodeBoxVersion=${kx_node_version}
                        echo "Profile path: ${profile_path}"
                        echo "Vagrant action: ${vagrant_action}"
                        echo "Current directory \$(pwd)"
                        cd profiles/vagrant-${profile}
                        VBoxManage list vms
                        if [ "${vagrant_action}" == "destroy" ]; then
                            vagrant destroy --force --no-tty
                        elif [ "${vagrant_action}" == "up" ]; then
                            vagrant up --no-tty
                            for i in \$(seq 1 \$(($num_kx_main_nodes - 1)));
                            do
                                vagrant up --no-tty kx-main\${i}
                            done
                            for i in \$(seq 1 ${num_kx_worker_nodes});
                            do
                                vagrant up --no-tty kx-worker\${i}
                            done
                        else
                            vagrant ${vagrant_action} --no-tty
                        fi
                        VBoxManage list vms
                        """
                    }
                }
            }
        }
    }
}
