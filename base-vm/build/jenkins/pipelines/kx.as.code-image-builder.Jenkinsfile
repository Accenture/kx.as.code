def functions
def kx_version
def kube_version

node('master') {
    dir(shared_workspace) {
        functions = load "base-vm/build/jenkins/pipelines/shared-pipeline-functions.groovy"
        println(functions)
        (kx_version, kube_version) = functions.setBuildEnvironment()
    }
}

pipeline {

    agent {
        node {
            label "master"
            customWorkspace shared_workspace
        }
    }

    parameters {
        string(name: 'kx_vm_user', defaultValue: '', description: '')
        string(name: 'kx_vm_password', defaultValue: '', description: '')
        string(name: 'vagrant_compute_engine_build', defaultValue: '', description: '')
        string(name: 'kx_version_override', defaultValue: '', description: '')
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
                        withCredentials([usernamePassword(credentialsId: 'GIT_KX.AS.CODE_DOCS', passwordVariable: 'git_docs_token', usernameVariable: 'git_docs_user')]) {
                        withCredentials([usernamePassword(credentialsId: 'GIT_KX.AS.CODE_TECHRADAR', passwordVariable: 'git_techradar_token', usernameVariable: 'git_techradar_user')]) {
                            def packerPath = tool "packer-${os}"
                            if ( "${os}" == "windows" ) {
                                packerPath = packerPath.replaceAll("\\\\","/")
                            }
                            sh """
                            cd base-vm/build/packer/${packerOsFolder}
                            PACKER_LOG=1 ${packerPath}/packer build -force -only ${node_type}-${profile} \
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
                            -var "git_docs_url=${git_docs_url}" \
                            -var "git_docs_branch=${git_docs_branch}" \
                            -var "git_docs_user=${git_docs_user}" \
                            -var "git_docs_token=${git_docs_token}" \
                            -var "git_techradar_url=${git_techradar_url}" \
                            -var "git_techradar_branch=${git_techradar_branch}" \
                            -var "git_techradar_user=${git_techradar_user}" \
                            -var "git_techradar_token=${git_techradar_token}" \
                            -var "base_image_ssh_user=${vagrant_ssh_username}" \
                            ./${node_type}-local-profiles.json
                            """
                        }}}
                    }
                }
            }
        }
    }
}
