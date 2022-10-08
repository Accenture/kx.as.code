
tidyUpInterface()

function getLocalKxVersion() {
    let localKxVersion = document.getElementById("local-kx-version").value;
    return localKxVersion;
}

function getGithubKxVersion() {
    let githubKxVersion = document.getElementById("github-kx-version").value;
    return githubKxVersion;
}

function getLocalKubeVersion() {
    let localKubeVersion = document.getElementById("local-kube-version").value;
    return localKubeVersion;
}

function getGithubKubeVersion() {
    let githubKubeVersion = document.getElementById("github-kube-version").value;
    return githubKubeVersion;
}

function getProfilePaths() {
    let profilePaths = document.getElementById("profile-paths").value;
    return profilePaths;
}

function getVirtualboxLocalVagrantBoxMainVersion() {
    let virtualboxLocalVagrantBoxMainVersion = document.getElementById("virtualbox-local-vagrant-box-main-version").value;
    return virtualboxLocalVagrantBoxMainVersion;
}

function getVirtualboxLocalVagrantBoxNodeVersion() {
    let virtualboxLocalVagrantBoxNodeVersion = document.getElementById("virtualbox-local-vagrant-box-node-version").value;
    return virtualboxLocalVagrantBoxNodeVersion;
}

function getVmwareLocalVagrantBoxMainVersion() {
    let vmwareLocalVagrantBoxMainVersion = document.getElementById("vmware-local-vagrant-box-main-version").value;
    return vmwareLocalVagrantBoxMainVersion;
}

function getVmwareLocalVagrantBoxNodeVersion() {
    let vmwareLocalVagrantBoxNodeVersion = document.getElementById("vmware-local-vagrant-box-node-version").value;
    return vmwareLocalVagrantBoxNodeVersion;
}

function getParallelsLocalVagrantBoxMainVersion() {
    let parallelsLocalVagrantBoxMainVersion = document.getElementById("parallels-local-vagrant-box-main-version").value;
    return parallelsLocalVagrantBoxMainVersion;
}

function getParallelsLocalVagrantBoxNodeVersion() {
    let parallelsLocalVagrantBoxNodeVersion = document.getElementById("parallels-local-vagrant-box-node-version").value;
    return parallelsLocalVagrantBoxNodeVersion;
}

function getVirtualboxKxMainVagrantCloudVersion() {
    let virtualboxKxMainVagrantCloudVersion = document.getElementById("virtualbox-kx-main-vagrant-cloud-version").value;
    return virtualboxKxMainVagrantCloudVersion;
}

function getVirtualboxKxNodeVagrantCloudVersion() {
    let virtualboxKxNodeVagrantCloudVersion = document.getElementById("virtualbox-Kx-node-vagrant-cloud-version").value;
    return virtualboxKxNodeVagrantCloudVersion;
}

function getVmwareDesktopKxMainVagrantCloudVersion() {
    let vmwareDesktopKxMainVagrantCloudVersion = document.getElementById("vmware-desktop-kx-main-vagrant-cloud-version").value;
    return vmwareDesktopKxMainVagrantCloudVersion;
}

function getVmwareDesktopKxNodeVagrantCloudVersion() {
    let vmwareDesktopKxNodeVagrantCloudVersion = document.getElementById("vmware-desktop-kx-node-vagrant-cloud-version").value;
    return vmwareDesktopKxNodeVagrantCloudVersion;
}

function getParallelsKxMainVagrantCloudVersion() {
    let parallelsKxMainVagrantCloudVersion = document.getElementById("parallels-kx-main-vagrant-cloud-Version").value;
    return parallelsKxMainVagrantCloudVersion;
}

function getParallelsKxNodeVagrantCloudVersion() {
    let parallelsKxNodeVagrantCloudVersion = document.getElementById("parallels-kx-node-vagrant-cloud-version").value;
    return parallelsKxNodeVagrantCloudVersion;
}

function getVboxExecutableExists() {
    let vboxExecutableExists = document.getElementById("vbox-executable-exists").value;
    return vboxExecutableExists;
}

function getParallelsExecutableExists() {
    let parallelsExecutableExists = document.getElementById("parallels-executable-exists").value;
    return parallelsExecutableExists;
}

function getVmwareExecutableExists() {
    let vmwareExecutableExists = document.getElementById("vmware-executable-exists").value;
    return vmwareExecutableExists;
}

function getVboxVagrantPluginInstalled() {
    let vboxVagrantPluginInstalled = document.getElementById("vbox-vagrant-plugin-installed").value;
    return vboxVagrantPluginInstalled;
}

function getVmwareVagrantPluginInstalled() {
    let vmwareVagrantPluginInstalled = document.getElementById("vmware-vagrant-plugin-installed").value;
    return vmwareVagrantPluginInstalled;
}

function getParallelsPluginInstalled() {
    let parallelsPluginInstalled = document.getElementById("parallels-vagrant-plugin-installed").value;
    return parallelsPluginInstalled;
}

async function triggerBuild(nodeType) {

    document.getElementById(nodeType + "-build-result").className = "";
    document.getElementById(nodeType + "-build-result").style.justifyContent = "center";
    document.getElementById(nodeType + "-build-result").innerHTML = "<div class='dot-flashing' style='background-color: white; margin-right: 15px; margin-left: 15px;'></div>";

    // Disable buttons to avoid double builds
    document.getElementById("build-" + nodeType + "-play-button").style.pointerEvents = "none";
    document.getElementById("build-" + nodeType + "-play-button").style.cursor = "not-allowed";
    document.getElementById("build-" + nodeType + "-play-button").style.opacity = "0.3";

    disableControlPanel(arguments.callee.name);

    let jenkinsCrumb = getCrumb().value;
    let localKxVersion = getLocalKxVersion();
    let formData = new FormData();
    formData.append('kx_vm_user', 'kx.hero'); //user changed at runtime, rather than build time
    formData.append('kx_vm_password', 'L3arnandshare'); //user changed at runtime, rather than build time
    formData.append('vagrant_compute_engine_build', 'false');
    formData.append('kx_version', localKxVersion);
    formData.append('kx_domain', document.getElementById('general-param-base-domain').value);
    formData.append('kx_main_hostname', nodeType);
    formData.append('profile', document.getElementById('profiles').value);
    formData.append('profile_path', getProfilePath());
    formData.append('node_type', nodeType);

    const config = {
        method: 'POST',
        headers: {
            'Authorization': 'Basic ' + btoa('admin:admin'),
            'Jenkins-Crumb': jenkinsCrumb
        },
        body: formData
    }
    let response = await fetch('/job/Actions/job/KX.AS.CODE_Image_Builder/buildWithParameters', config);
    let data = await response.text();

    await new Promise(resolve => setTimeout(resolve, 10000))
    enableControlPanel(arguments.callee.name);
    refreshGetBuildJobList("KX.AS.CODE_Image_Builder", nodeType)
}

function populate_profile_option_list() {
    tidyUpInterface()
    let profiles = getProfilePaths().split(',');

    for ( let i = 0; i < profiles.length; i++ ) {
        let profileName = profiles[i].split("/").pop();
        profileName = profileName.replace("vagrant-", "");

        document.getElementById("profiles").options[i] = new Option(profileName, profileName);
        update_selected_value();
    }
}

function update_selected_value(selectedProfileIndex) {
    if ( ! selectedProfileIndex ) {
        selectedProfileIndex = document.getElementById("profiles").selectedIndex;
    }
    let profilePaths = getProfilePaths().split(',');
    let profilePath = profilePaths[selectedProfileIndex] + '/profile-config.json'
    let startMode = document.getElementsByClassName("start-mode-selection-radio-selected")[0].id.split("-")[1];
    let orchestrator = document.getElementsByClassName("orchestrator-selection-radio-selected")[0].id.split("-")[1];
    let concatenatedProfileSelection = profilePath + ";" + startMode + ";" + orchestrator;
    document.getElementById("concatenated-profile-selection").value = concatenatedProfileSelection;
    document.getElementById("concatenated-profile-selection").setAttribute("concatenated-profile-selection", concatenatedProfileSelection);
    triggerChoiceParameterUpdate('concatenated-profile-selection');
}

