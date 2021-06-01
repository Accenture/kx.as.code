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

        stage('Build the AMI'){
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'GITHUB_KX.AS.CODE', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                  withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "AWS_PACKER_ACCESS",
                    accessKeyVariable: 'AWS_PACKER_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_PACKER_SECRET_ACCESS_KEY'
                  ]]) {
                        def packerPath = tool "packer-${os}"
                        sh """
                        cd base-vm/build/packer/${packerOsFolder}
                        ${packerPath}/packer build -force -only kx.as.code-worker-aws-ami \
                        -var "compute_engine_build=${aws_compute_engine_build}" \
                        -var "hostname=${kx_worker_hostname}" \
                        -var "domain=${kx_domain}" \
                        -var "version=${kx_version}" \
                        -var "vm_user=${kx_vm_user}" \
                        -var "vm_password=${kx_vm_password}" \
                        -var "instance_type=${aws_instance_type}" \
                        -var "access_key=${AWS_ACCESS_KEY_ID}" \
                        -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
                        -var "github_user=${GITHUB_USER}" \
                        -var "github_token=${GITHUB_TOKEN}" \
                        -var "git_source_branch=${git_source_branch}" \
                        -var "source_ami=${aws_source_ami}" \
                        -var "ami_groups=${aws_ami_groups}" \
                        -var "vpc_region=${aws_vpc_region}" \
                        -var "availability_zone=${aws_availability_zone}" \
                        -var "vpc_id=${aws_vpc_id}" \
                        -var "vpc_subnet_id=${aws_vpc_subnet_id}" \
                        -var "associate_public_ip_address=${aws_associate_public_ip_address}" \
                        -var "ssh_username=${aws_ssh_interface}" \
                        -var "ssh_username=${aws_ssh_username}" \
                        -var "shutdown_behavior=${aws_shutdown_behavior}" \
                        ./kx.as.code-worker-cloud-profiles.json
                        """
                        }
                    }
                }
            }
        }
    }
}