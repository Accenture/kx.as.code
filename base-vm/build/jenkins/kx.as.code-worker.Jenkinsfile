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
        string(name: 'base_image_ssh_user', defaultValue: "admin", description: "Default AMI SSH user")
        string(name: 'ami_groups', defaultValue: "kxascode", description: "AWS user group that can launch AMI")
        string(name: 'vpc_region', defaultValue: 'us-east-2', description: 'VPC region, eg. us-east-2')
        string(name: 'vpc_id', defaultValue: 'vpc-051354ba4e689b0b4', description: 'VPC Id')
        string(name: 'vpc_subnet_id', defaultValue: 'subnet-038d9eabbbb629e5c', description: 'VPC Subnet Id')
        string(name: 'availability_zone', defaultValue: 'us-east-2c', description: 'VPC Availability zone, eg. us-east-2c')
        string(name: 'associate_public_ip_address', defaultValue: 'true', description: 'Assign public IP. Should be true or false')
        string(name: 'source_ami', defaultValue: 'ami-0f42acddbf04bd1b6', description: 'Source AMI set to Debian Buster 10.9')
        string(name: 'security_group_id', defaultValue: 'sg-0772da3ed04fe2677', description: 'VPC Security Group Id')
        string(name: 'instance_type', defaultValue: 't3.small', description: 'Instance type, eg t3.small')
        string(name: 'shutdown_behavior', defaultValue: 'terminate', description: 'Stop or Terminate instance on failure')
        string(name: 'ssh_username', defaultValue: 'admin', description: 'SSH user used during packer build process')
        string(name: 'ssh_interface', defaultValue: 'public_ip', description: 'Options are private_ip or public_ip')
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
                        cd base-vm/build/packer/darwin-linux
                        PACKER_LOG=1 ${packerPath}/packer build -force -only kx.as.code-worker-aws-ami \
                        -var "compute_engine_build=${kx_compute_engine_build}" \
                        -var "hostname=${kx_hostname}" \
                        -var "domain=${kx_domain}" \
                        -var "version=${kx_version}" \
                        -var "vm_user=${kx_vm_user}" \
                        -var "vm_password=${kx_vm_password}" \
                        -var "instance_type=${instance_type}" \
                        -var "access_key=${AWS_ACCESS_KEY_ID}" \
                        -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
                        -var "github_user=${GITHUB_USER}" \
                        -var "github_token=${GITHUB_TOKEN}" \
                        -var "source_ami=${source_ami}" \
                        -var "ami_groups=${ami_groups}" \
                        -var "vpc_region=${vpc_region}" \
                        -var "availability_zone=${availability_zone}" \
                        -var "vpc_id=${vpc_id}" \
                        -var "vpc_subnet_id=${vpc_subnet_id}" \
                        -var "associate_public_ip_address=${associate_public_ip_address}" \
                        -var "ssh_username=${ssh_interface}" \
                        -var "ssh_username=${ssh_username}" \
                        -var "base_image_ssh_user=${base_image_ssh_user}" \
                        -var "shutdown_behavior=${shutdown_behavior}" \
                        kx.as.code-worker-aws-ami.json
                        """
                        }
                    }
                }
            }
        }
    }
}