function compareVersions() {
    let githubKxVersion = getGithubKxVersion();
    let githubKubeVersion = getGithubKubeVersion();
    let localKxVersion = getLocalKxVersion();
    let localKubeVersion = getLocalKubeVersion();

    if (githubKxVersion !== localKxVersion) {

        document.getElementById("version-check-message").innerHTML = "Your local checked out code (v" + localKxVersion + ") does not match the version on GitHub MAIN (v" + githubKxVersion + ")";
        document.getElementById("version-check-svg").src = "/userContent/icons/alert-outline.svg";
        document.getElementById("version-check-svg").className = "checklist-status-icon svg-orange-red";
    } else {

        document.getElementById("version-check-message").innerHTML = "The latest KX.AS.CODE source (v" + localKxVersion + ") is present on your machine";
        document.getElementById("version-check-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
        document.getElementById("version-check-svg").className = "checklist-status-icon svg-bright-green";
    }
}

function tidyUpInterface() {

    let mainElementDiv = document.getElementById("main-panel")
    mainElementDiv.childNodes.forEach(c=>{

        if(c.tagName  === 'P'){

            mainElementDiv.removeChild(c);
        }
        if(c.tagName  === 'H1'){

            mainElementDiv.removeChild(c);
        }
    })

    let parameterLabelElements = document.getElementsByClassName("jenkins-form-label");
    for (let i = 0; i < parameterLabelElements.length; i++) {
        parameterLabelElements[i].style.display = "none"
    }

    let folderElements = document.getElementsByClassName("icon-folder");
    folderElements[0].className = "icon-folder icon-md";

}

function changeBuildButton() {
    const checkElement = async selector => {
        while (document.querySelector(selector) === null) {
            await new Promise(resolve => requestAnimationFrame(resolve));
        }
        return document.querySelector(selector);
    };

    checkElement(document.getElementById("yui-gen1-button")).then((selector) => {

        document.getElementById("yui-gen1-button").innerText = "Start";
    });
}

function updateConcatenatedGeneralParamsReturnVariable() {

    let baseDomain = document.getElementById("general-param-base-domain");
    let baseDomainValue;
    if (baseDomain.value.length === 0) {
        baseDomainValue = baseDomain.placeholder.trim();
    } else {
        baseDomainValue = baseDomain.value.trim();
    }

    let username = document.getElementById("general-param-username");
    let usernameValue;
    if (username.value.length === 0) {
        usernameValue = username.placeholder.trim();
    } else {
        usernameValue = username.value.trim();
    }

    let teamName = document.getElementById("general-param-team-name");
    let teamNameValue;
    if (teamName.value.length === 0) {
        teamNameValue = teamName.placeholder.trim();
    } else {
        teamNameValue = teamName.value.trim();
    }

    let password = document.getElementById("general-param-password");
    let passwordValue;
    if (password.value.length === 0) {
        passwordValue = password.placeholder.trim();
    } else {
        passwordValue = password.value.trim();
    }

    let standaloneModeCheckedStatus = document.getElementById("general-param-standalone-mode-toggle").checked
    let workloadsOnMasterCheckedStatus = document.getElementById("general-param-workloads-on-master-toggle").checked
    let disableLinuxDesktop = document.getElementById("general-param-disable-desktop-toggle").checked

    triggerChoiceParameterUpdate('concatenated-general-params');
    document.getElementById("concatenated-general-params").value = baseDomainValue + ";" + teamNameValue + ";" + usernameValue + ";" + passwordValue + ";" + standaloneModeCheckedStatus + ";" + workloadsOnMasterCheckedStatus + ";" + disableLinuxDesktop;

    //#TODO - Placeholder to check if issue after commenting out line below
    //change_panel_selection("config-panel-general-params");
}

async function waitForElement(elementId, callBack){
    window.setTimeout(function(){
        let element = document.getElementById(elementId);
        if(element){
            callBack(elementId, element);
        }else{
            waitForElement(elementId, callBack);
        }
    },500)
}

function setInitialCheckboxValue(checkboxElementId, checked) {
    document.getElementById(checkboxElementId).className = "checkbox-slider round";
    document.getElementById(checkboxElementId).checked = checked;
    document.getElementById(checkboxElementId).value = checked;
    document.getElementById(checkboxElementId + '-name-value').value = checked;
}

function updateCheckbox(checkboxElementId) {

    disableControlPanel(arguments.callee.name);

    waitForElement(checkboxElementId, function () {

    });

    waitForElement('standalone-mode-toggle', function () {


    });

    waitForElement('system-prerequisites-check', function () {

    });

    if (document.getElementById(checkboxElementId).checked === true) {
        document.getElementById(checkboxElementId).className = "checkbox-slider round";
        document.getElementById(checkboxElementId).checked = true;
        document.getElementById(checkboxElementId).value = true;
        document.getElementById(checkboxElementId + '-name-value').value = true;
    } else {
        document.getElementById(checkboxElementId).className = "checkbox-slider round";
        document.getElementById(checkboxElementId).checked = false;
        document.getElementById(checkboxElementId).value = false;
        document.getElementById(checkboxElementId + '-name-value').value = false;
    }
    /*
        if (document.getElementById("system-prerequisites-check").value === "standalone" || document.getElementById("system-prerequisites-check").value === "failed") {

            document.getElementById('general-param-standalone-mode-toggle').checked = true;
            document.getElementById('general-param-workloads-on-master-toggle').checked = true;
            document.getElementById('general-param-standalone-mode-toggle').className = "checkbox-slider-checked-disabled round";
            document.getElementById('general-param-standalone-mode-toggle-span').className = "checkbox-slider-checked-disabled round";
            document.getElementById('general-param-workloads-on-master-toggle').className = "checkbox-slider-checked-disabled round";
            document.getElementById('general-param-workloads-on-master-toggle-span').className = "checkbox-slider-checked-disabled round";
            document.getElementById('general-param-workloads-on-master-toggle-name-value').value = true;
            document.getElementById('general-param-disable-desktop-toggle').className = "checkbox-slider round";
            document.getElementById('general-param-disable-desktop-toggle-span').className = "checkbox-slider round";
        } else if (document.getElementById("system-prerequisites-check").value === "full") {
            document.getElementById('general-param-standalone-mode-toggle').className = "checkbox-slider round";
            document.getElementById('general-param-standalone-mode-toggle-span').className = "checkbox-slider round";
            document.getElementById('general-param-workloads-on-master-toggle').className = "checkbox-slider round";
            document.getElementById('general-param-workloads-on-master-toggle-span').className = "checkbox-slider round";
            document.getElementById('general-param-disable-desktop-toggle').className = "checkbox-slider round";
            document.getElementById('general-param-disable-desktop-toggle-span').className = "checkbox-slider round";
        }
    */
    triggerChoiceParameterUpdate(checkboxElementId + '-name-value');
    enableControlPanel(arguments.callee.name);
}

function triggerChoiceParameterUpdate(elementId) {
    let parentId;
    let baseCommand = "document.getElementById(\"" + elementId + "\").parentNode";
    let command;
    for (let i = 0; i < 15; i++) {
        command = baseCommand + ".id";
        parentId = eval(command);
        if (parentId.startsWith("formattedHtml_choice-parameter")) {
            break;
        } else {
            baseCommand = baseCommand + ".parentNode";
        }
    }
    jQuery('#' + parentId).trigger('change');
}

function show_value(x, previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit) {
    let previous_x = document.getElementById(previousElementId).value;
    if (x !== previous_x) {
        let x_float = parseFloat(x).toFixed(2);
        document.getElementById(valueElementId).innerHTML = (x_float / valueDisplayConversion) + " " + rangeUnit;
        document.getElementById(elementId).value = x;
        document.getElementById(elementId).setAttribute(elementId, x);
        if (parseInt(x) < parseInt(minWarning)) {
            document.getElementById(warningElementId).style.visibility = "visible";
        } else {
            document.getElementById(warningElementId).style.visibility = "hidden";
        }
        document.getElementById(previousElementId).value = x;
        if (elementId.includes("main_admin_node") || elementId.includes("main_node")) {
            updateConcatenatedNodeReturnVariable("concatenated_value_main_node_config");
        } else if (elementId.includes("worker_node")) {
            updateConcatenatedNodeReturnVariable("concatenated_value_worker_node_config");
        } else if (elementId.includes("local_volume_count") || elementId.includes("network_storage")) {
            updateConcatenatedStorageReturnVariable();
        } else if (elementId.includes("general-param")) {
            updateConcatenatedGeneralParamsReturnVariable();
        } else {

        }
    }
    calculateHeatmapScalePosition();
}

function update_display_value(x, valueElementId, valueDisplayConversion, rangeUnit) {
    let x_float = parseFloat(x).toFixed(2);
    document.getElementById(valueElementId).innerHTML = (x_float / valueDisplayConversion) + " " + rangeUnit;
}

function add_one(previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit, step, max) {
    let count = parseInt(document.getElementById(elementId).value) + parseInt(step);
    if (count <= max) {
        show_value(count, previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit);
    }
}

function subtract_one(previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit, step, min) {
    let count = parseInt(document.getElementById(elementId).value) - parseInt(step);
    if (count >= min) {
        show_value(count, previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit);
    }
}

function updateConcatenatedNodeReturnVariable(hiddenValueElementId) {
    let nodeCount
    let cpuCores
    let memory

    if (hiddenValueElementId === "concatenated_value_main_node_config") {

        nodeCount = document.getElementById("counter_value_main_node_count").value;
        cpuCores = document.getElementById("slider_value_main_admin_node_cpu_cores").value;
        memory = document.getElementById("slider_value_main_admin_node_memory").value;

    } else if (hiddenValueElementId === "concatenated_value_worker_node_config") {

        nodeCount = document.getElementById("counter_value_worker_node_count").value;
        cpuCores = document.getElementById("slider_value_worker_node_cpu_cores").value;
        memory = document.getElementById("slider_value_worker_node_memory").value;

    } else {

    }
    let concatenatedValue = nodeCount + ";" + cpuCores + ";" + memory;

    document.getElementById(hiddenValueElementId).value = concatenatedValue;
    triggerChoiceParameterUpdate(hiddenValueElementId);
}

function updateConcatenatedStorageReturnVariable() {
    let counterHiddenValueIdOneGb = document.getElementById("counter_value_local_volume_count_1_gb").value;
    let counterHiddenValueIdFiveGb = document.getElementById("counter_value_local_volume_count_5_gb").value;
    let counterHiddenValueIdTenGb = document.getElementById("counter_value_local_volume_count_10_gb").value;
    let counterHiddenValueIdThirtyGb = document.getElementById("counter_value_local_volume_count_30_gb").value;
    let counterHiddenValueIdFiftyGb = document.getElementById("counter_value_local_volume_count_50_gb").value;
    let networkStorageValueGb = document.getElementById("slider_value_network_storage").value;
    let concatenatedLocalVolumeParams = counterHiddenValueIdOneGb + ";" + counterHiddenValueIdFiveGb + ";" + counterHiddenValueIdTenGb + ";" + counterHiddenValueIdThirtyGb + ";" + counterHiddenValueIdFiftyGb + ";" + networkStorageValueGb;
    document.getElementById("concatenated-storage-params").value = concatenatedLocalVolumeParams;
    document.getElementById("concatenated-storage-params").setAttribute("concatenated-storage-params", concatenatedLocalVolumeParams);
    let parentId = triggerChoiceParameterUpdate('concatenated-storage-params');
}

function updateAllConcatenatedVariables() {
    updateConcatenatedGeneralParamsReturnVariable();
    updateConcatenatedNodeReturnVariable("concatenated_value_main_node_config");
    updateConcatenatedNodeReturnVariable("concatenated_value_worker_node_config");
    updateConcatenatedStorageReturnVariable();
}

async function refreshGetBuildJobList(job, nodeType, timeout=3000) {
    // Rerun getBuildJobListForProfile if still in progress
    var buildStatus = getBuildJobListForProfile(job, nodeType);
    while (buildStatus !== 'DONE') {
        // wait for 3s
        await new Promise(r => setTimeout(r, timeout))
        buildStatus = getBuildJobListForProfile(job, nodeType);
    }
}

async function getBuildJobListForProfile(job, nodeType) {
    let styleColor;
    var buildStatus = 'IN PROGRESS';
    getAllJenkinsBuilds(job).then(data => {
        const kxBuilds = (() => {
            const builds = filterBuilds(data);
            // Return builds according to profile selection
            const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
            if (nodeType === "kx-launch") {
                return filteredBuilds;
            } else {
                return filterDataByNodeType(filteredBuilds, nodeType);
            }
        })();

        if (kxBuilds.length > 0) {
            getExtendedJobDetails(kxBuilds[0].url).then( text => {

                const splitDisplayName = JSON.parse(text).displayName.split('_');
                //const buildNumber = splitDisplayName[0];
                const kxVersion = splitDisplayName[1];
                const kubeVersion = splitDisplayName[2];
                //const profile = splitDisplayName[3];
                const nodeTypeVagrantAction = splitDisplayName[4];
                //const gitCommitId = splitDisplayName[5];

                if (nodeTypeVagrantAction === "kx-main" || nodeTypeVagrantAction === "kx-node") {
                    document.getElementById(nodeTypeVagrantAction + '-build-kx-version').innerText = kxVersion;
                    document.getElementById(nodeTypeVagrantAction + '-build-kube-version').innerText = kubeVersion;
                } else if (nodeTypeVagrantAction === "up" || nodeTypeVagrantAction === "destroy" || nodeTypeVagrantAction === "halt") {
                    document.getElementById('kx-launch-last-action').innerText = nodeTypeVagrantAction;
                    document.getElementById('kx-launch-build-kx-version').innerText = kxVersion;
                    document.getElementById('kx-launch-build-kube-version').innerText = kubeVersion;
                }
            })

            if (kxBuilds[0].timestamp !== null) {
                document.getElementById(nodeType + "-build-timestamp").innerText = new Date(kxBuilds[0].timestamp).toLocaleDateString() + " " + new Date(kxBuilds[0].timestamp).toLocaleTimeString();
            }
            if (kxBuilds[0].result !== null && kxBuilds[0].result !== '-') {
                if (kxBuilds[0].result === "ABORTED") {
                    styleClass = 'build-result build-result-aborted';
                } else if (kxBuilds[0].result === "FAILURE") {
                    styleClass = 'build-result build-result-failure';
                } else if (kxBuilds[0].result === "SUCCESS") {
                    styleClass = 'build-result build-result-success';
                } else {
                    styleClass = 'build-result build-result-neutral';
                }
                // Re-enable buttons to avoid double builds
                document.getElementById("build-" + nodeType + "-play-button").style.pointerEvents = "auto";
                document.getElementById("build-" + nodeType + "-play-button").style.cursor = "pointer";
                document.getElementById("build-" + nodeType + "-play-button").style.opacity = "1.0";

                // Write status to control panel
                document.getElementById(nodeType + "-build-result").innerHTML = '<span className="build-action-text-value build-action-text-value-result" style="width: 70px;">' + kxBuilds[0].result + '</span>';
                document.getElementById(nodeType + "-build-result").className = styleClass;
                document.getElementById(nodeType + "-build-number-link").innerHTML = "<a href='" + kxBuilds[0].url + "' target='_blank' rel='noopener noreferrer' style='font-weight: normal;'># " + kxBuilds[0].number + "</a>";
                buildStatus = 'DONE';
            }
            else {
                document.getElementById(nodeType + "-build-result").className = "";
                document.getElementById(nodeType + "-build-result").style.justifyContent = "center";
                document.getElementById(nodeType + "-build-result").innerHTML = "<div class='dot-flashing' style='background-color: white; margin-right: 15px; margin-left: 15px;'></div>";
                document.getElementById(nodeType + "-build-number-link").innerHTML = "<a href='" + kxBuilds[0].url + "' target='_blank' rel='noopener noreferrer' style='font-weight: normal;'># " + kxBuilds[0].number + "</a>";
            }
        } else {
            styleClass = 'build-result build-result-neutral';
            document.getElementById(nodeType + "-build-result").innerText = 'n/a';
            document.getElementById(nodeType + "-build-result").className = styleClass;
            document.getElementById(nodeType + "-build-timestamp").innerText = "not run yet";
            document.getElementById(nodeType + "-build-number-link").innerText = "-";
            document.getElementById(nodeType + '-build-kx-version').innerText = "-";
            document.getElementById(nodeType + '-build-kube-version').innerText = "-";
            buildStatus = "NOT RUN";
        }
    })
    return buildStatus;
}

async function getExtendedJobDetails(url) {
    let jenkinsCrumb = getCrumb().value;
    //let url = '/job/Actions/job/KX.AS.CODE_Runtime_Actions/42/api/json';
    let urlToFetch = url + '/api/json';

    let responseData = await fetch(urlToFetch, {
        method: 'GET',
        headers: {
            'Authorization': 'Basic ' + btoa('admin:admin'),
            'Jenkins-Crumb': jenkinsCrumb
        }
    }).then(data => {

        let responseText = data.text().then(function (text) {

            return text;
        });
        return responseText;
    });


    let jobDisplayName = JSON.parse(responseData);

    return responseData;
}


function filterBuilds(data) {
    let tmp = [];
    let nodeType;
    let paramArrayLocation

    const builds = data.builds;


    builds.map((e) => {
        let obj = {};
        obj["estimatedDuration"] = e.estimatedDuration ? e.estimatedDuration : -1;
        obj["id"] = e.id ? e.id : -1;
        obj["number"] = e.number ? e.number : -1;
        obj["result"] = e.result ? e.result : '-';
        obj["timestamp"] = e.timestamp ? e.timestamp : -1;
        obj["url"] = e.url ? e.url : '-';

        if (e.actions[0]._class === 'hudson.model.ParametersAction') {
            paramArrayLocation = 0;
        } else if (e.actions[1]._class === 'hudson.model.ParametersAction') {
            paramArrayLocation = 1;
        }




        e.actions[paramArrayLocation].parameters.filter((e) => {

            if (e.value === "kx-main") {
                nodeType = "kx-main";
            } else if (e.value === "kx-node") {
                nodeType = "kx-node";
            }

            if (e.value === "virtualbox") {
                obj["vm_type"] = "virtualbox"
                if (nodeType === "kx-main") {
                    obj["node_type"] = "kx-main"
                } else if (nodeType === "kx-node") {
                    obj["node_type"] = "kx-node"
                }
                tmp.push(obj)
                // return obj
            } else if (e.value === "parallels") {
                obj["vm_type"] = "parallels"
                if (nodeType === "kx-main") {
                    obj["node_type"] = "kx-main"
                } else if (nodeType === "kx-node") {
                    obj["node_type"] = "kx-node"
                }
                tmp.push(obj)
                // return obj
            } else if (e.value === "vmware-desktop") {
                obj["vm_type"] = "vmware-desktop"
                if (nodeType === "kx-main") {
                    obj["node_type"] = "kx-main"
                } else if (nodeType === "kx-node") {
                    obj["node_type"] = "kx-node"
                }
                tmp.push(obj)
                // return obj
            }
        })
    })


    return tmp
}

function filterDataByVmType(jsonData, v) {
    return jsonData.filter((e) => {
        if (e.vm_type === v) {
            return e
        }
    })
}

function filterDataByNodeType(jsonData, v) {
    return jsonData.filter((e) => {
        if (e.node_type === v) {
            return e
        }
    })
}

function filterDataByResult(jsonData) {
    return jsonData.filter((e) => {
        if (e.result === null) {
            return e
        }
    })
}

async function stopTriggeredBuild(job, nodeType) {
    //let job = 'KX.AS.CODE_Image_Builder';    // For debuging only
    //let nodeType = 'kx-main';    // For debuging only
    let jenkinsCrumb = getCrumb().value;
    getAllJenkinsBuilds(job).then(data => {
        const builds = filterBuilds(data);
        const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);

        const runningBuilds = (() => {
            if (nodeType === null) {

                return filterDataByResult(filteredBuilds);
            } else {

                const kxBuilds = filterDataByNodeType(filteredBuilds, nodeType);
                return filterDataByResult(kxBuilds);

            }
        })();

        if (runningBuilds.length > 0) {

            let urlToFetch = runningBuilds[0].url + 'stop';

            let response = fetch(urlToFetch, {
                method: 'POST',
                headers: {
                    'Authorization': 'Basic ' + btoa('admin:admin'),
                    'Jenkins-Crumb': jenkinsCrumb
                }
            }).then(data => {

            })
            let responseText = response.text();

        }
        refreshGetBuildJobList(job, nodeType)
    })
}

