node('local') {
    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_DARWIN_DOWNLOAD_URL}"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_LINUX_DOWNLOAD_URL}"
    } else {
        echo "Running on Windows"
        os="windows"
        jqDownloadPath="${JQ_WINDOWS_DOWNLOAD_URL}"
        packerOsFolder="windows"
    }
}

pipeline {

    agent { label "local" }

    options {
        ansiColor('xterm')
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 3, unit: 'HOURS')
    }

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
                    checkout([$class: 'GitSCM', branches: [[name: "$git_source_branch"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GIT_KX.AS.CODE_SOURCE', url: '${git_source_url}']]])
                }
            }
        }

        stage('Build the OVA/BOX'){
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'GIT_KX.AS.CODE_SOURCE', passwordVariable: 'git_source_token', usernameVariable: 'git_source_user')]) {
                withCredentials([usernamePassword(credentialsId: 'GIT_KX.AS.CODE_DOCS', passwordVariable: 'git_docs_token', usernameVariable: 'git_docs_user')]) {
                withCredentials([usernamePassword(credentialsId: 'GIT_KX.AS.CODE_TECHRADAR', passwordVariable: 'git_techradar_token', usernameVariable: 'git_techradar_user')]) {
                        def packerPath = tool "packer-${os}"
                        if ( "${os}" == "windows" ) {
                            packerPath = packerPath.replaceAll("\\\\","/")
                        }
                        sh """
                        if [[ ! -f ./jq* ]]; then
                            curl -L -o jq ${jqDownloadPath}
                            chmod +x ./jq
                        fi
                        export kx_version=\$(cat versions.json | ./jq -r '.kx-as-code')
                        export kube_version=\$(cat versions.json | ./jq -r '.kubernetes')
                        echo \${kx_version}
                        echo \${kube_version}
                        cd base-vm/build/packer/${packerOsFolder}
                        ${packerPath}/packer build -force -only kx.as.code-main-parallels \
                        -var "compute_engine_build=${vagrant_compute_engine_build}" \
                        -var "memory=8192" \
                        -var "cpus=2" \
                        -var "video_memory=128" \
                        -var "hostname=${kx_main_hostname}" \
                        -var "domain=${kx_domain}" \
                        -var "version=\${kx_version}" \
                        -var "kube_version=\${kube_version}" \
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
                        ./kx.as.code-main-local-profiles.json
                        """
                    }}}
                }
            }
        }
    }
}