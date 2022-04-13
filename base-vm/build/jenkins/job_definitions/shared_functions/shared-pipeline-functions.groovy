def setBuildEnvironment(profile,node_type,vagrant_action) {

    println("setBuildEnvironment() -> Received parameters: profile: ${profile}, node_type: ${node_type}, vagrant_action: ${vagrant_action}")

    os = sh (
        script: 'uname -s',
        returnStdout: true
    ).toLowerCase().trim()
    if ( os == "darwin" ) {
        echo "Running on Mac"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_DARWIN_DOWNLOAD_URL}"
        vmWareDiskUtilityPath="/System/Volumes/Data/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
        virtualboxCliPath = "/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
        vmwareCliPath = "/Applications/VMware\\ Fusion.app/Contents/Public/vmrun"
        parallelsCliPath = "/Applications/Parallels Desktop.app/Contents/MacOS/prlctl"
    } else if ( os == "linux" ) {
        echo "Running on Linux"
        packerOsFolder="darwin-linux"
        jqDownloadPath="${JQ_LINUX_DOWNLOAD_URL}"
        vmWareDiskUtilityPath=""
        virtualboxCliPath = "/usr/bin/vboxmanage"
        vmwareCliPath = "/usr/bin/vmrun"
    } else {
        echo "Running on Windows"
        os="windows"
        packerOsFolder="windows"
        jqDownloadPath="${JQ_WINDOWS_DOWNLOAD_URL}"
        vmWareDiskUtilityPath="c:/Program Files (x86)/VMware/VMware Workstation/vmware-vdiskmanager.exe"
        virtualboxCliPath = "C:/Program Files/Oracle/VirtualBox/VBoxManage.exe"
        vmwareCliPath = "C:/Program Files (x86)/VMware/VMware Workstation/vmrun.exe"
    }

    sh """
    if [ ! -f ./jq* ]; then
        curl -L -o jq ${jqDownloadPath}
        chmod +x ./jq
    fi
    """

    kx_version = sh (script: "cat versions.json | ./jq -r '.kxascode'", returnStdout: true).trim()
    kube_version = sh (script: "cat versions.json | ./jq -r '.kubernetes'", returnStdout: true).trim()
    gitShortCommitId = sh (script: "git rev-parse --short HEAD", returnStdout: true).trim()
    try {
        if ( currentBuild.number > 1 ) {
            if ( node_type != '' ) {
                currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${profile}_${node_type}_${gitShortCommitId}"
            } else if ( vagrant_action != '' ){
                currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${profile}_${vagrant_action}_${gitShortCommitId}"
            } else {
                currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${gitShortCommitId}"
            }
            def lastCompletedBuildName = Jenkins.instance.getItemByFullName(env.JOB_NAME).lastCompletedBuild.displayName
            def (oldBuildNumber, oldKxVersion, oldKubeVersion, oldGitShortCommitId) = lastCompletedBuildName.split('_')
            if ( oldKxVersion != "v${kx_version}" ) {
                println("KX.AS.CODE version has changed since the last build, ${oldKxVersion} --> v${kx_version}")
            } else {
                println("KX.AS.CODE version has not changed since the last build - v${kx_version}")
            }
            if (oldKubeVersion !=  "v${kube_version}") {
                println("Kube version has changed since the last build, ${oldKubeVersion} --> v${kube_version}")
            } else {
                println("Kube version has not changed since the last build - v${kube_version}")
            }
            if ( os == "windows" ) {
                println("Getting Git-Log on ${os}")
                gitDiff = sh(script: """{ set +x; } 2>/dev/null
                         parsed_git_source_url=\$(echo ${git_source_url} | sed 's/\\.git//g')
                         git log ${oldGitShortCommitId}..${gitShortCommitId} --oneline --no-merges --stat --pretty='format:<a style=\"color: #ff8c00\" href=\"'\${parsed_git_source_url}'/commit/%h\">%h%<(15,trunc)</a> ### %<(15,trunc)%ar ### %<(20,trunc)%cn ### <span style=\"color: green\"> %<(100,trunc)%s </span>' | sed 's/<br>/\\&lt\\;br\\&gt\\;/g' | sed 's/<p>/\\&lt\\;p\\&gt\\;/g' | sed 's/§/<span style=\"color: red\">-<\\/span>/g' | sed 's/\$/<br>/g' | sed 's/§/<span style=\"color: green\">-<\\/span>/g' | sed 's/###/|/g'
                    """, returnStdout: true).trim()
            } else {
                println("Getting Git-Log on ${os}")
                gitDiff = sh(script: """{ set +x; } 2>/dev/null
                         parsed_git_source_url=\$(echo ${git_source_url} | sed 's/\\.git//g')
                         git log ${oldGitShortCommitId}..${gitShortCommitId} --oneline --no-merges --stat --pretty='format:<a style=\"color: #ff8c00\" href=\"${git_source_url}/commit/%h\">%h%<(15,trunc)</a> ### %<(15,trunc)%ar ### %<(20,trunc)%cn ### <span style=\"color: green\"> %<(100,trunc)%s </span>' | sed 's/<br>/\\&lt\\;br\\&gt\\;/g' | sed 's/<p>/\\&lt\\;p\\&gt\\;/g' | rev | sed -e ':b; /###/! s/^\\([^|]*\\)*\\-/\\1§/; tb;' | rev | sed 's/§/<span style=\"color: red\">-<\\/span>/g' | rev | sed -e ':b; /###/! s/^\\([^|]*\\)*+/\\1§/; tb;' | rev | sed 's/\$/<br>/g' | sed 's/§/<span style=\"color: green\">-<\\/span>/g' | sed 's/###/|/g'
                    """, returnStdout: true).trim()
            }
            header = '<!DOCTYPE html PUBLIC"-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head><div style="font-family:monospace,Courier;font-size:12px">'
            footer = "</div></html>"
            htmlBuildDescription = header + gitDiff + footer
            println(htmlBuildDescription)
            currentBuild.description = htmlBuildDescription
        } else {
            currentBuild.displayName = "#${currentBuild.number}_v${kx_version}_v${kube_version}_${gitShortCommitId}"
        }
    } catch(Exception e) {
        // Do not fail the build because there was an error setting the build name
        println("Exception: ${e}")
    }
    return [ kx_version, kube_version ]
}

