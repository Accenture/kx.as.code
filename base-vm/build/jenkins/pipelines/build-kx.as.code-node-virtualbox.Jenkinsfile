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

    tools {
        'biz.neustar.jenkins.plugins.packer.PackerInstallation' "packer-${os}"
    }

    environment {
        RED="\033[31m"
        GREEN="\033[32m"
        ORANGE="\033[33m"
        BLUE="\033[34m"
        NC="\033[0m" // No Color
    }

    stages {
        stage('Build the OVA/BOX'){
            steps {
                script {
                    def packerPath = tool "packer-${os}"
                    if ( "${os}" == "windows" ) {
                        packerPath = packerPath.replaceAll("\\\\","/")
                    }
                    sh """
                    cd base-vm/build/packer/${packerOsFolder}
                    ${packerPath}/packer build -force -only kx.as.code-node-virtualbox \
                    -var "compute_engine_build=${vagrant_compute_engine_build}" \
                    -var "memory=8192" \
                    -var "cpus=2" \
                    -var "video_memory=128" \
                    -var "hostname=${kx_node_hostname}" \
                    -var "domain=${kx_domain}" \
                    -var "version=\${kx_version}" \
                    -var "kube_version=\${kube_version}" \
                    -var "vm_user=${kx_vm_user}" \
                    -var "vm_password=${kx_vm_password}" \
                    -var "base_image_ssh_user=${vagrant_ssh_username}" \
                    ./kx.as.code-node-local-profiles.json
                    """
                }
            }
        }
    }
}