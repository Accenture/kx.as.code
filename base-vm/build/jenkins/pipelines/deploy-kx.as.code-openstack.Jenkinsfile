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
            environment {
                OS_EXTERNAL_NETWORK_ID = "${openstack_external_network_id}"
                OS_KX_MAIN_IMAGE_ID = "${openstack_kx_main_image_id}"
                OS_KX_WORKER_IMAGE_ID = "${openstack_kx_worker_image_id}"
                OS_REGION_NAME = "${openstack_region_name}"
                OS_AUTH_URL = "${openstack_auth_url}"
                OS_PROJECT_NAME = "${openstack_project_name}"
                OS_USER_DOMAIN_NAME = "${openstack_user_domain_name}"
                OS_PROJECT_DOMAIN_NAME = "${openstack_project_domain_name}"
                OS_IDENTITY_API_VERSION = "${openstack_identity_api_version}"
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'OPENSTACK_ADMIN_CREDENTIAL', usernameVariable: 'OS_USERNAME', passwordVariable: 'OS_PASSWORD')]) {
                        sh """
                        env
                        def terraformPath = tool "terraform-${os}"
                        unset OS_SERVICE_TOKEN
                        cd profiles/terraform-openstack
                        pip3 install python-openstackclient
                        openstack image list -f json
                        if [[ -z "${OS_KX_MAIN_IMAGE_ID}" ]]; then
                            export TF_VAR_KX_MAIN_IMAGE_ID=\$(openstack image list -f json | jq -r '.[] | select(.Name=="kx.as.code-worker-demo-0.6.7") | .ID')
                        else
                            export TF_VAR_KX_MAIN_IMAGE_ID=${OS_KX_MAIN_IMAGE_ID}
                        fi
                        if [[ -z "${OS_KX_WORKER_IMAGE_ID}" ]]; then
                            export TF_VAR_KX_WORKER_IMAGE_ID=\$(openstack image list -f json | jq -r '.[] | select(.Name=="kx.as.code-main-demo-0.6.7") | .ID')
                        else
                            export TF_VAR_KX_WORKER_IMAGE_ID=${OS_KX_WORKER_IMAGE_ID}
                        fi
                        echo "KX-Main Image ID: \${TF_VAR_KX_MAIN_IMAGE_ID}"
                        echo "KX-Worker Image ID: \${TF_VAR_KX_WORKER_IMAGE_ID}"

                        if [[ -z "${OS_EXTERNAL_NETWORK_ID}" ]]; then
                            export TF_VAR_EXTERNAL_NETWORK_ID=\$(openstack network list --external -f json | jq -r '.[].ID')
                        else
                            export TF_VAR_EXTERNAL_NETWORK_ID=${OS_EXTERNAL_NETWORK_ID}
                        fi
                        echo "External Network ID: \${TF_VAR_EXTERNAL_NETWORK_ID}"

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