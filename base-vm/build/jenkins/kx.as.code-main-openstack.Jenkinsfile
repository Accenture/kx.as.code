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
        'biz.neustar.jenkins.plugins.packer.PackerInstallation' 'packer-linux-1.7.2'
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
        string(name: 'git_source_branch', defaultValue: "main", description: "Source Github branch to build from and clone inside VM")
        string(name: 'git_docs_branch', defaultValue: "main", description: "Docs Github branch to clone")
        string(name: 'git_techradar_branch', defaultValue: "main", description: "TechRadar Github branch to clone")
        string(name: 'kx_version', defaultValue: "0.6.7", description: "KX.AS.CODE Version")
        string(name: 'kx_vm_user', defaultValue: "kx.hero", description: "KX.AS.CODE VM user login")
        string(name: 'kx_vm_password', defaultValue: "L3arnandshare", description: "KX.AS.CODE VM user login password")
        string(name: 'kx_compute_engine_build', defaultValue: "true", description: "Needs to be true for AWS to avoid 'grub' changes")
        string(name: 'kx_hostname', defaultValue: "kx-main", description: "KX.AS.CODE main node hostname")
        string(name: 'kx_domain', defaultValue: "kx-as-code.local", description: "KX.AS.CODE local domain")
        string(name: 'base_image_ssh_user', defaultValue: "debian", description: "Default AMI SSH user")
        string(name: 'ssh_username', defaultValue: 'debian', description: 'SSH user used during packer build process')
        string(name: 'openstack_region', defaultValue: 'RegionOne', description: 'OpenStack Region')
        string(name: 'openstack_networks', defaultValue: '71e047f7-5855-43c6-a36a-bc8404278f90', description: 'OpenStack Network')
        string(name: 'openstack_floating_ip_network', defaultValue: 'public', description: 'OpenStack Floating IP Network')
        string(name: 'openstack_source_image', defaultValue: 'f9ca5675-d208-494f-97c5-3db12fbd8764', description: 'OpenStack Source Image')
        string(name: 'openstack_flavor', defaultValue: 'm1.medium', description: 'OpenStack Flavor')
        string(name: 'openstack_security_groups', defaultValue: 'limited_access', description: 'OpenStack Security Groups')
    }

    stages {

        stage('Clone the repository'){
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CleanBeforeCheckout']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: 'https://${git_repo_url}']]])
                }
            }
        }

        stage('Build the QCOW2 image'){
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'GITHUB_KX.AS.CODE', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                  withCredentials([usernamePassword(credentialsId: 'OPENSTACK_ADMIN_CREDENTIAL', usernameVariable: 'OPENSTACK_USER', passwordVariable: 'OPENSTACK_PASSWORD')]) {
                       def packerPath = tool 'packer-linux-1.7.2'
                        sh """
                        cd base-vm/build/packer/${os}
                        ${packerPath}/packer build -force -only kx.as.code-main-openstack \
                            -var "compute_engine_build=${kx_compute_engine_build}" \
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
                            -var "openstack_user=${openstack_user}" \
                            -var "openstack_password=${openstack_password}" \
                            -var "openstack_region=${openstack_region}" \
                            -var "openstack_networks=${openstack_networks}" \
                            -var "openstack_floating_ip_network=${openstack_floating_ip_network}" \
                            -var "openstack_source_image=${openstack_source_image}" \
                            -var "openstack_flavor=${openstack_flavor}" \
                            -var "openstack_security_groups=${openstack_security_groups}" \
                            ./kx.as.code-main-cloud-profiles.json
                        """
                        }
                    }
                }
            }
        }
    }
}