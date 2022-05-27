def functions
def kx_version
def kube_version

node('built-in') {
    dir(shared_workspace) {
        functions = load "base-vm/build/jenkins/job_definitions/shared_functions/shared-pipeline-functions.groovy"
        println(functions)
        def vagrant_action = ''
        (kx_version, kube_version) = functions.setBuildEnvironment(profile,node_type,vagrant_action)
    }
}

pipeline {

    agent {
        node {
            label "built-in"
            customWorkspace shared_workspace
        }
    }

    parameters {
        string(name: 'kx_vm_user', defaultValue: '', description: '')
        string(name: 'kx_vm_password', defaultValue: '', description: '')
        string(name: 'vagrant_compute_engine_build', defaultValue: '', description: '')
        string(name: 'kx_version', defaultValue: '', description: '')
        string(name: 'kx_domain', defaultValue: '', description: '')
        string(name: 'kx_main_hostname', defaultValue: '', description: '')
        string(name: 'profile', defaultValue: '', description: '')
        string(name: 'profile_path', defaultValue: '', description: '')
        string(name: 'node_type', defaultValue: '', description: '')
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
        'biz.neustar.jenkins.plugins.packer.PackerInstallation' "packer-${os}"
    }

    stages {
        stage('Build the OVA/BOX'){
            steps {
                script {
                    dir(shared_workspace) {
                        withCredentials([usernamePassword(credentialsId: 'GIT_KX.AS.CODE_SOURCE', passwordVariable: 'git_source_token', usernameVariable: 'git_source_user')]) {
                            def packerPath = tool "packer-${os}"
                            if ( "${os}" == "windows" ) {
                                packerPath = packerPath.replaceAll("\\\\","/")
                            }
                            sh """
                            cd base-vm/build/packer/${packerOsFolder}
                            PACKER_LOG=1 ${packerPath}/packer build -force -on-error=abort -only ${node_type}-${profile} \
                            -var "compute_engine_build=${vagrant_compute_engine_build}" \
                            -var "memory=8192" \
                            -var "cpus=2" \
                            -var "video_memory=128" \
                            -var "hostname=${kx_main_hostname}" \
                            -var "domain=${kx_domain}" \
                            -var "version=${kx_version}" \
                            -var "kube_version=${kube_version}" \
                            -var "vm_user=${kx_vm_user}" \
                            -var "vm_password=${kx_vm_password}" \
                            -var "git_source_url=${git_source_url}" \
                            -var "git_source_branch=${git_source_branch}" \
                            -var "git_source_user=${git_source_user}" \
                            -var "git_source_token=${git_source_token}" \
                            -var "base_image_ssh_user=${vagrant_ssh_username}" \
                            ./${node_type}-local-profiles.json
                            """
                        }
                    }
                }
            }
        }
    }
}
