node('local') {
    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
    } else {
        echo "Running on Windows"
        os="windows"
        packerOsFolder="windows"
    }
}

pipeline {

    agent { label "local" }

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

        stage('Clone the repository'){
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: 'https://${git_repo_url}']]])
                }
            }
        }

        stage('Build the OVA/BOX'){
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'GITHUB_KX.AS.CODE', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                        def packerPath = tool "packer-${os}"
                        sh """
                        cd base-vm/build/packer/${packerOsFolder}
                        ${packerPath}/packer build -force -only kx.as.code-main-parallels \
                        -var "compute_engine_build=${vagrant_compute_engine_build}" \
                        -var "memory=8192" \
                        -var "cpus=2" \
                        -var "video_memory=128" \
                        -var "hostname=${kx_main_hostname}" \
                        -var "domain=${kx_domain}" \
                        -var "version=${kx_version}" \
                        -var "vm_user=${kx_vm_user}" \
                        -var "vm_password=${kx_vm_password}" \
                        -var "github_user=${GITHUB_USER}" \
                        -var "github_token=${GITHUB_TOKEN}" \
                        -var "git_source_branch=${git_source_branch}" \
                        -var "git_docs_branch=${git_docs_branch}" \
                        -var "git_techradar_branch=${git_techradar_branch}" \
                        -var "base_image_ssh_user=${vagrant_ssh_username}" \
                        ./kx.as.code-main-local-profiles.json
                        """
                    }
                }
            }
        }
    }
}