async function showConsoleLog(job, nodeType) {
    //let nodeType = 'kx-main';    // For debugging only
    //let job = 'KX.AS.CODE_Image_Builder';     // For debugging only
    let jenkinsCrumb = getCrumb().value;
    let consoleLogDiv;
    if (nodeType === 'kx-main') {
        consoleLogDiv = document.getElementById('kxMainBuildConsoleLog');
    } else if (nodeType === 'kx-node') {
        consoleLogDiv = document.getElementById('kxNodeBuildConsoleLog');
    } else if (nodeType === 'kx-launch') {
        consoleLogDiv = document.getElementById('kxLaunchBuildConsoleLog');
    }
    consoleLogDiv.innerHTML = "";
    getAllJenkinsBuilds(job).then(data => {


        const kxBuilds = (() => {
            const builds = filterBuilds(data);




            const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);



            if (nodeType === "kx-launch") {


                return filteredBuilds;
            } else {

                return filterDataByNodeType(filteredBuilds, nodeType);
            }
        })();
        //const kxBuilds = filterDataByNodeType(filteredBuilds, nodeType);

        if (kxBuilds.length > 0) {

            let urlToFetch = kxBuilds[0].url + 'consoleText';

            fetch(urlToFetch, {
                method: 'GET',
                headers: {
                    'Authorization': 'Basic ' + btoa('admin:admin'),
                    'Jenkins-Crumb': jenkinsCrumb
                }
            }).then(data => {
                data.text().then(consoleLog => {



                    let consoleLine;
                    let lines = consoleLog.split(/[\r\n]+/);


                    let n;
                    if (lines.length > 50) {
                        n = lines.length - 50;
                    } else {
                        n = lines.length;
                    }

                    let numLinesToIgnore = 0;
                    for (let line = n; line < lines.length; line++) {
                        if (lines[line].includes('[Pipeline]')) {
                            numLinesToIgnore++;
                        }
                    }

                    let linesToReturn = 12;


                    n = lines.length - (linesToReturn + numLinesToIgnore);
                    for (let line = n; line < lines.length; line++) {

                        if ( ! lines[line].includes('[Pipeline]') ) {
                            consoleLine = lines[line] + '<br>';
                            consoleLine = consoleLine.replace(/FAILURE/g, '<span style="color: var(--kx-error-red-100)">FAILURE</span>')
                            consoleLine = consoleLine.replace(/ERROR/g, '<span style="color: var(--kx-error-red-100)">ERROR</span>')
                            consoleLine = consoleLine.replace(/SUCCESS/g, '<span style="color: var(--kx-success-green-100)">SUCCESS</span>')
                            consoleLogDiv.innerHTML += consoleLine;

                        } else {

                        }
                    }
                });
            })
        } else {
            consoleLogDiv.innerHTML += "<i>No " + nodeType + " build has been run yet for " + document.getElementById("profiles").value + "</i>";
        }
    })
}

async function openFullConsoleLog(job, nodeType) {
    getAllJenkinsBuilds(job).then(data => {
        const builds = filterBuilds(data);
        const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);


        const kxBuilds = (() => {
            const builds = filterBuilds(data);




            const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);



            if (nodeType === "kx-launch") {


                return filteredBuilds;
            } else {

                return filterDataByNodeType(filteredBuilds, nodeType);
            }
        })();

        if (kxBuilds.length > 0) {
            let urlToOpen = kxBuilds[0].url + 'console';

            window.open(urlToOpen, '_blank').focus();
        }
    })
}

function formatSeconds(seconds) {
    let numDays = Math.floor((seconds % 31536000) / 86400);
    let numHours = Math.floor(((seconds % 31536000) % 86400) / 3600);
    let numMinutes = Math.floor((((seconds % 31536000) % 86400) % 3600) / 60);
    let numSeconds = Math.floor((((seconds % 31536000) % 86400) % 3600) % 60);
    return numDays + " days " + numHours + " hours " + numMinutes + " minutes " + numSeconds + " seconds";
}

function getCrumb() {
    const xhr = new XMLHttpRequest(),
        method = "GET",
        url = "/crumbIssuer/api/json";

    xhr.open(method, url, true);
    xhr.onreadystatechange = function () {
        // In local files, status is 0 upon success in Mozilla Firefox
        if (xhr.readyState === XMLHttpRequest.DONE) {
            let status = xhr.status;
            if (status === 0 || (status >= 200 && status < 400)) {
                // The request has been completed successfully

                let crumb = JSON.parse(xhr.responseText).crumb;

            } else {
                // Oh no! There has been an error with the request!
            }
        }
    };
    xhr.send();
    return crumb;
}

async function getAllJenkinsBuilds(job) {
    let jenkinsCrumb = getCrumb().value;
    let fetchUrl = '/job/Actions/job/' + job + '/api/json?tree=builds[number,status,timestamp,id,result,url,estimatedDuration,actions[parameters[name,value]]]'
    let response = await fetch(fetchUrl, {
        method: 'GET',
        headers: {
            'Authorization': 'Basic ' + btoa('admin:admin'),
            'Jenkins-Crumb': jenkinsCrumb
        }
    });

    if (!response.ok) {
        const message = 'An error has occurred fetching JSON from Jenkins: ' + response.status;
        throw new Error(message);
    }
    return response.json();
}

