tidyUpInterface()

async function triggerBuild(nodeType) {
    let jenkinsCrumb = getCrumb().value;
    let localKxVersion = getLocalKxVersion();
    console.log("Jenkins Crumb received = " + jenkinsCrumb.value);

    let formData = new FormData();
    formData.append('kx_vm_user', document.getElementById('general-param-username').value);
    formData.append('kx_vm_password', document.getElementById('general-param-password').value);
    formData.append('vagrant_compute_engine_build', 'false');
    formData.append('kx_version', localKxVersion);
    formData.append('kx_domain', document.getElementById('general-param-base-domain').value);
    formData.append('kx_main_hostname', nodeType);
    formData.append('profile', document.getElementById('profiles').value);
    formData.append('profile_path', document.getElementById('selected-profile-path').value);
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
    console.log(data);
}

function populate_profile_option_list() {
    tidyUpInterface()
    let profiles = getProfilePaths().split(',');
    console.log("js profiles array: " + profiles)
    for ( let i = 0; i < profiles.length; i++ ) {
        let profileName = profiles[i].split("/").pop();
        profileName = profileName.replace("vagrant-", "");
        console.log("Adding profile to options: " + profileName + i);
        document.getElementById("profiles").options[i] = new Option(profileName, profileName);
        update_selected_value();
    }
}

function update_selected_value() {
    let selectedOptionNumber = document.getElementById("profiles").selectedIndex;
    let profilePaths = getProfilePaths().split(',');
    let profilePath = profilePaths[selectedOptionNumber] + '/profile-config.json'
    console.log("profileName: " + profilePath)
    document.getElementById("selected-profile-path").value = profilePath;
    document.getElementById("selected-profile-path").setAttribute("selected-profile-path", profilePath);
    let parentId = document.getElementById("selected-profile-path").parentNode.id;
    console.log(parentId);
    jQuery('#' + parentId).trigger('change');
}

