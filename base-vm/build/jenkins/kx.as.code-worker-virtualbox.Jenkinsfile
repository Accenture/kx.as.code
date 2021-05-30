node('packer') {
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
        packerOsFolder="windows"
    }
}

pipeline {

    agent { label "packer" }

    options {
        ansiColor('xterm')
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
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

    parameters {
        string(name: 'github_repo_url', defaultValue: "github.com/Accenture/kx.as.code.git", description: "Source Github repository")
        string(name: 'git_source_branch', defaultValue: "main", description: "Source Github branch to build from and clone inside VM")
        string(name: 'git_docs_branch', defaultValue: "main", description: "Docs Github branch to clone")
        string(name: 'git_techradar_branch', defaultValue: "main", description: "TechRadar Github branch to clone")
        string(name: 'kx_version', defaultValue: "0.6.7", description: "KX.AS.CODE Version")
        string(name: 'kx_vm_user', defaultValue: "kx.hero", description: "KX.AS.CODE VM user login")
        string(name: 'kx_vm_password', defaultValue: "L3arnandshare", description: "KX.AS.CODE VM user login password")
        string(name: 'kx_compute_engine_build', defaultValue: "false", description: "Needs to be true for AWS to avoid 'grub' changes")
        string(name: 'kx_hostname', defaultValue: "kx-worker", description: "KX.AS.CODE worker node hostname")
        string(name: 'kx_domain', defaultValue: "kx-as-code.local", description: "KX.AS.CODE local domain")
        string(name: 'base_image_ssh_user', defaultValue: "vagrant", description: "Default AMI SSH user")
        string(name: 'ssh_username', defaultValue: 'vagrant', description: 'SSH user used during packer build process')
    }

    stages {

        stage('Clone the repository'){
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: 'https://${github_repo_url}']]])
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
                        ${packerPath}/packer build -force -only kx.as.code-worker-virtualbox \
                        -var "compute_engine_build=${kx_compute_engine_build}" \
                        -var "memory=8192" \
                        -var "cpus=2" \
                        -var "video_memory=128" \
                        -var "host_data_directory=c:/Users/Patrick/KX_Share" \
                        -var "hostname=${kx_hostname}" \
                        -var "domain=${kx_domain}" \
                        -var "version=${kx_version}" \
                        -var "vm_user=${kx_vm_user}" \
                        -var "vm_password=${kx_vm_password}" \
                        -var "github_user=${GITHUB_USER}" \
                        -var "github_token=${GITHUB_TOKEN}" \
                        -var "git_source_branch=${GIT_SOURCE_BRANCH}" \
                        -var "git_docs_branch=${GIT_DOCS_BRANCH}" \
                        -var "git_techradar_branch=${GIT_TECHRADAR_BRANCH}" \
                        -var "ssh_username=${ssh_username}" \
                        -var "base_image_ssh_user=${base_image_ssh_user}" \
                        ./kx.as.code-worker-local-profiles.json
                        """
                    }
                }
            }
        }
    }
}