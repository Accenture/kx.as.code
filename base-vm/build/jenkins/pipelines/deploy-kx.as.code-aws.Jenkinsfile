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
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 3, unit: 'HOURS')
    }

    tools {
        'terraform' "terraform-${os}"
    }

    stages {
        stage('Execute Terraform Action'){
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
                        def terraformPath = tool "terraform-${os}"
                        cd profiles/terraform-aws

                        if [ "${terraform_action}" == "destroy" ]; then
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