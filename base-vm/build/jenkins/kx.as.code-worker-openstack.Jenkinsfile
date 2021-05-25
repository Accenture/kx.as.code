import org.apache.commons.lang.SystemUtils

if (SystemUtils.IS_OS_UNIX || SystemUtils.IS_OS_MAC) {
    os="darwin-linux"
} else {
    os="windows"
}

pipeline {

    agent { label "master" }

    options {
        ansiColor('xterm')
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 3, unit: 'HOURS')
    }

    tools {
        'biz.neustar.jenkins.plugins.packer.PackerInstallation' 'packer-linux-1.6.6'
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
        string(name: 'github_source_branch', defaultValue: "feature/multi-user-enablement", description: "Source Github branch to build from")
        string(name: 'kx_version', defaultValue: "0.6.7", description: "KX.AS.CODE Version")
        string(name: 'kx_vm_user', defaultValue: "kx.hero", description: "KX.AS.CODE VM user login")
        string(name: 'kx_vm_password', defaultValue: "L3arnandshare", description: "KX.AS.CODE VM user login password")
        string(name: 'kx_compute_engine_build', defaultValue: "true", description: "Needs to be true for AWS to avoid 'grub' changes")
        string(name: 'kx_hostname', defaultValue: "kx-worker", description: "KX.AS.CODE main node hostname")
        string(name: 'kx_domain', defaultValue: "kx-as-code.local", description: "KX.AS.CODE local domain")
        string(name: 'base_image_ssh_user', defaultValue: "debian", description: "Default AMI SSH user")
        string(name: 'ssh_username', defaultValue: 'debian', description: 'SSH user used during packer build process')
    }

    stages {

        stage('Clone the repository'){
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$github_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CleanBeforeCheckout']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: 'https://${github_repo_url}']]])
                }
            }
        }

        stage('Build the AMI'){
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'GITHUB_KX.AS.CODE', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                  withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "AWS_PACKER_ACCESS",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                  ]]) {
                       def packerPath = tool 'packer-linux-1.6.6'
                        sh """
                        cd base-vm/build/packer/${os}
                        PACKER_LOG=1 ${packerPath}/packer build -force -only kx.as.code-worker-aws-ami \
                            -var "compute_engine_build=${kx_compute_engine_build}" \
                            -var "hostname=${kx_hostname}" \
                            -var "domain=${kx_domain}" \
                            -var "version=${kx_version}" \
                            -var "vm_user=${kx_vm_user}" \
                            -var "vm_password=${kx_vm_password}" \
                            -var "github_user=${GITHUB_USER}" \
                            -var "github_token=${GITHUB_TOKEN}" \
                            -var "ssh_username=${ssh_username}" \
                            -var "base_image_ssh_user=${base_image_ssh_user}" \
                            ./kx.as.code-worker-cloud-profiles.json
                        """
                        }
                    }
                }
            }
        }
    }
}