getAllJenkinsBuilds().catch(error => {
    error.message;
});


function populateReviewTable() {

    document.getElementById("summary-profile-value").innerText = document.getElementById("profiles").value;
    document.getElementById("summary-start-mode-value").innerText = document.getElementById('concatenated-profile-selection').value.split(';')[1];
    document.getElementById("summary-standalone-mode-value").innerText = document.getElementById("general-param-standalone-mode-toggle").value;
    document.getElementById("summary-workloads-on-master-value").innerText = document.getElementById("general-param-workloads-on-master-toggle").value;
    document.getElementById("summary-disable-desktop-value").innerText = document.getElementById("general-param-disable-desktop-toggle").value;
    let numMainNodes = parseInt(document.getElementById("counter_value_main_node_count_value").innerText);
    document.getElementById("summary-main-nodes-number-value").innerText = numMainNodes;
    let numWorkerNodes = parseInt(document.getElementById("counter_value_worker_node_count_value").innerText);
    document.getElementById("summary-worker-nodes-number-value").innerText = numWorkerNodes;
    document.getElementById("summary-start-mode-value").innerText = document.getElementById('concatenated-profile-selection').value.split(';')[1];
    document.getElementById("summary-orchestrator-value").innerText = document.getElementById('concatenated-profile-selection').value.split(';')[2];
    document.getElementById("summary-profile-value").innerText = document.getElementById("profiles").value;
    if (document.getElementById("concatenated-templates-list").value === "" || ! document.getElementById("concatenated-templates-list").value || document.getElementById("concatenated-templates-list").value === "null") {
        document.getElementById("list-templates-to-install").innerHTML = "<i>None</i>"
        document.getElementById("list-templates-tooltip-text").innerText = "No application group template has been selected";
    } else {
        let templatesList = document.getElementById("concatenated-templates-list").value;
        let templatesListArray = templatesList.split(',');
        document.getElementById("list-templates-to-install").innerText = templatesListArray.length + " templates";
        document.getElementById("list-templates-tooltip-text").innerText = templatesListArray;
    }
}

async function performRuntimeAction(vagrantAction) {

    document.getElementById("kx-launch-build-result").className = "";
    document.getElementById("kx-launch-build-result").style.justifyContent = "center";
    document.getElementById("kx-launch-build-result").innerHTML = "<div class='dot-flashing' style='background-color: white; margin-right: 15px; margin-left: 15px;'></div>";

    // Disable buttons to avoid double builds
    document.getElementById("build-kx-launch-play-button").style.pointerEvents = "none";
    document.getElementById("build-kx-launch-play-button").style.cursor = "not-allowed";
    document.getElementById("build-kx-launch-play-button").style.opacity = "0.3";

    disableControlPanel(arguments.callee.name);

    let jenkinsCrumb = getCrumb().value;
    let formData = new FormData();

    let kxMainVersionToDeploy
    let kxNodeVersionToDeploy

    let cloudKxMainVersion = document.getElementById("kx-main-vagrant-cloud-box-version").value;
    let cloudKxNodeVersion = document.getElementById("kx-node-vagrant-cloud-box-version").value;
    let localKxMainVersion = document.getElementById("kx-main-local-box-version").value;
    let localKxNodeVersion = document.getElementById("kx-node-local-box-version").value;

    if ( localKxMainVersion.toString() > cloudKxMainVersion.toString() ) {
        kxMainVersionToDeploy = localKxMainVersion
    } else {
        kxMainVersionToDeploy = cloudKxMainVersion
    }

    if ( localKxNodeVersion.toString() > cloudKxNodeVersion.toString() ) {
        kxNodeVersionToDeploy = localKxNodeVersion
    } else {
        kxNodeVersionToDeploy = cloudKxNodeVersion
    }

    formData.append('kx_main_version', kxMainVersionToDeploy);
    formData.append('kx_node_version', kxNodeVersionToDeploy);
    formData.append('num_kx_main_nodes', document.getElementById('counter_value_main_node_count_value').innerText);
    formData.append('num_kx_worker_nodes', document.getElementById('counter_value_worker_node_count_value').innerText);
    formData.append('dockerhub_email', '');
    formData.append('profile', document.getElementById('profiles').value);
    formData.append('profile_path', getProfilePath());
    formData.append('vagrant_action', vagrantAction);
    const config = {
        method: 'POST',
        headers: {
            'Authorization': 'Basic ' + btoa('admin:admin'),
            'Jenkins-Crumb': jenkinsCrumb
        },
        body: formData
    }
    let response = await fetch('/job/Actions/job/KX.AS.CODE_Runtime_Actions/buildWithParameters', config);
    let data = await response.text();

    await new Promise(resolve => setTimeout(resolve, 10000))
    enableControlPanel(arguments.callee.name);
    refreshGetBuildJobList("KX.AS.CODE_Runtime_Actions", "kx-launch");

}

function updateProfileAndPrereqsCheckTab(selectedProfileIndex) {
    getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-main");
    getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-node");
    getAvailableLocalBoxes();
    getAvailableCloudBoxes()
    compareVersions();
    checkVagrantPreRequisites();
    update_selected_value(selectedProfileIndex);
}

function displayOrHideKxAlreadyRunningWarning(mainNodes) {
    if (mainNodes > 0 ) {
        document.getElementById("kx-launch-running-vms").style.display = "inline-block";
    } else {
        document.getElementById("kx-launch-running-vms").style.display = "none";
    }
}

function getTemplates(selectedTemplate) {

    let templateDefinitionsArray = document.getElementById('template-definitions-array').value;
    let definitionsArray = JSON.parse(templateDefinitionsArray);
    let templateId;

    try {
        if ( ! selectedTemplate ) {
            selectedTemplate = document.getElementById("templates").value;
            selectedTemplate = selectedTemplate.replaceAll("*", "");
        }

        if ( selectedTemplate !== "-- Select Templates --" ) {
            let templateDefinitionArray = definitionsArray.find(template => template.template_name === selectedTemplate);
            templateId = templateDefinitionArray.template_id;
        } else {
            templateId = -1;
        }
        getTemplateComponents(templateId);
    } catch (e) {
        console.debug(e)
    }
    return [ definitionsArray, templateId];
}

function getComponentsArray(templateId) {
    let templateComponentsArray = document.getElementById('template-components-array').value;
    let componentsArray = JSON.parse(templateComponentsArray);
    let componentArray = componentsArray.findAll(templateComponent => templateComponent.template_id === templateId);
    return componentArray;
}

function getTemplateComponents(templateId) {
    let componentItemInnerHTML;
    document.getElementById('components-list').innerHTML = "";

    if ( templateId === -1  || templateId === null || templateId === '' ) {

        let shortcutIconPlaceholder = 'application-cog-outline.svg';
        let categoryPlaceholder = 'Optional';
        let shortcutTextPlaceholder = 'Templates';
        let descriptionPlaceholder = 'Select from a pre-defined list of integrated application groups';

        iDiv = document.createElement('div');
        iDiv.id = "placeholder-template";
        iDiv.className = 'component-item';

        componentItemInnerHTML = '<div class="component-outer-div">' +
            '<div class="component-image-div">' +
            '<img src="/userContent/icons/' + shortcutIconPlaceholder + '" width="60">' +
            '</div>' +
            '<div class="component-outer-text-div">' +
            '<div class="component-category-div">' + categoryPlaceholder + '</div>' +
            '<div class="component-title-div">' + shortcutTextPlaceholder + '</div>' +
            '</div>' +
            '</div>' +
            '<div>' +
            '   <span class="component-description-span">' + descriptionPlaceholder + '</span>' +
            '</div>';


        iDiv.innerHTML = componentItemInnerHTML;
        document.getElementById('components-list').appendChild(iDiv);

    } else {
        let shortcutIcon
        try {
            let componentArray = getComponentsArray(templateId)

            for (let i = 0; i < componentArray.size(); i++) {

                iDiv = document.createElement('div');
                iDiv.id = componentArray[i].component;
                iDiv.className = 'component-item';

                if (componentArray[i].shortcutText !== "null" && componentArray[i].shortcutIcon !== "null") {

                    if (componentArray[i].shortcutIcon === "null") {
                        shortcutIcon = 'application-cog-outline.svg';
                    } else {
                        shortcutIcon = componentArray[i].shortcutIcon;
                    }

                    componentItemInnerHTML = '<div class="component-outer-div">' +
                        '<div class="component-image-div">' +
                        '<img src="/userContent/icons/' + shortcutIcon + '" width="60">' +
                        '</div>' +
                        '<div class="component-outer-text-div">' +
                        '<div class="component-category-div">' + componentArray[i].category.replace('_', ' ') + '</div>' +
                        '<div class="component-title-div">' + componentArray[i].shortcutText + '</div>' +
                        '</div>' +
                        '</div>' +
                        '<div>' +
                        '   <span class="component-description-span">' + componentArray[i].description.replace(/(.{50})..+/, "$1…") + '</span>' +
                        '</div>';

                    iDiv.innerHTML = componentItemInnerHTML;
                    document.getElementById('components-list').appendChild(iDiv);
                }
            }
        } catch (e) {
            console.debug(e);
        }
    }

}

function populate_selected_template_list(selectedTemplate) {
    let selectedTemplateId = getTemplates(selectedTemplate)[1];
    let selectedTemplatesListSpan = document.getElementById("selected-components-list");
    let selectedComponentItem = document.createElement("span");
    let componentArray = getComponentsArray(selectedTemplateId);
    let componentsAlternateText = "";

    for (let i = 0; i < componentArray.size(); i++) {
        if ( componentsAlternateText === "" ) {
            componentsAlternateText = componentArray[i].shortcutText;
        } else {
            componentsAlternateText = componentsAlternateText + ", " + componentArray[i].shortcutText;
        }
    }
    selectedComponentItem.innerHTML = '<span class="selected-component-item"><div class="tooltip-info"><span class="info-span"><img id="selected-component-item-icon-' + selectedTemplate + '" src="/userContent/icons/close-box-outline.svg" class="selected-component-item-icon svg-white" title="Remove Template" alt="Remove Template" onclick="removeTemplateFromProfile(this.id)" /> ' + selectedTemplate + '<span class="tooltiptext">' + componentsAlternateText + '</span></span></div></span>'
    selectedTemplatesListSpan.appendChild(selectedComponentItem);
}

function remove_selected_template_list_item(selectedTemplate) {
    try {
        let selectedTemplates = document.getElementsByClassName("selected-component-item-icon");
        let selectedTemplateListItemSpan;
        for (let i = 0; i < selectedTemplates.length; i++) {
            selectedTemplateListItemSpan = document.getElementById(selectedTemplate);
            if (selectedTemplates[i].id === selectedTemplateListItemSpan.id) {
                selectedTemplateListItemSpan.parentElement.parentElement.parentElement.remove()
            }
        }
    } catch (e) {
        console.debug(e);
    }
}

