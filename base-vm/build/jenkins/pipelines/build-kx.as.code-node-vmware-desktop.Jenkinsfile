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
                        def packerPath = tool "packer-${os}"
                        if ( "${os}" == "windows" ) {
                            packerPath = packerPath.replaceAll("\\\\","/")
                        }
                        sh """
                        if [[ ! -f ./jq* ]]; then
                            curl -L -o jq ${jqDownloadPath}
                            chmod +x ./jq
                        fi
                        export kx_version=\$(cat version.json | ./jq -r '.version')
                        echo \${kx_version}
                        cd base-vm/build/packer/${packerOsFolder}
                        ${packerPath}/packer build -force -only kx.as.code-node-vmware-desktop \
                        -var "compute_engine_build=${vagrant_compute_engine_build}" \
                        -var "memory=8192" \
                        -var "cpus=2" \
                        -var "video_memory=128" \
                        -var "hostname=${kx_node_hostname}" \
                        -var "domain=${kx_domain}" \
                        -var "version=\${kx_version}" \
                        -var "vm_user=${kx_vm_user}" \
                        -var "vm_password=${kx_vm_password}" \
                        -var "base_image_ssh_user=${vagrant_ssh_username}" \
                        ./kx.as.code-node-local-profiles.json
                        """
                    }
                }
            }
        }
    }
}