function compareVersions() {
    let githubKxVersion = getGithubKxVersion();
    let githubKubeVersion = getGithubKubeVersion();
    let localKxVersion = getLocalKxVersion();
    let localKubeVersion = getLocalKubeVersion();

    if (githubKxVersion !== localKxVersion) {
        console.log("KX Version mismatch. Your code is out of date");
        document.getElementById("version-check-message").innerHTML = "Your local checked out code (v" + localKxVersion + ") does not match the version on GitHub MAIN (v" + githubKxVersion + ")";
        document.getElementById("version-check-svg").src = "/userContent/icons/alert-outline.svg";
        document.getElementById("version-check-svg").className = "checklist-status-icon svg-orange-red";
    } else {
        console.log("KX Version is the same. Your code is up to date");
        document.getElementById("version-check-message").innerHTML = "The latest KX.AS.CODE source (v" + localKxVersion + ") is present on your machine";
        document.getElementById("version-check-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
        document.getElementById("version-check-svg").className = "checklist-status-icon svg-bright-green";
    }
}

function tidyUpInterface() {

    let mainElementDiv = document.getElementById("main-panel")
    mainElementDiv.childNodes.forEach(c=>{
        console.log("Main Panel Tag Name: " + c.tagName);
        if(c.tagName  === 'P'){
            console.log(c);
            mainElementDiv.removeChild(c);
        }
        if(c.tagName  === 'H1'){
            console.log(c);
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
        console.log(selector);
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

    let parentId = document.getElementById("concatenated-general-params").parentNode.id;
    jQuery('#' + parentId).trigger('change');

    document.getElementById("concatenated-general-params").value = baseDomainValue + ";" + teamNameValue + ";" + usernameValue + ";" + passwordValue + ";" + standaloneModeCheckedStatus + ";" + workloadsOnMasterCheckedStatus;
    console.log(document.getElementById("concatenated-general-params").value);
    //#TODO - Placeholder to check if issue after commenting out line below
    //change_panel_selection("config-panel-general-params");
}

function waitForElement(elementId, callBack){
    window.setTimeout(function(){
        let element = document.getElementById(elementId);
        if(element){
            callBack(elementId, element);
        }else{
            waitForElement(elementId, callBack);
        }
    },500)
}

function updateCheckbox(checkboxElementId) {
    console.log("Processing updateCheckbox(checkboxElementId) for " + checkboxElementId);
    waitForElement(checkboxElementId, function () {
        console.log("checkboxElementId: " + checkboxElementId + " --> " + document.getElementById(checkboxElementId).checked);
    });

    waitForElement('standalone-mode-toggle', function () {
        console.log("document.getElementById('standalone-mode-toggle').value: *" + document.getElementById("standalone-mode-toggle").value + "*");

    });

    waitForElement('system-prerequisites-check', function () {
        console.log("document.getElementById(system-prerequisites-check).value: *" + document.getElementById("system-prerequisites-check").value + "*");
    });

    if (document.getElementById(checkboxElementId).checked === true) {
        console.log("DEBUG (1) updateCheckbox() - false: " + document.getElementById(checkboxElementId).checked);
        document.getElementById(checkboxElementId).checked = true;
        document.getElementById(checkboxElementId).value = true;
        console.log("Name value hidden field: " + checkboxElementId + "-name-value");
        document.getElementById(checkboxElementId + '-name-value').value = true;
    } else {
        console.log("DEBUG (2) updateCheckbox() - true: " + document.getElementById(checkboxElementId).checked);
        document.getElementById(checkboxElementId).checked = false;
        document.getElementById(checkboxElementId).value = false;
        console.log("Name value hidden field: " + checkboxElementId + "-name-value");
        document.getElementById(checkboxElementId + '-name-value').value = false;
    }

    if (document.getElementById("system-prerequisites-check").value === "standalone" || document.getElementById("system-prerequisites-check").value === "failed") {
        console.log('DEBUG: Inside checkbox set to standalone');
        document.getElementById('general-param-standalone-mode-toggle').checked = true;
        document.getElementById('general-param-workloads-on-master-toggle').checked = true;
        document.getElementById('general-param-standalone-mode-toggle').className = "checkbox-slider-checked-disabled round";
        document.getElementById('general-param-standalone-mode-toggle-span').className = "checkbox-slider-checked-disabled round";
        document.getElementById('general-param-workloads-on-master-toggle').className = "checkbox-slider-checked-disabled round";
        document.getElementById('general-param-workloads-on-master-toggle-span').className = "checkbox-slider-checked-disabled round";
        document.getElementById('general-param-workloads-on-master-toggle-name-value').value = true;
    } else if (document.getElementById("system-prerequisites-check").value === "full") {
        console.log("DEBUG: Inside checkbox set to full");
        document.getElementById('general-param-standalone-mode-toggle').className = "checkbox-slider round";
        document.getElementById('general-param-standalone-mode-toggle-span').className = "checkbox-slider round";
        document.getElementById('general-param-workloads-on-master-toggle').className = "checkbox-slider round";
        document.getElementById('general-param-workloads-on-master-toggle-span').className = "checkbox-slider round";
    }

    let parentId = document.getElementById(checkboxElementId + '-name-value').parentNode.id;
    console.log(parentId);
    jQuery('#' + parentId).trigger('change');

}

function show_value(x, previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit) {
    let previous_x = document.getElementById(previousElementId).value;
    if (x !== previous_x) {
        let x_float = parseFloat(x).toFixed(2);
        document.getElementById(valueElementId).innerHTML = (x_float / valueDisplayConversion) + " " + rangeUnit;
        document.getElementById(elementId).value = x;
        document.getElementById(elementId).setAttribute(elementId, x);
        let parentId = document.getElementById(elementId).parentNode.parentNode.parentNode.parentNode.parentNode.id;
        if (parentId === '') {
            parentId = document.getElementById(elementId).parentNode.id;
        }
        console.log("parentId: " + parentId);
        jQuery('#' + parentId).trigger('change');
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
            console.log("Not calling updateConcatenated*ReturnVariable() for " + elementId);
        }
    }
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
    console.log("Updating concatenated value for " + hiddenValueElementId);
    if (hiddenValueElementId === "concatenated_value_main_node_config") {
        console.log("Getting values for concatenated_value_main_node_config");
        nodeCount = document.getElementById("counter_value_main_node_count").value;
        cpuCores = document.getElementById("slider_value_main_admin_node_cpu_cores").value;
        memory = document.getElementById("slider_value_main_admin_node_memory").value;
        console.log("Received following values for main node: " + nodeCount + "; " + cpuCores + "; " + memory);
    } else if (hiddenValueElementId === "concatenated_value_worker_node_config") {
        console.log("Getting values for concatenated_value_worker_node_config");
        nodeCount = document.getElementById("counter_value_worker_node_count").value;
        cpuCores = document.getElementById("slider_value_worker_node_cpu_cores").value;
        memory = document.getElementById("slider_value_worker_node_memory").value;
        console.log("Received following values for worker node: " + nodeCount + "; " + cpuCores + "; " + memory);
    } else {
        console.log(hiddenValueElementId + "not found -> updateConcatenatedNodeReturnVariable()");
    }
    let concatenatedValue = nodeCount + ";" + cpuCores + ";" + memory;
    console.log("Updating hidden value id " + hiddenValueElementId + " with " + concatenatedValue);
    document.getElementById(hiddenValueElementId).value = concatenatedValue;
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
    let parentId = document.getElementById('concatenated-storage-params').parentNode.id;
    console.log(parentId);
    jQuery('#' + parentId).trigger('change');
}

function updateAllConcatenatedVariables() {
    updateConcatenatedGeneralParamsReturnVariable();
    updateConcatenatedNodeReturnVariable("concatenated_value_main_node_config");
    updateConcatenatedNodeReturnVariable("concatenated_value_worker_node_config");
    updateConcatenatedStorageReturnVariable();
}

async function getBuildJobListForProfile(job, nodeType) {
    let styleColor;
    console.log("DEBUG getBuildJobListForProfile: " + job + " | " + nodeType);
    getAllJenkinsBuilds(job).then(data => {
        console.log("DEBUG nodeType: " + nodeType);
        console.log("DEBUG job: " + job);
        console.log(data);
        const kxBuilds = (() => {
            const builds = filterBuilds(data);
            console.log(data);
            console.log("above: data");
            console.log(builds);
            console.log("above: builds");
            const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
            console.log(filteredBuilds);
            console.log("above: filteredBuilds");
            console.log(filteredBuilds);
            if (nodeType === "kx-launch") {
                console.log("Inside const definition kx-launch");
                console.log(filteredBuilds);
                return filteredBuilds;
            } else {
                console.log("Inside const definition not equal to kx-launch");
                return filterDataByNodeType(filteredBuilds, nodeType);
            }
        })();
        console.log(nodeType + ' kxBuilds.length: ' + kxBuilds.length);
        console.log(kxBuilds);
        if (kxBuilds.length > 0) {
            console.log('Found ' + nodeType + ' builds for profile');
            console.log(kxBuilds[0].estimatedDuration);
            console.log(kxBuilds[0].id);
            console.log(kxBuilds[0].node_type);
            console.log(kxBuilds[0].number);
            console.log(kxBuilds[0].result);
            console.log(kxBuilds[0].timestamp);
            console.log(kxBuilds[0].url);
            console.log(kxBuilds[0].vm_type);

            getExtendedJobDetails(kxBuilds[0].url).then( text => {
                console.log("DISPLAY_NAME: ", JSON.parse(text).displayName);
                const splitDisplayName = JSON.parse(text).displayName.split('_');
                //const buildNumber = splitDisplayName[0];
                const kxVersion = splitDisplayName[1];
                const kubeVersion = splitDisplayName[2];
                //const profile = splitDisplayName[3];
                const nodeTypeVagrantAction = splitDisplayName[4];
                //const gitCommitId = splitDisplayName[5];
                console.log("nodeTypeVagrantAction: " + nodeTypeVagrantAction);
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
                document.getElementById(nodeType + "-build-result").innerHTML = '<span className="build-action-text-value build-action-text-value-result" style="width: 70px;">' + kxBuilds[0].result + '</span>';
                document.getElementById(nodeType + "-build-result").className = styleClass;
                document.getElementById(nodeType + "-build-number-link").innerHTML = "<a href='" + kxBuilds[0].url + "' target='_blank' rel='noopener noreferrer' style='font-weight: normal;'># " + kxBuilds[0].number + "</a>";
            } else {
                document.getElementById(nodeType + "-build-result").className = "";
                document.getElementById(nodeType + "-build-result").style.justifyContent = "center";
                document.getElementById(nodeType + "-build-result").innerHTML = "<div class='dot-flashing' style='background-color: white; margin-right: 15px; margin-left: 15px;'></div>";
                document.getElementById(nodeType + "-build-number-link").innerHTML = "<a href='" + kxBuilds[0].url + "' target='_blank' rel='noopener noreferrer' style='font-weight: normal;'># " + kxBuilds[0].number + "</a>";
            }
        } else {
            console.log('Did not find ' + nodeType + ' builds for profile');
            styleClass = 'build-result build-result-neutral';
            document.getElementById(nodeType + "-build-result").innerText = 'n/a';
            document.getElementById(nodeType + "-build-result").className = styleClass;
            document.getElementById(nodeType + "-build-timestamp").innerText = "not run yet";
            document.getElementById(nodeType + "-build-number-link").innerText = "-";
            document.getElementById(nodeType + '-build-kx-version').innerText = "-";
            document.getElementById(nodeType + '-build-kube-version').innerText = "-";
        }
    })
}

async function getExtendedJobDetails(url) {
    let jenkinsCrumb = getCrumb().value;
    //let url = '/job/Actions/job/KX.AS.CODE_Runtime_Actions/42/api/json';
    let urlToFetch = url + '/api/json';
    console.log(urlToFetch);
    let responseData = await fetch(urlToFetch, {
        method: 'GET',
        headers: {
            'Authorization': 'Basic ' + btoa('admin:admin'),
            'Jenkins-Crumb': jenkinsCrumb
        }
    }).then(data => {
        //console.log(data);
        let responseText = data.text().then(function (text) {
            //console.log(responseText);
            return text;
        });
        return responseText;
    });
    //console.log(responseData);
    //console.log(JSON.parse(responseData));
    let jobDisplayName = JSON.parse(responseData);
    //console.log(jobDisplayName.displayName);
    return responseData;
}


function filterBuilds(data) {
    let tmp = [];
    let nodeType;
    let paramArrayLocation
    console.log("Inside filterBuilds");
    const builds = data.builds;
    console.log(data);
    console.log(builds);
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

        console.log("paramArrayLocation: " + paramArrayLocation);
        console.log(e.actions[paramArrayLocation]);
        console.log(e.actions[paramArrayLocation]._class);
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
    console.log(tmp);
    console.log("above tmp");
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
                console.log('nodeType = null. Filtering running jobs from all builds')
                return filterDataByResult(filteredBuilds);
            } else {
                console.log('nodeType = ' + nodeType + '. Filtering running jobs from ' + job + ' builds')
                const kxBuilds = filterDataByNodeType(filteredBuilds, nodeType);
                return filterDataByResult(kxBuilds);

            }
        })();

        console.log('runningBuilds.length: ' + runningBuilds.length);
        if (runningBuilds.length > 0) {
            console.log(runningBuilds[0].url);
            let urlToFetch = runningBuilds[0].url + 'stop';
            console.log(urlToFetch);
            let response = fetch(urlToFetch, {
                method: 'POST',
                headers: {
                    'Authorization': 'Basic ' + btoa('admin:admin'),
                    'Jenkins-Crumb': jenkinsCrumb
                }
            }).then(data => {
                console.log(data)
            })
            let responseText = response.text();
            console.log(responseText);
        }
    })
}

