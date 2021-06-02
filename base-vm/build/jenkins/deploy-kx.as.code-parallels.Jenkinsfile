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

    environment {
        RED="\033[31m"
        GREEN="\033[32m"
        ORANGE="\033[33m"
        BLUE="\033[34m"
        NC="\033[0m" // No Color
    }

    stages {

        stage('Clone the repository'){
            when {
                allOf {
                  expression{vagrant_action == 'up'}
                }
            }
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GITHUB_KX.AS.CODE', url: '${git_repo_url}']]])
                }
            }
        }

        stage('Execute Vagrant Action'){
            steps {
                script {
                    sh """
                    cd profiles/vagrant-parallels-demo1
                    if [[ "${vagrant_action}" == "destroy" ]]; then
                        vagrant halt
                        vagrant ${vagrant_action} -f
                    else
                        vagrant ${vagrant_action}
                    fi
                    """
                }
            }
        }
    }
}