function populate_template_option_list(selectedTemplate) {
    let templateNameOptionDisplayText;
    let templateNameOption;
    let selectedIndex = 0;
    selectedTemplate = (typeof selectedTemplate === 'undefined') ? '-- Select Templates --' : selectedTemplate;
    let selectedTemplateList = document.getElementById("concatenated-templates-list").value.split(',');
    let templates = getTemplates()[0];
    document.getElementById("templates").options[0] = new Option("-- Select Templates --", "-- Select Templates --");
    for ( let i = 0; i < templates.length; i++ ) {
        if ( selectedTemplateList.includes(templates[i].template_name) === true ) {
            templateNameOptionDisplayText = templates[i].template_name + " \u2606";
            if ( selectedTemplate === templates[i].template_name ) {
                selectedIndex = i+1;
            }
        } else {
            templateNameOptionDisplayText = templates[i].template_name;
        }
        templateNameOption = templates[i].template_name;
        document.getElementById("templates").options[i+1] = new Option(templateNameOptionDisplayText, templateNameOption);
    }

    if ( selectedTemplate !== '-- Select Templates --') {
        let e = document.getElementById("templates");
        if ( e.options[selectedIndex].value === selectedTemplate ) {
            document.getElementById("templates").value = selectedTemplate;
            document.getElementById('button_remove_template').setAttribute( "onClick", "removeTemplateFromProfile();" );
            document.getElementById('button_add_template').setAttribute( "onClick", "" );
            document.getElementById('button_remove_template').style.opacity = "1.0";
            document.getElementById('button_add_template').style.opacity = "0.2";
            document.getElementById('button_remove_template').style.cursor = "pointer";
            document.getElementById('button_add_template').style.cursor = "not-allowed";
        } else {
            document.getElementById("templates").value = selectedTemplate;
            document.getElementById('button_remove_template').setAttribute( "onClick", "" );
            document.getElementById('button_add_template').setAttribute( "onClick", "addTemplateToProfile();" );
            document.getElementById('button_remove_template').style.opacity = "0.2";
            document.getElementById('button_add_template').style.opacity = "1.0";
            document.getElementById('button_remove_template').style.cursor = "not-allowed";
            document.getElementById('button_add_template').style.cursor = "pointer";
        }
    } else {
        document.getElementById("templates").value = document.getElementById("templates").options[0].value;
        document.getElementById('button_remove_template').setAttribute( "onClick", "" );
        document.getElementById('button_add_template').setAttribute( "onClick", "" );
        document.getElementById('button_remove_template').style.opacity = "0.2";
        document.getElementById('button_add_template').style.opacity = "0.2";
        document.getElementById('button_remove_template').style.cursor = "not-allowed";
        document.getElementById('button_add_template').style.cursor = "not-allowed";
    }
}

function selectTemplatesAlreadyExistingInProfile(existingTemplates) {
    templateRows = existingTemplates.split(",");
    document.getElementById("selected-components-list").innerText = ""
    for (let template of templateRows) {
        let selectedTemplate = template;
        addTemplateToProfile(selectedTemplate);
    }
}

function addTemplateToProfile(selectedTemplate) {
    if ( ! selectedTemplate ) {
        selectedTemplate = document.getElementById("templates").value;
    }
    if ( selectedTemplate !== "-- Select Templates --" ) {
        let selectedTemplateList = document.getElementById("concatenated-templates-list").value.split(',');
        selectedTemplate = selectedTemplate.replaceAll("*", "");
        selectedTemplateList.push(selectedTemplate);
        let uniqueSelectedTemplateList = [...new Set(selectedTemplateList.sort())];
        document.getElementById("concatenated-templates-list").value = uniqueSelectedTemplateList.toString().replace(/^,/, '');
        populate_template_option_list(selectedTemplate);
        populate_selected_template_list(selectedTemplate);
        triggerChoiceParameterUpdate('concatenated-templates-list');
    }
}

function removeTemplateFromProfile(templateToRemoveId) {
    let selectedTemplate;
    try {
        if ( ! templateToRemoveId ) {
            selectedTemplate = document.getElementById("templates").value;
        } else {
            selectedTemplate = templateToRemoveId.replaceAll("selected-component-item-icon-","");
        }
        selectedTemplate = selectedTemplate.replaceAll("*", "");
        let selectedTemplateList = document.getElementById("concatenated-templates-list").value.split(',');
        if (selectedTemplateList.includes(selectedTemplate) === true || selectedTemplateList.includes(selectedTemplate + "*") === true) {
            selectedTemplateList = arrayRemove(selectedTemplateList, selectedTemplate)
            document.getElementById("concatenated-templates-list").value = selectedTemplateList.toString();
            populate_template_option_list(selectedTemplate);
            remove_selected_template_list_item("selected-component-item-icon-" + selectedTemplate);
            triggerChoiceParameterUpdate('concatenated-templates-list');
        }
    } catch (e) {
        console.debug(e)
    }
}

function hideDiv() {
    document.getElementById("templates-div").style.display = "none";
}

function arrayRemove(array, value) {
    return array.filter(function(element){
        return element != value;
    });
}

function hideParameterDivs() {
    let configDivs = [
        "headline-select-profile-div",
        "select-profile-div",
        "prerequisites-div",
        "profile-builds-div",
        "standalone-toggle-div",
        "worker-cpu-count-div",
        "worker-node-count-div",
        "main-node-count-div",
        "local-storage-div",
        "main-memory-div",
        "general-parameters-div",
        "workloads-on-master-div",
        "disable-desktop-div",
        "main-cpu-count-div",
        "worker-memory-div",
        "network-storage-div",
        "headline-main-div",
        "headline-workers-div",
        "headline-storage-div",
        "templates-div",
        "user-provisioning-div",
        "custom-variables-div",
        "review-and-launch-div"
    ];

    configDivs.forEach(function(item) {
        try {
            for (let i = 0; i < 5; i++) {
                document.getElementById(item).style.display = "none";
                if ( document.getElementById(item).style.display === "none") {
                    break;
                }
                sleep(1);
            }
        } catch (e) {
            console.debug(e);
        }
    })
}

function sleep(seconds){
    var waitUntil = new Date().getTime() + seconds*1000;
    while(new Date().getTime() < waitUntil)
        true;
}

async function disableControlPanel(caller) {
    document.getElementById('config-panel-outer-div').style.pointerEvents = "none";
    document.getElementById('config-panel-outer-div').style.opacity = "0.5";
}

async function enableControlPanel(caller) {
    if (caller === "change_panel_selection") {
        await new Promise(resolve => setTimeout(resolve, 5000));
    } else {
        await new Promise(resolve => setTimeout(resolve, 4000));
    }
    document.getElementById('config-panel-outer-div').style.pointerEvents="auto";
    document.getElementById('config-panel-outer-div').style.opacity="1.0";
    sessionStorage.disableControlPanelExecutedOnce = true;

}

function change_panel_selection(config_panel) {

    if (config_panel === "config-panel-general-params") {
        disableControlPanel(arguments.callee.name);
    }

    if ( document.getElementById('system-prerequisites-check').value === "failed" ) {
        config_panel = "config-panel-profile-selection";
    }
    waitForElement(config_panel,function(){
    });

    waitForElement('config-placeholder',function(){
    });

    let configPanelDivsInPlaceholderDiv = document.getElementById('config-placeholder').children;

    for (let i = 0; i < configPanelDivsInPlaceholderDiv.length; i++) {
        if ( configPanelDivsInPlaceholderDiv[i].style.display !== "none" ) {

        }
    }

    const configPanels = [
        "config-panel-profile-selection",
        "config-panel-general-params",
        "config-panel-kx-main-config",
        "config-panel-storage-config",
        "config-panel-template-selection",
        "config-panel-user-provisioning",
        "config-panel-custom-variables",
        "config-panel-kx-summary-start"
    ];
    let configPanelIcon
    configPanels.forEach(function(item) {
        configPanelIcon = item + "-icon";
        if ( item === config_panel ) {
            hideParameterDivs();
            document.getElementById(item).className = "config-tab-selected";
            document.getElementById(configPanelIcon).className = "config-panel-icon svg-blue";
            switch (item) {
                case "config-panel-profile-selection":

                    moveDivToConfigPanel("headline-select-profile-div");
                    moveDivToConfigPanel("select-profile-div");
                    moveDivToConfigPanel("prerequisites-div");
                    moveDivToConfigPanel("profile-builds-div");
                    updateNavigationFooter("", "config-panel-general-params");
                    break;
                case "config-panel-general-params":
                    moveDivToConfigPanel("general-parameters-div");
                    moveDivToConfigPanel("standalone-toggle-div");
                    moveDivToConfigPanel("workloads-on-master-div");
                    moveDivToConfigPanel("disable-desktop-div");
                    updateNavigationFooter("config-panel-profile-selection", "config-panel-kx-main-config");
                    break;
                case "config-panel-kx-main-config":
                    moveDivToConfigPanel("headline-main-div");
                    moveDivToConfigPanel("main-node-count-div");
                    moveDivToConfigPanel("main-cpu-count-div");
                    moveDivToConfigPanel("main-memory-div");
                    moveDivToConfigPanel("headline-workers-div");
                    moveDivToConfigPanel("worker-node-count-div");
                    moveDivToConfigPanel("worker-cpu-count-div");
                    moveDivToConfigPanel("worker-memory-div");
                    updateNavigationFooter("config-panel-general-params", "config-panel-storage-config");
                    break;
                case "config-panel-storage-config":
                    moveDivToConfigPanel("headline-storage-div");
                    moveDivToConfigPanel("network-storage-div");
                    moveDivToConfigPanel("local-storage-div");
                    updateNavigationFooter("config-panel-kx-main-config", "config-panel-template-selection");
                    break;
                case "config-panel-template-selection":
                    moveDivToConfigPanel("templates-div");
                    updateNavigationFooter("config-panel-storage-config", "config-panel-user-provisioning");
                    break;
                case "config-panel-user-provisioning":
                    moveDivToConfigPanel("user-provisioning-div");
                    updateNavigationFooter("config-panel-template-selection", "config-panel-custom-variables");
                    break;
                case "config-panel-custom-variables":
                    moveDivToConfigPanel("custom-variables-div");
                    updateNavigationFooter("config-panel-user-provisioning", "config-panel-kx-summary-start");
                    break;
                case "config-panel-kx-summary-start":
                    populateReviewTable();
                    getBuildJobListForProfile('KX.AS.CODE_Runtime_Actions', 'kx-launch');
                    moveDivToConfigPanel("review-and-launch-div");
                    updateNavigationFooter("config-panel-custom-variables", "");
                    break;
            }
        } else {
            if ( document.getElementById('system-prerequisites-check').value === "failed" ) {
                document.getElementById(item).className = "config-tab-disabled";
            } else {
                document.getElementById(item).className = "config-tab";
            }
            document.getElementById(configPanelIcon).className = "config-panel-icon svg-white";
        }
    })
    if (config_panel === "config-panel-general-params") {
        enableControlPanel(arguments.callee.name);
    }

}

function removeAllChildNodes(parent) {
    while (parent.firstChild) {
        parent.removeChild(parent.firstChild);
    }
}