def addVagrantBox(provider,kx_version) {
    sh """
        # Get the number of main and worker nodes, to determine if it's needed to import the kx-node or not
        if [ ! -f profiles/vagrant-${provider}/profile-config.json ]; then
            echo "profiles/vagrant-${provider}/profile-config.json missing. Cannot continue with the deployment."
            exit 1
        else
            mainNodesNum=\$(cat profiles/vagrant-${provider}/profile-config.json | jq '.config.vm_properties.main_node_count')
            workerNodesNum=\$(cat profiles/vagrant-${provider}/profile-config.json | jq '.config.vm_properties.worker_node_count')
        fi

        # Import kx-node if profile-config.json is >0 for kx-main or kx-worker nodes
        if [ \${mainNodesNum} -gt 1 ] || [ \${workerNodesNum} -gt 0 ]; then
            if [ -f base-vm/boxes/${provider}-${kx_version}/kx.as.code-node-${kx_version}_metadata.json ]; then
                echo "${BLUE}Adding Vagrant box kx.as.code-node-${kx_version}, before starting up the environment${NC}"
                metadata="base-vm/boxes/${provider}-${kx_version}/kx.as.code-node-${kx_version}_metadata.json"
                vagrant box add kx.as.code-node \${metadata} --force
            else
                echo "${RED}You must build the kx-main box first, before starting up the KX.AS.CODE environment${NC}"
                exit 1
            fi
        fi

        # Exit job execution if # of desired main nodes is less than 1
        if [ \${mainNodesNum} -lt 1 ]; then
            echo "${RED}You must have at least 1 KX-Main node defined in profile-config.json. KX.AS.CODE cannot start with 0 main nodes${NC}"
            cho "${RED}The number of main nodes for ${provider} are defined in \"profiles/vagrant-${provider}/profile-config.json\"${NC}"
            exit 1
        else
            if [ -f base-vm/boxes/${provider}-${kx_version}/kx.as.code-main-${kx_version}_metadata.json ]; then
                echo "${BLUE}Adding Vagrant box kx.as.code-main-${kx_version}, before starting up the environment${NC}"
                metadata="base-vm/boxes/${provider}-${kx_version}/kx.as.code-main-${kx_version}_metadata.json"
                vagrant box add kx.as.code-main \${metadata} --force
            else
                echo "${RED}You must build the kx-main Vagrant box first, before starting up the KX.AS.CODE environment${NC}"
                exit 1
            fi
        fi
        echo "${GREEN}Vagrat boxes imported successfully. Proceeding to start KX.AS.CODE environment...${NC}"
        vagrant box list -i
    """
}

def setEnvironmentPrefix(profile) {

    def environmentPrefix = sh (script: """
        if [ "${os}" == "darwin" ]; then
            export shuffleCommand="sort -R"
        else
            export shuffleCommand="shuf"
        fi
        cd profiles/${profile}
        if [ -z \$(vagrant status --machine-readable | grep ",state," | grep -v "not_created") ]; then
            # Cleanup old kx.as.code_main-ip-address file
            if [ -f kx.as.code_main-ip-address ]; then
                rm -f kx.as.code_main-ip-address
            fi
            profileEnvPrefix=\$(cat profile-config.json | jq -r '.config.environmentPrefix')
            if [ -z \$profileEnvPrefix ] || [ -n \$(cat ../.environment_prefix_names | grep "\$profileEnvPrefix") ]; then
                # No machines running and previous name also came from random name list. Will set a new name for new environment
                export environmentPrefix=\$(cat ../.environment_prefix_names | \${shuffleCommand} | tail -1)
                cat profile-config.json | jq -r '.config.environmentPrefix="'\${environmentPrefix}'"' | tee profile-config.json >/dev/null
            else
                # Get environment prefix from profile-config.json
                export environmentPrefix=\$(cat profile-config.json | jq -r '.config.environmentPrefix')
            fi
        fi
        echo \${environmentPrefix}
    """, returnStdout: true).trim()
    return environmentPrefix
}

return this
