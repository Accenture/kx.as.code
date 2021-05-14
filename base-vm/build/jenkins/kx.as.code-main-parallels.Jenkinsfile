import org.apache.commons.lang.SystemUtils

if (SystemUtils.IS_OS_UNIX || SystemUtils.IS_OS_MAC) {
    os="darwin-linux"
} else {
    os="windows"
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

    environment {
        RED="\033[31m"
        GREEN="\033[32m"
        ORANGE="\033[33m"
        BLUE="\033[34m"
        NC="\033[0m" // No Color
    }

    parameters {
        string(name: 'git_repo_url', defaultValue: "github.com/Accenture/kx.as.code.git", description: "Source Github repository")
        string(name: 'git_source_branch', defaultValue: "feature/multi-user-enablement", description: "Source Github branch to build from and clone inside VM")
        string(name: 'git_docs_branch', defaultValue: "master", description: "Docs Github branch to clone")
        string(name: 'git_techradar_branch', defaultValue: "master", description: "TechRadar Github branch to clone")
        string(name: 'kx_version', defaultValue: "0.6.7", description: "KX.AS.CODE Version")
        string(name: 'kx_vm_user', defaultValue: "kx.hero", description: "KX.AS.CODE VM user login")
        string(name: 'kx_vm_password', defaultValue: "L3arnandshare", description: "KX.AS.CODE VM user login password")
        string(name: 'kx_compute_engine_build', defaultValue: "false", description: "Needs to be true for AWS to avoid 'grub' changes")
        string(name: 'kx_hostname', defaultValue: "kx-main", description: "KX.AS.CODE main node hostname")
        string(name: 'kx_domain', defaultValue: "kx-as-code.local", description: "KX.AS.CODE local domain")
        string(name: 'base_image_ssh_user', defaultValue: "vagrant", description: "Default VM SSH user")
        string(name: 'ssh_username', defaultValue: 'vagrant', description: 'SSH user used during packer build process')
    }

    stages {

        stage('Clone the repository'){
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CleanBeforeCheckout']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: 'https://${git_repo_url}']]])
                }
            }
        }

        stage('Build the OVA/BOX'){
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'GITHUB_KX.AS.CODE', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                        sh """
                        cd base-vm/build/packer/${os}
                        packer build -force -only kx.as.code-main-parallels \
                        -var "compute_engine_build=${kx_compute_engine_build}" \
                        -var "memory=8192" \
                        -var "cpus=2" \
                        -var "video_memory=128" \
                        -var "hostname=${kx_hostname}" \
                        -var "domain=${kx_domain}" \
                        -var "version=${kx_version}" \
                        -var "vm_user=${kx_vm_user}" \
                        -var "vm_password=${kx_vm_password}" \
                        -var "github_user=${GITHUB_USER}" \
                        -var "github_token=${GITHUB_TOKEN}" \
                        -var "git_source_branch=${git_source_branch}" \
                        -var "git_docs_branch=${git_docs_branch}" \
                        -var "git_techradar_branch=${git_techradar_branch}" \
                        -var "ssh_username=${ssh_username}" \
                        -var "base_image_ssh_user=${base_image_ssh_user}" \
                        ./kx.as.code-main-local-profiles.json
                        """
                    }
                }
            }
        }
    }
}