function moveDivToConfigPanel(configDiv) {
    try {
        let currentParent = document.getElementById(configDiv).parentNode.id;
        let divConfigPanelParent = document.getElementById("config-placeholder");
        let divConfigPanelChild = document.getElementById(configDiv);
        let divChildConfigs = document.querySelectorAll('[id=' + configDiv + ']');
        if ( divChildConfigs.length <= 1 && currentParent !== "config-placeholder" ) {
            divConfigPanelParent.appendChild(divConfigPanelChild);
        } else if ( divChildConfigs.length > 1) {
            divChildConfigs.forEach(function(item) {
                if ( item.parentNode.id === 'config-placeholder' ) {
                    divConfigPanelParent.removeChild(item);
                };
            });
            currentParent = document.getElementById(configDiv).parentNode.id;
            divConfigPanelChild = document.getElementById(configDiv);
            divConfigPanelParent.appendChild(divConfigPanelChild);
        }
        let divConfigNumber = document.querySelectorAll('[id=' + configDiv + ']').length;
        let displayType;
        if ( configDiv === "system-check-div" || configDiv === "review-and-launch-div" ) {
            displayType = "block";
            if ( configDiv === "review-and-launch-div" ) {
                populateReviewTable();
            }
        } else if ( configDiv === "select-profile-div") {
            displayType = "inline-flex";
        } else {
            displayType = "block";
        }
        divConfigPanelChild.style.display = displayType;
    } catch (e) {
        console.debug(e);
    }
}

function updateNavigationFooter(previous, next) {

    let chevronsToShow;
    document.getElementById('config-panel-footer-left-nav-div').setAttribute( "onClick", "change_panel_selection('" + previous +"')" );
    document.getElementById('config-panel-footer-right-nav-div').setAttribute( "onClick", "change_panel_selection('" + next + "')" );

    if ( previous === '') {
        chevronsToShow = "right-only";
    } else if ( next === '') {
        chevronsToShow = "left-only";
    }  else {
        chevronsToShow = "both";
    }

    if ( chevronsToShow === "both" ) {
        document.getElementById("config-panel-footer-left-nav-div").style.display = "block";
        document.getElementById("config-panel-footer-right-nav-div").style.display = "block";
        document.getElementById("config-navigator-footer").style.justifyContent = "space-between";
    } else if ( chevronsToShow === "left-only" ) {
        document.getElementById("config-panel-footer-left-nav-div").style.display = "block";
        document.getElementById("config-panel-footer-right-nav-div").style.display = "none";
        document.getElementById("config-navigator-footer").style.justifyContent = "flex-start";
    } else {
        document.getElementById("config-panel-footer-left-nav-div").style.display = "none";
        document.getElementById("config-panel-footer-right-nav-div").style.display = "block";
        document.getElementById("config-navigator-footer").style.justifyContent = "flex-end";
    }
}

function loadFirstConfigPanel() {
    waitForElement('profile-builds-div',function() {
        document.getElementById("grid-spinner").style.display = "none";
        change_panel_selection('config-panel-profile-selection');
    });
}

