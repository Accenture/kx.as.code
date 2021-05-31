node('packer') {
    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
        jqDownloadUrl="${JQ_DARWIN_DOWNLOAD_URL}"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
        jqDownloadUrl="${JQ_LINUX_DOWNLOAD_URL}"
    } else {
        echo "Running on Windows"
        packerOsFolder="windows"
        jqDownloadUrl="${JQ_WINDOWS_DOWNLOAD_URL}"
    }
}

pipeline {

    agent { label "packer" }

    options {
        ansiColor('xterm')
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
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
        choice(choices: ['init', 'plan', 'apply', 'destroy'], name: 'terraform_action', description: 'Selection Terraform action to execute')
        string(name: 'git_repo_url', defaultValue: "github.com/Accenture/kx.as.code.git", description: "Source Github repository")
        string(name: 'git_source_branch', defaultValue: "main", description: "Source Github branch to build from and clone inside VM")
    }

    stages {

        stage('Clone the repository'){
            when {
                allOf {
                  expression{terraform_action == 'plan'}
                }
            }
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: 'https://${git_repo_url}']]])
                }
            }
        }

        stage('Execute Terraform Action'){
            environment {
               ....
            }
            steps {
                script {
                  withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "AWS_TERRAFORM_ACCESS",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                  ]]) {
                        sh """
                        env
                        cd profiles/terraform-aws-ip-vpn-demo1

                        if [[ ! -f ./jq ]]; then
                            curl -o jq ${jqDownloadUrl}
                        fi

                        if [[ "${terraform_action}" == "destroy" ]]; then
                            echo "${terraform_action}"
                        else
                            echo "${terraform_action}"
                        fi
                        """
                    }
                }
            }
        }
    }
}