async function showConsoleLog(job, nodeType) {
    //let nodeType = 'kx-main';    // For debuging only
    //let job = 'KX.AS.CODE_Image_Builder';     // For debuging only
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
        console.log("nodeType: " + nodeType);
        console.log(data);
        const kxBuilds = (() => {
            const builds = filterBuilds(data);
            console.log(data);
            console.log("above: data");
            console.log(builds);
            console.log("above: builds");
            const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
            console.log(filteredBuilds);
            console.log("above: filteredBuilds");
            console.log(filteredBuilds);
            if (nodeType === "kx-launch") {
                console.log("Inside const definition kx-launch");
                console.log(filteredBuilds);
                return filteredBuilds;
            } else {
                console.log("Inside const definition not equal to kx-launch");
                return filterDataByNodeType(filteredBuilds, nodeType);
            }
        })();
        //const kxBuilds = filterDataByNodeType(filteredBuilds, nodeType);
        console.log('kxBuilds.length: ' + kxBuilds.length);
        if (kxBuilds.length > 0) {
            console.log(kxBuilds[0].url);
            let urlToFetch = kxBuilds[0].url + 'consoleText';
            console.log(urlToFetch);
            fetch(urlToFetch, {
                method: 'GET',
                headers: {
                    'Authorization': 'Basic ' + btoa('admin:admin'),
                    'Jenkins-Crumb': jenkinsCrumb
                }
            }).then(data => {
                data.text().then(consoleLog => {
                    console.log(consoleLog)
                    console.log('consoleLog: ');
                    console.log(consoleLog);
                    let consoleLine;
                    let lines = consoleLog.split(/[\r\n]+/);
                    console.log(lines);

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
                    console.log("numLinesToIgnore: " + numLinesToIgnore + " linesToReturn: " + linesToReturn)

                    n = lines.length - (linesToReturn + numLinesToIgnore);
                    for (let line = n; line < lines.length; line++) {
                        console.log("Jenkins Console Log Line: " + lines[line] + " | " + lines[line].includes('[Pipeline]'))
                        if ( ! lines[line].includes('[Pipeline]') ) {
                            consoleLine = lines[line] + '<br>';
                            consoleLine = consoleLine.replace(/FAILURE/g, '<span style="color: var(--kx-error-red-100)">FAILURE</span>')
                            consoleLine = consoleLine.replace(/ERROR/g, '<span style="color: var(--kx-error-red-100)">ERROR</span>')
                            consoleLine = consoleLine.replace(/SUCCESS/g, '<span style="color: var(--kx-success-green-100)">SUCCESS</span>')
                            consoleLogDiv.innerHTML += consoleLine;
                            console.log(consoleLine);
                        } else {
                            console.log("Skipping line: " + lines[line]);
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
        console.log('filteredBuilds: ');
        console.log(filteredBuilds);
        const kxBuilds = (() => {
            const builds = filterBuilds(data);
            console.log(data);
            console.log("above: data");
            console.log(builds);
            console.log("above: builds");
            const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
            console.log(filteredBuilds);
            console.log("above: filteredBuilds");
            console.log(filteredBuilds);
            if (nodeType === "kx-launch") {
                console.log("Inside const definition kx-launch");
                console.log(filteredBuilds);
                return filteredBuilds;
            } else {
                console.log("Inside const definition not equal to kx-launch");
                return filterDataByNodeType(filteredBuilds, nodeType);
            }
        })();
        console.log('kxBuilds.length: ' + kxBuilds.length);
        if (kxBuilds.length > 0) {
            let urlToOpen = kxBuilds[0].url + 'console';
            console.log(urlToOpen);
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
                console.log(xhr.responseText);
                let crumb = JSON.parse(xhr.responseText).crumb;
                console.log(crumb);
            } else {
                // Oh no! There has been an error with the request!
            }
        }
    };
    xhr.send();
    return crumb;
}

async function getAllJenkinsBuilds(job) {
    console.log((new Error()).stack);
    console.log("DEBUG getAllJenkinsBuilds(job): " + job);
    let jenkinsCrumb = getCrumb().value;
    console.log("Jenkins Crumb received = " + jenkinsCrumb);
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
    console.log("Inside populateReviewTable()");
    document.getElementById("summary-profile-value").innerText = document.getElementById("profiles").value;
    document.getElementById("summary-standalone-mode-value").innerText = document.getElementById("general-param-standalone-mode-toggle").value;
    document.getElementById("summary-workloads-on-master-value").innerText = document.getElementById("general-param-workloads-on-master-toggle").value;
    let numMainNodes = parseInt(document.getElementById("counter_value_main_node_count_value").innerText);
    document.getElementById("summary-main-nodes-number-value").innerText = numMainNodes;
    let numWorkerNodes = parseInt(document.getElementById("counter_value_worker_node_count_value").innerText);
    document.getElementById("summary-worker-nodes-number-value").innerText = numWorkerNodes;
    if (document.getElementById("concatenated-templates-list").value === "") {
        document.getElementById("list-templates-to-install").innerHTML = "<i>None</i>"
    } else {
        let templatesList = document.getElementById("concatenated-templates-list").value;
        templatesList = templatesList.replaceAll(';', ', ');
        document.getElementById("list-templates-to-install").innerText = templatesList;
    }
}

async function performRuntimeAction(vagrantAction) {
    console.log("performRuntimeAction(vagrantAction): " + vagrantAction);

    let jenkinsCrumb = getCrumb().value;
    console.log("Jenkins Crumb received = " + jenkinsCrumb);

    let formData = new FormData();
    formData.append('kx_main_version', document.getElementById("kx-main-vagrant-cloud-box-version").innerText);
    formData.append('kx_node_version', document.getElementById("kx-node-vagrant-cloud-box-version").innerText);
    formData.append('num_kx_main_nodes', document.getElementById('counter_value_main_node_count_value').innerText);
    formData.append('num_kx_worker_nodes', document.getElementById('counter_value_worker_node_count_value').innerText);
    formData.append('dockerhub_email', '');
    formData.append('profile', document.getElementById('profiles').value);
    formData.append('profile_path', document.getElementById('selected-profile-path').value);
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
    console.log(data);
}

function updateProfileAndPrereqsCheckTab() {
    getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-main");
    getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-node");
    //update_selected_value();
    getAvailableLocalBoxes();
    getAvailableCloudBoxes()
    compareVersions();
    checkVagrantPreRequisites();
    updateProfileSelection();
}

function displayOrHideKxAlreadyRunningWarning(mainNodes) {
    console.log("displayOrHideKxAlreadyRunningWarning(" + mainNodes + ")");
    if (mainNodes > 0 ) {
        document.getElementById("kx-launch-running-vms").style.display = "inline-block";
    } else {
        document.getElementById("kx-launch-running-vms").style.display = "none";
    }
}