function getAvailableLocalBoxes() {
    let localVagrantBoxMainVersion;
    let localVagrantBoxNodeVersion;
    let selectedProfile = document.getElementById("profiles").value;
    try {
        switch (selectedProfile) {
            case "virtualbox":
                localVagrantBoxMainVersion = getVirtualboxLocalVagrantBoxMainVersion();
                localVagrantBoxNodeVersion = getVirtualboxLocalVagrantBoxNodeVersion();
                break;
            case "vmware-desktop":
                localVagrantBoxMainVersion = getVmwareLocalVagrantBoxMainVersion();
                localVagrantBoxNodeVersion = getVmwareLocalVagrantBoxNodeVersion();
                break;
            case "parallels":
                localVagrantBoxMainVersion = getParallelsLocalVagrantBoxMainVersion();
                localVagrantBoxNodeVersion = getParallelsLocalVagrantBoxNodeVersion();
                break;
            default:
                console.debug("Weird, box type not known. Normally the box type is either VirtualBox, VMWare or Parallels");
        }
        if ( localVagrantBoxMainVersion !== "null" && localVagrantBoxMainVersion !== "-1") {
            document.getElementById("kx-main-local-box-version").innerHTML = localVagrantBoxMainVersion;
            document.getElementById("kx-main-local-box-version").value = localVagrantBoxMainVersion;
            document.getElementById("local-main-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
            document.getElementById("local-main-version-status-svg").className = "checklist-status-icon svg-bright-green";
        } else {
            document.getElementById("kx-main-local-box-version").innerHTML = "<i>- (Optional)</i>";
            document.getElementById("kx-main-local-box-version").value = -1;
            document.getElementById("local-main-version-status-svg").src = "/userContent/icons/alert-outline.svg";
            document.getElementById("local-main-version-status-svg").className = "checklist-status-icon svg-orange-red";
        }

        if ( localVagrantBoxNodeVersion !== "null" && localVagrantBoxNodeVersion !== "-1") {
            document.getElementById("kx-node-local-box-version").innerHTML = localVagrantBoxNodeVersion;
            document.getElementById("kx-node-local-box-version").value = localVagrantBoxNodeVersion;
            document.getElementById("local-node-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
            document.getElementById("local-node-version-status-svg").className = "checklist-status-icon svg-bright-green";
        } else {
            document.getElementById("kx-node-local-box-version").innerHTML = "<i>- (Optional)</i>";
            document.getElementById("kx-node-local-box-version").value = -1;
            document.getElementById("local-node-version-status-svg").src = "/userContent/icons/alert-outline.svg";
            document.getElementById("local-node-version-status-svg").className = "checklist-status-icon svg-orange-red";
            document.getElementById('standalone-mode-toggle').value = "true";
            document.getElementById('workloads_on_master_checkbox').value = "true";
        }

    } catch (e) {
        console.debug("Error getting box versions: " + e);
    }
}

function getAvailableCloudBoxes() {
    let cloudVagrantBoxMainVersion;
    let cloudVagrantBoxNodeVersion;
    let selectedProfile = document.getElementById("profiles").value;
    try {
        switch (selectedProfile) {
            case "virtualbox":
                cloudVagrantBoxMainVersion = getVirtualboxKxMainVagrantCloudVersion();
                cloudVagrantBoxNodeVersion = getVirtualboxKxNodeVagrantCloudVersion();
                break;
            case "vmware-desktop":
                cloudVagrantBoxMainVersion = getVmwareDesktopKxMainVagrantCloudVersion();
                cloudVagrantBoxNodeVersion = getVmwareDesktopKxNodeVagrantCloudVersion();
                break;
            case "parallels":
                cloudVagrantBoxMainVersion = getParallelsKxMainVagrantCloudVersion();
                cloudVagrantBoxNodeVersion = getParallelsKxNodeVagrantCloudVersion();
                break;
            default:
                console.debug("Weird, box type not known. Normally the box type is either VirtualBox, VMWare or Parallels");
        }
        if ( cloudVagrantBoxMainVersion !== "null" && cloudVagrantBoxMainVersion !== "-1" ) {
            document.getElementById("kx-main-vagrant-cloud-box-version").innerHTML = cloudVagrantBoxMainVersion;
            document.getElementById("kx-main-vagrant-cloud-box-version").value = cloudVagrantBoxMainVersion;
            document.getElementById("cloud-main-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
            document.getElementById("cloud-main-version-status-svg").className = "checklist-status-icon svg-bright-green";
        } else {
            document.getElementById("kx-main-vagrant-cloud-box-version").innerHTML = "<i>Not found</i>";
            document.getElementById("kx-main-vagrant-cloud-box-version").value = -1;
            document.getElementById("cloud-main-version-status-svg").src = "/userContent/icons/alert-outline.svg";
            document.getElementById("cloud-main-version-status-svg").className = "checklist-status-icon svg-orange-red";
        }

        if ( cloudVagrantBoxNodeVersion !== "null" && cloudVagrantBoxNodeVersion !== "-1") {
            document.getElementById("kx-node-vagrant-cloud-box-version").innerHTML = cloudVagrantBoxNodeVersion;
            document.getElementById("kx-node-vagrant-cloud-box-version").value = cloudVagrantBoxNodeVersion;
            document.getElementById("cloud-node-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
            document.getElementById("cloud-node-version-status-svg").className = "checklist-status-icon svg-bright-green";
        } else {
            document.getElementById("kx-node-vagrant-cloud-box-version").innerHTML = "<i>Not found</i>";
            document.getElementById("kx-node-vagrant-cloud-box-version").value = -1;
            document.getElementById("cloud-node-version-status-svg").src = "/userContent/icons/alert-outline.svg";
            document.getElementById("cloud-node-version-status-svg").className = "checklist-status-icon svg-orange-red";
            document.getElementById('standalone-mode-toggle').value = "true";
            document.getElementById('workloads_on_master_checkbox').value = "true";
        }

    } catch (e) {
        console.debug("Error getting box versions: " + e);
    }
}

function checkVagrantPreRequisites() {
    let selectedProfile = document.getElementById("profiles").value;
    let virtualizationExecutableExists = "";
    let vagrantPluginInstalled = "";
    if ( selectedProfile === "virtualbox" ) {
        virtualizationExecutableExists = getVboxExecutableExists();
        vagrantPluginInstalled = getVboxVagrantPluginInstalled();
    } else if ( selectedProfile === "vmware-desktop" ) {
        virtualizationExecutableExists = getVmwareExecutableExists();
        vagrantPluginInstalled = getVmwareVagrantPluginInstalled();
    } else if ( selectedProfile === "parallels" ) {
        virtualizationExecutableExists = getParallelsExecutableExists();
        vagrantPluginInstalled = getParallelsPluginInstalled();
    }

    if ( virtualizationExecutableExists === "true" ) {
        document.getElementById("virtualization-svg").className = "checklist-status-icon svg-bright-green";
        document.getElementById("virtualization-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
        document.getElementById("virtualization-text").innerHTML = selectedProfile.charAt(0).toUpperCase() + selectedProfile.slice(1) + " is installed";
    } else {
        document.getElementById("virtualization-svg").className = "checklist-status-icon svg-orange-red";
        document.getElementById("virtualization-svg").src = "/userContent/icons/alert-outline.svg";
        document.getElementById("virtualization-text").innerHTML = selectedProfile.charAt(0).toUpperCase() + selectedProfile.slice(1) + " could not be found";
    }

    if ( vagrantPluginInstalled  === "true" ) {
        document.getElementById("vagrant-plugin-svg").className = "checklist-status-icon svg-bright-green";
        document.getElementById("vagrant-plugin-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
        document.getElementById("vagrant-plugin-text").innerHTML = "The required Vagrant plugin is installed";
    } else {
        document.getElementById("vagrant-plugin-svg").className = "checklist-status-icon svg-orange-red";
        document.getElementById("vagrant-plugin-svg").src = "/userContent/icons/alert-outline.svg";
        document.getElementById("vagrant-plugin-text").innerHTML = "The required Vagrant plugin could not be located";
    }
}

function updateProfileSelection(selectedProfileIndex) {
    if ( ! selectedProfileIndex ) {
        selectedProfileIndex = document.getElementById("profiles").selectedIndex;
    }
    let selectedProfile = document.getElementById("profiles").options[selectedProfileIndex].text
    let parallelsExecutableExists = getParallelsExecutableExists();
    let vboxExecutableExists = getVboxExecutableExists();
    let vmwareExecutableExists = getVmwareExecutableExists();
    let vboxVagrantPluginInstalled = getVboxVagrantPluginInstalled();
    let vmwareVagrantPluginInstalled = getVmwareVagrantPluginInstalled();
    let parallelsPluginInstalled = getParallelsPluginInstalled();
    let defaultProfile = selectedProfile;
    let prerequisitesCheckResult = "";
    let selectedProfileCheckResult = "";
    if (sessionStorage.getItem('hasCodeRunBefore') === null) {
        if ( vboxExecutableExists === "true" && vboxVagrantPluginInstalled === "true" ) {
            defaultProfile = "virtualbox";
            updateStartModeSelection(document.getElementById("virtualbox-profile-selected-startup-mode").value);
            updateOrchestratorSelection(document.getElementById("virtualbox-profile-selected-orchestrator").value);
            if (selectedProfile === "virtualbox") { selectedProfileCheckResult = "full"; }
            prerequisitesCheckResult = "full";
        } else if ( vmwareExecutableExists === "true" && vmwareVagrantPluginInstalled === "true" ) {
            defaultProfile = "vmware-desktop";
            updateStartModeSelection(document.getElementById("vmware-desktop-profile-selected-startup-mode").value);
            updateOrchestratorSelection(document.getElementById("vmware-desktop-profile-selected-orchestrator").value);
            prerequisitesCheckResult = "full";
        } else if ( parallelsExecutableExists === "true" && parallelsPluginInstalled === "true" ) {
            defaultProfile = "parallels";
            updateStartModeSelection(document.getElementById("parallels-profile-selected-startup-mode").value);
            updateOrchestratorSelection(document.getElementById("parallels-profile-selected-orchestrator").value);
            prerequisitesCheckResult = "full";
        } else {
            prerequisitesCheckResult = "failed";
        }

        // Pre-requisite value must be either "full", "standalone" or "failed"
        document.getElementById("system-prerequisites-check").value = prerequisitesCheckResult;
        document.getElementById("profiles").value = defaultProfile;
        sessionStorage.hasCodeRunBefore = true;
    }

    if (sessionStorage.getItem('hasCodeRunBefore') !== null) {
        if ( selectedProfile === "virtualbox" && vboxExecutableExists === "true" && vboxVagrantPluginInstalled === "true" ) {
            selectedProfileCheckResult = "full";
            updateStartModeSelection(document.getElementById("virtualbox-profile-selected-startup-mode").value);
            updateOrchestratorSelection(document.getElementById("virtualbox-profile-selected-orchestrator").value);
        } else if ( selectedProfile === "vmware-desktop" && vmwareExecutableExists === "true" && vmwareVagrantPluginInstalled === "true" ) {
            selectedProfileCheckResult = "full";
            updateStartModeSelection(document.getElementById("vmware-desktop-profile-selected-startup-mode").value);
            updateOrchestratorSelection(document.getElementById("vmware-desktop-profile-selected-orchestrator").value);
        } else if ( selectedProfile === "parallels" && parallelsExecutableExists === "true" && parallelsPluginInstalled === "true" ) {
            selectedProfileCheckResult = "full";
            updateStartModeSelection(document.getElementById("parallels-profile-selected-startup-mode").value);
            updateOrchestratorSelection(document.getElementById("parallels-profile-selected-orchestrator").value);
        } else {
            selectedProfileCheckResult = "failed";
        }
        // Pre-requisite value must be either "full", "standalone" or "failed"
        document.getElementById("system-prerequisites-check").value = selectedProfileCheckResult;
    }
    //triggerChoiceParameterUpdate('concatenated-profile-selection');
    change_panel_selection('config-panel-profile-selection');

}

function buildInitialUsersTableFromJson(usersJsonFileContent) {
    const usersJson = JSON.parse(usersJsonFileContent);
    for (let user of usersJson.config.additionalUsers) {
        addUserToTable(user.userFirstName, user.userSurname, user.userEmail, user.userKeyboard, user.userRole);
    }
}

function checkIfUserAlreadyExistsInTable(userEmail) {
    let addUserBoolean = true;
    for ( let i=2; i<document.getElementsByClassName('user-cell-email').length; i++ ){
        if( document.getElementsByClassName('user-cell-email')[i].innerText.includes(userEmail) ) {
            addUserBoolean = false;
            break;
        }
    }
    return addUserBoolean
}

function addUserToTable( userFirstName, userSurname, userEmail, userKeyboard, userRole ) {

    let addUserBoolean;

    if (!userFirstName) {
        userFirstName = document.getElementById("user-details-firstname").value;
        userSurname = document.getElementById("user-details-surname").value;
        userEmail = document.getElementById("user-details-email").value;
        userEmail = userEmail.replaceAll(/\\s/g, "");
        userKeyboard = document.getElementById("user-details-keyboard").value;
        userRole = document.getElementById("user-details-role").value;
    }

    addUserBoolean = checkIfUserAlreadyExistsInTable(userEmail);

    if ( addUserBoolean ) {
        let tableRowHtml = '<div class="user-cell" id="firstname_' + userEmail + '">' + userFirstName + '</div>' +
            '<div class="user-cell" id="surname_' + userEmail + '">' + userSurname + '</div>' +
            '<div class="user-cell user-cell-email" id="email_' + userEmail + '">' + userEmail + '</div>' +
            '<div class="user-cell" id="keyboard_' + userEmail + '">' + userKeyboard + '</div>' +
            '<div class="user-cell" id="role_' + userEmail + '">' + userRole.charAt(0).toUpperCase() + userRole.slice(1) + '</div>' +
            '<div class="user-image-cell"><img src="/userContent/icons/delete.svg" title="remove user" alt="remove user" onclick="removeUserFromTable(&quot;' + userEmail + '&quot;);"></div>';
        let userTableDiv = document.createElement('div');
        userTableDiv.className = 'user-row-added';
        userTableDiv.id = userEmail;
        userTableDiv.innerHTML = tableRowHtml;
        document.getElementById('user-row-group').appendChild(userTableDiv);
        buildUserJsonFromDivTable()
    }

}

function removeUserFromTable(userTableRowDivToRemove) {
    let userRowToDeleteElement = document.getElementById(userTableRowDivToRemove);
    userRowToDeleteElement.remove();
    buildUserJsonFromDivTable()
}

function getTableRows() {
    let divRowList = [];
    let everyChild = document.querySelectorAll(".user-row-added");
    for (let i = 0; i<everyChild.length; i++) {
        if ( everyChild[i].id !== null && everyChild[i].id !== "") {
            divRowList.push(everyChild[i].id);
        }
    }
    return divRowList;
}

function buildUserJsonFromDivTable() {
    let userTableRows = getTableRows();
    let userJsonNodes = [];
    let userJsonNode;
    let userRowElement;
    let userFirstName;
    let userSurname;
    let userEmail;
    let userKeyboard;
    let userRole;
    for (let i = 0; i<userTableRows.length; i++) {
        userRowElement = document.getElementById(userTableRows[i]).id;
        userFirstName = document.getElementById("firstname_" + userRowElement).innerText;
        userSurname = document.getElementById("surname_" + userRowElement).innerText;
        userEmail = document.getElementById("email_" + userRowElement).innerText;
        userKeyboard = document.getElementById("keyboard_" + userRowElement).innerText;
        userRole = document.getElementById("role_" + userRowElement).innerText;
        userJsonNode = '{ "userFirstName": "' + userFirstName + '", "userSurname": "' + userSurname + '", "userEmail": "' + userEmail + '", "userKeyboard": "' + userKeyboard + '", "userRole": "' + userRole + '"}';
        userJsonNodes.push(userJsonNode);
    }
    let allUsersJson = '{ "config": { "additionalUsers": [' + userJsonNodes.toString() + '] } }';
    document.getElementById('concatenated-user-provisioning-list').value = allUsersJson;
    triggerChoiceParameterUpdate('concatenated-user-provisioning-list');

}

function calculateHeatmapScalePosition() {

    let mainNodeCount = document.getElementById("counter_value_main_node_count").value;
    let mainNodecpuCores = document.getElementById("slider_value_main_admin_node_cpu_cores").value;
    let mainNodememory = document.getElementById("slider_value_main_admin_node_memory").value;
    let workerNodeCount = document.getElementById("counter_value_worker_node_count").value;
    let workerNodeCpuCores = document.getElementById("slider_value_worker_node_cpu_cores").value;
    let workerNodeMemory = document.getElementById("slider_value_worker_node_memory").value;
    let workloadsOnMasterCheckedStatus = document.getElementById("general-param-workloads-on-master-toggle").checked;

    let totalAvailableMemory;
    let totalAvailableCpuCores;

    let cpuCoresHeatScaleMax = 20;
    let memoryHeatScaleMax = 64 * 1024;
    let cpuCoresHeatScaleMin = 2;
    let memoryHeatScaleMin = 6 * 1024;

    if ( workloadsOnMasterCheckedStatus ) {
        totalAvailableCpuCores = ( mainNodeCount * mainNodecpuCores ) + ( workerNodeCount * workerNodeCpuCores );
        totalAvailableMemory = ( mainNodeCount * mainNodememory ) + ( workerNodeCount * workerNodeMemory );
    } else {
        totalAvailableCpuCores = workerNodeCount * workerNodeCpuCores;
        totalAvailableMemory = workerNodeCount * workerNodeMemory;
    }

    let cpuScore;
    if ( totalAvailableCpuCores >= cpuCoresHeatScaleMax ) {
        cpuScore = 1;
    } else {
        cpuScore = ( totalAvailableCpuCores / cpuCoresHeatScaleMax );
    }

    let memoryScore;
    if ( totalAvailableMemory >= memoryHeatScaleMax ) {
        memoryScore = 1;
    } else {
        memoryScore = (totalAvailableMemory / memoryHeatScaleMax);
    }

    let heatScaleDivWidth = 880;

    let heatmapScalePosition;

    if ( totalAvailableCpuCores < cpuCoresHeatScaleMin || totalAvailableMemory < memoryHeatScaleMin ) {
        heatmapScalePosition = 10;
    } else {
        heatmapScalePosition = heatScaleDivWidth * ( ( cpuScore + memoryScore ) / 2 );
    }
    let heatmapScalePositionPercentage = ( heatmapScalePosition / heatScaleDivWidth ) * 100;

    switch (true) {
        case (heatmapScalePositionPercentage <= 5):
            document.getElementById("experience-meter-emoji-icon").src="/userContent/icons/emoji_robot1.png";
            document.getElementById("triangle-heat-highlight").style.filter = "invert(36%) sepia(53%) saturate(5349%) hue-rotate(334deg) brightness(92%) contrast(88%)";
            break;
        case (heatmapScalePositionPercentage <= 10):
            document.getElementById("experience-meter-emoji-icon").src="/userContent/icons/emoji_robot1.png";
            document.getElementById("triangle-heat-highlight").style.filter = "invert(36%) sepia(59%) saturate(5081%) hue-rotate(355deg) brightness(101%) contrast(91%)";
            break;
        case (heatmapScalePositionPercentage <= 20):
            document.getElementById("experience-meter-emoji-icon").src="/userContent/icons/emoji_robot2.png";
            document.getElementById("triangle-heat-highlight").style.filter = "invert(48%) sepia(33%) saturate(2153%) hue-rotate(351deg) brightness(98%) contrast(98%)";
            break;
        case (heatmapScalePositionPercentage <= 25):
            document.getElementById("experience-meter-emoji-icon").src="/userContent/icons/emoji_robot2.png";
            document.getElementById("triangle-heat-highlight").style.filter = "invert(70%) sepia(85%) saturate(746%) hue-rotate(338deg) brightness(101%) contrast(85%)";
            break;
        case (heatmapScalePositionPercentage <= 30):
            document.getElementById("experience-meter-emoji-icon").src="/userContent/icons/emoji_robot3.png";
            document.getElementById("triangle-heat-highlight").style.filter = "invert(94%) sepia(75%) saturate(2435%) hue-rotate(359deg) brightness(93%) contrast(84%)";
            break;
        case (heatmapScalePositionPercentage <= 50):
            document.getElementById("experience-meter-emoji-icon").src="/userContent/icons/emoji_robot4.png";
            document.getElementById("triangle-heat-highlight").style.filter = "invert(82%) sepia(45%) saturate(844%) hue-rotate(23deg) brightness(107%) contrast(84%)";
            break;
        case (heatmapScalePositionPercentage <= 100):
            document.getElementById("experience-meter-emoji-icon").src="/userContent/icons/emoji_robot5.png";
            document.getElementById("triangle-heat-highlight").style.filter = "invert(62%) sepia(52%) saturate(436%) hue-rotate(74deg) brightness(94%) contrast(94%)";
            break;
        default:
            break;
    }

    document.getElementById("experience-marker").style.left = heatmapScalePosition + "px";

    let resourceSettingsInnerHtml = '<span class="experience-meter-title">Rought estimated experience based on current selection</span><span class="experience-meter-label">CPU</span><span class="experience-meter-value">' + totalAvailableCpuCores + ' vCores</span class="experience-meter-label"><span class="experience-meter-label">Memory</span><span class="experience-meter-value">' + ( totalAvailableMemory / 1024 )+ 'GB</span>'
    document.getElementById("current-resource-settings-div").innerHTML = resourceSettingsInnerHtml;
    document.getElementById("current-resource-settings-span").style.left = ( heatmapScalePosition - 130 ) + "px";

}

function generateTeamName() {
    const xhr = new XMLHttpRequest(),
        method = "GET",
        url = "/userContent/data/environment_prefix_names";
    xhr.open(method, url, true);
    xhr.onreadystatechange = function () {
        // In local files, status is 0 upon success in Mozilla Firefox
        if (xhr.readyState === XMLHttpRequest.DONE) {
            let status = xhr.status;
            if (status === 0 || (status >= 200 && status < 400)) {
                // The request has been completed successfully
                let teamNames = xhr.responseText.split(/\r?\n/);
                let teamName = teamNames[Math.floor(Math.random()*teamNames.length)];
                document.getElementById("general-param-team-name").value = teamName;
            } else {
                // Oh no! There has been an error with the request!
            }
        }
    };
    xhr.send();
}

function generatePassword() {
    let generatedPassword = Math.random().toString(36).slice(-10);
    document.getElementById("general-param-password").value = generatedPassword;
}

function updateStartModeSelection(elementId) {
    if ( elementId === "normal" ) {
        document.getElementById("selection-normal-label").className = "selection-label selection-label-selected";
        document.getElementById("selection-normal-radio").className = "selection-radio start-mode-selection-radio-selected";
        document.getElementById("selection-lite-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-lite-radio").className = "selection-radio start-mode-selection-radio-unselected";
        document.getElementById("selection-minimal-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-minimal-radio").className = "selection-radio start-mode-selection-radio-unselected";
        document.getElementById("selection-normal-svg").src = "/userContent/icons/radiobox-marked.svg";
        document.getElementById("selection-lite-svg").src = "/userContent/icons/radiobox-blank.svg";
        document.getElementById("selection-minimal-svg").src = "/userContent/icons/radiobox-blank.svg";
    } else if ( elementId === "lite" ) {
        document.getElementById("selection-normal-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-normal-radio").className = "selection-radio start-mode-selection-radio-unselected";
        document.getElementById("selection-lite-label").className = "selection-label selection-label-selected";
        document.getElementById("selection-lite-radio").className = "selection-radio start-mode-selection-radio-selected";
        document.getElementById("selection-minimal-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-minimal-radio").className = "selection-radio start-mode-selection-radio-unselected";
        document.getElementById("selection-normal-svg").src = "/userContent/icons/radiobox-blank.svg";
        document.getElementById("selection-lite-svg").src = "/userContent/icons/radiobox-marked.svg";
        document.getElementById("selection-minimal-svg").src = "/userContent/icons/radiobox-blank.svg";
    } else if ( elementId === "minimal" ) {
        document.getElementById("selection-normal-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-normal-radio").className = "selection-radio start-mode-selection-radio-unselected";
        document.getElementById("selection-lite-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-lite-radio").className = "selection-radio start-mode-selection-radio-unselected";
        document.getElementById("selection-minimal-label").className = "selection-label selection-label-selected";
        document.getElementById("selection-minimal-radio").className = "selection-radio start-mode-selection-radio-selected";
        document.getElementById("selection-normal-svg").src = "/userContent/icons/radiobox-blank.svg";
        document.getElementById("selection-lite-svg").src = "/userContent/icons/radiobox-blank.svg";
        document.getElementById("selection-minimal-svg").src = "/userContent/icons/radiobox-marked.svg";
    }
    update_selected_value();
}


function updateOrchestratorSelection(elementId) {
    if ( elementId === "k8s" ) {
        document.getElementById("selection-k8s-label").className = "selection-label selection-label-selected";
        document.getElementById("selection-k8s-radio").className = "selection-radio orchestrator-selection-radio-selected";
        document.getElementById("selection-k3s-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-k3s-radio").className = "selection-radio orchestrator-selection-radio-unselected";
        document.getElementById("selection-k8s-svg").src = "/userContent/icons/radiobox-marked.svg";
        document.getElementById("selection-k3s-svg").src = "/userContent/icons/radiobox-blank.svg";
    } else if ( elementId === "k3s" ) {
        document.getElementById("selection-k8s-label").className = "selection-label selection-label-unselected";
        document.getElementById("selection-k8s-radio").className = "selection-radio orchestrator-selection-radio-unselected";
        document.getElementById("selection-k3s-label").className = "selection-label selection-label-selected";
        document.getElementById("selection-k3s-radio").className = "selection-radio orchestrator-selection-radio-selected";
        document.getElementById("selection-k8s-svg").src = "/userContent/icons/radiobox-blank.svg";
        document.getElementById("selection-k3s-svg").src = "/userContent/icons/radiobox-marked.svg";
    }
    update_selected_value();
}

function showHidePassword() {

    let currentPasswordInputBoxType = document.getElementById("general-param-password").type;
    if (currentPasswordInputBoxType === "password") {
        document.getElementById("general-param-password").type = "text";
        document.getElementById("general-param-password-svg").src = "/userContent/icons/eye-off-outline.svg";
    } else {
        document.getElementById("general-param-password").type = "password";
        document.getElementById("general-param-password-svg").src = "/userContent/icons/eye-outline.svg";
    }

}

function getProfilePath() {
    document.getElementById('concatenated-profile-selection').value;
    let concatenatedProfileSelection = document.getElementById('concatenated-profile-selection').value.split(';');
    return concatenatedProfileSelection[0];
}

function buildInitialCustomVariablesTableFromJson(customVariablesJsonFileContent) {
    const customVariablesJson = JSON.parse(customVariablesJsonFileContent);
    for (let customVariable of customVariablesJson.config.customVariables) {
        addCustomVariableToTable(customVariable.key, customVariable.value);
    }
}

function checkIfCustomVariableAlreadyExistsInTable(customVariableKey) {
    let addCustomVariableBoolean = true;
    for ( let i=0; i<document.getElementsByClassName('custom-variable-cell-key').length; i++ ){
        if( document.getElementsByClassName('custom-variable-cell-key')[i].innerText.includes(customVariableKey) ) {
            addCustomVariableBoolean = false;
            break;
        }
    }
    return addCustomVariableBoolean
}

function addCustomVariableToTable( customVariableKey, customVariableValue ) {

    let addCustomVariableBoolean;

    if (!customVariableKey) {
        customVariableKey = document.getElementById("custom-variable-key").value;
        customVariableValue = document.getElementById("custom-variable-value").value;
    }

    addCustomVariableBoolean = checkIfCustomVariableAlreadyExistsInTable(customVariableKey);

    if ( addCustomVariableBoolean ) {
        let tableRowHtml = '<div class="custom-variable-cell-key" id="key_' + customVariableKey + '">' + customVariableKey + '</div>' +
            '<div class="custom-variable-cell" id="value_' + customVariableKey + '">' + customVariableValue + '</div>' +
            '<div class="custom-variable-image-cell"><img src="/userContent/icons/delete.svg" title="remove custom variable" alt="remove custom-variable" onclick="removeCustomVariableFromTable(&quot;' + customVariableKey + '&quot;);"></div>';
        let customVariablesTableDiv = document.createElement('div');
        customVariablesTableDiv.className = 'custom-variable-row-added';
        customVariablesTableDiv.id = customVariableKey;
        customVariablesTableDiv.innerHTML = tableRowHtml;
        document.getElementById('custom-variable-row-group').appendChild(customVariablesTableDiv);
        buildCustomVariablesJsonFromDivTable()
    }

}

function removeCustomVariableFromTable(customVariableTableRowDivToRemove) {
    let customVariableRowToDeleteElement = document.getElementById(customVariableTableRowDivToRemove);
    customVariableRowToDeleteElement.remove();
    buildCustomVariablesJsonFromDivTable()
}

function getCustomVariablesTableRows() {
    let divRowList = [];
    let everyChild = document.querySelectorAll(".custom-variable-row-added");
    for (let i = 0; i<everyChild.length; i++) {
        if ( everyChild[i].id !== null && everyChild[i].id !== "") {
            divRowList.push(everyChild[i].id);
        }
    }
    return divRowList;
}

function buildCustomVariablesJsonFromDivTable() {
    let customVariableTableRows = getCustomVariablesTableRows();
    let customVariableJsonNodes = [];
    let customVariableJsonNode;
    let customVariableRowElement;
    let customVariableKey;
    let customVariableValue;
    for (let i = 0; i<customVariableTableRows.length; i++) {
        customVariableRowElement = document.getElementById(customVariableTableRows[i]).id;
        customVariableKey = document.getElementById("key_" + customVariableRowElement).innerText;
        customVariableValue = document.getElementById("value_" + customVariableRowElement).innerText;
        customVariableJsonNode = '{ "key": "' + customVariableKey + '", "value": "' + customVariableValue + '"}';
        customVariableJsonNodes.push(customVariableJsonNode);
    }
    let allCustomVariablesJson = '{ "config": { "customVariables": [' + customVariableJsonNodes.toString() + '] } }';
    document.getElementById('concatenated-custom-variables-list').value = allCustomVariablesJson;
    triggerChoiceParameterUpdate('concatenated-custom-variables-list');

}

function nospaces(t){
    if(t.value.match(/\s/g)) {
        t.value = t.value.replace(/\s/g, '');
    }
}