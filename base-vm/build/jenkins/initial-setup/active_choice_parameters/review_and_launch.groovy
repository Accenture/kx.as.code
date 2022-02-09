def extendedDescription = "Here you can select an application group from a list of available templates. An application group is a set of applications that are commonly deployed together, and in many cases they will also be integrated within KX.AS.CODE."

try {
    println("Entered Review and Launch Parameter")
    //println(templateComponentsArray)
} catch(e) {
    println "Something went wrong in the GROOVY block (review_and_launch.groovy): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <head>
        <script>
        </script>
        <style>

            .table {
                display:table;
            }
            .header {
                display:table-header-group;
                font-weight:bold;
            }
            .rowGroup {
                display:table-row-group;
            }
            .row {
                /*display:table-row;*/
                margin: 5px;
            }
            .cell {
                display:table-cell;
            }

            .cell-label {
                background-color: #0a53be;
                color: white;
                vertical-align: middle;
                border-bottom-left-radius: 5px;
                border-top-left-radius: 5px;
                width: 270px;
                height: 40px;
                padding-left: 15px;
                padding-top: 5px;
                padding-bottom: 5px;
            }

            .cell-value {
                background-color: white;
                width: 140px;
                height: 40px;
                padding-right: 15px;
                padding-top: 5px;
                padding-bottom: 5px;
                text-align: right;
                vertical-align: middle;
                border: 1px solid  #0a53be;
                border-spacing: 15px;/*cellspacing:poor IE support for  this*/
                border-bottom-right-radius: 5px;
                border-top-right-radius: 5px;
            }

            .flex-wrapper {
                flex-flow: row wrap;
                justify-content: space-between;
                flex-wrap: wrap;
                /*background-color: green;*/
            }

            .flex-item {
                display: block;
                width: 46%;
                /*background-color: orange;*/
                height: 160px;
            }

        .launch-action-text-label {
            width: 160px;
            height: 30px;
            border: none;
            color: #404c50;
            padding: 2px 2px;
            text-decoration: none;
            margin: 2px 2px;
            display: inline-block;
            vertical-align: middle;
        }

        </style>
        <script>

        function populateReviewTable() {
            console.log("Inside populateReviewTable()");
            document.getElementById("summary-profile-value").innerText = document.getElementById("profiles").value;
            document.getElementById("summary-standalone-mode-value").innerText = document.getElementById("general-param-standalone-mode-toggle").value;
            document.getElementById("summary-workloads-on-master-value").innerText = document.getElementById("general-param-workloads-on-master-toggle").value;
            document.getElementById("summary-network-storage-value").innerText = document.getElementById("slider_value_network_storage").value;
            document.getElementById("summary-local-storage-value").innerText = document.getElementById("counter_value_local_volume_count_1_gb").value;
            document.getElementById("summary-main-nodes-number-value").innerText = document.getElementById("counter_value_main_node_count_value").innerText;
            document.getElementById("summary-main-nodes-cpu-cores-value").innerText = document.getElementById("slider_value_main_admin_node_cpu_cores_value").innerText;
            document.getElementById("summary-main-nodes-memory-value").innerText = document.getElementById("slider_value_main_admin_node_memory_value").innerText;
            document.getElementById("summary-worker-nodes-number-value").innerText = document.getElementById("counter_value_worker_node_count_value").innerText;
            document.getElementById("summary-worker-nodes-cpu-cores-value").innerText = document.getElementById("slider_value_worker_node_cpu_cores_value").innerText;
            document.getElementById("summary-worker-nodes-memory-value").innerText = document.getElementById("slider_value_worker_node_memory_value").innerText;
        }

        async function performRuntimeAction(vagrantAction) {
            console.log("vagrant action: " + vagrantAction);

            let jenkinsCrumb = getCrumb();
            console.log("Jenkins Crumb received = " + jenkinsCrumb.value);

            let formData = new FormData();

            formData.append('kx_main_box_location', '');
            formData.append('kx_node_box_location', '');
            formData.append('kx_version_override', '');
            formData.append('dockerhub_email', '');
            formData.append('profile', document.getElementById('profiles').value);
            formData.append('profile_path', document.getElementById('selected-profile-path').value);
            formData.append('vagrant_action', vagrantAction);

            const config = {
                method: 'POST',
                headers: {
                    'Authorization': 'Basic ' + btoa('admin:admin'),
                    'Jenkins-Crumb': jenkinsCrumb.value
                },
                body: formData
            }

            let response = await fetch('http://localhost:8081/job/Actions/job/KX.AS.CODE_Runtime_Actions/buildWithParameters', config);
            let data = await response.text();
            console.log(data);
        }

        </script>
    </head>
    <body>
    <div id="review-and-launch-div" class="flex-wrapper" style="display: none;">
        <div class="flex-item">
            <div class="table">
                <div class="row">
                    <div class="cell cell-label">Profile</div>
                    <div class="cell cell-value" id="summary-profile-value" >Vmware Desktop</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Standalone Mode</div>
                    <div class="cell cell-value" id="summary-standalone-mode-value">False</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Allow Workloads on K8s Master</div>
                    <div class="cell cell-value" id="summary-workloads-on-master-value">True</div>
                </div>
            </div>
        </div>
        <div class="flex-item">
            <div class="table">
                <div class="row">
                    <div class="cell cell-label">Network Storage</div>
                    <div class="cell cell-value" id="summary-network-storage-value">200GB</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Local Storage</div>
                    <div class="cell cell-value" id="summary-local-storage-value">100GB</div>
                </div>
            </div>
        </div>
        <div class="flex-item">
            <div class="table">
                <div class="row">
                    <div class="cell cell-label">Number of KX-Main Nodes</div>
                    <div class="cell cell-value" id="summary-main-nodes-number-value">3</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Total KX-Main CPU Cores Required</div>
                    <div class="cell cell-value" id="summary-main-nodes-cpu-cores-value">8</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Total KX-Main Memory Required</div>
                    <div class="cell cell-value" id="summary-main-nodes-memory-value">16GB</div>
                </div>
            </div>
        </div>
        <div class="flex-item">
            <div class="table">
                <div class="row">
                    <div class="cell cell-label">Number of KX-Worker Nodes</div>
                    <div class="cell cell-value" id="summary-worker-nodes-number-value">4</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Total KX-Worker CPU Cores Required</div>
                    <div class="cell cell-value" id="summary-worker-nodes-cpu-cores-value">4</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Total KX-Worker Memory Required</div>
                    <div class="cell cell-value" id="summary-worker-nodes-memory-value">8GB</div>
                </div>
            </div>
        </div>
    </div>
    </body>

        <div id="profile-launch-div" style="display: none;">
            <h2>Image Launch for Profile</h2>
            <div style="vertical-align: middle; display: inline-block;">
                <span style="vertical-align: middle; display: inline-block;">
                    <span class="launch-action-text-label">Last KX Launch Date: </span><span id="kx-launch-build-timestamp" class="build-action-text-value"></span>
                    <span class="launch-action-text-label">Last KX Launch Status: </span><span id="kx-launch-build-result" class="build-action-text-value build-action-text-value-result"></span>
                    <span class="build-number-span" id="kx-launch-build-number-link"></span>
                </span>
                <span class='span-rounded-border'>
                    <img src='/userContent/icons/play.svg' class="build-action-icon" title="Start Environment" alt="Start Environment" onclick='performRuntimeAction("start");' />|
                    <img src='/userContent/icons/stop.svg' class="build-action-icon" title="Stop Environment" alt="Stop Environment" onclick='performRuntimeAction("halt");' />|
                    <img src='/userContent/icons/cancel.svg' class="build-action-icon" title="Delete Environment" alt="Delete Environment" onclick='performRuntimeAction("destroy");' />|
                    <img src='/userContent/icons/refresh.svg' class="build-action-icon" title="Refresh Data" alt="Refresh Data" onclick='getBuildJobListForProfile("KX.AS.CODE_Runtime_Actions", "kx-launch");' />|
                    <div class="console-log"><span class="console-log-span"><img src="/userContent/icons/text-box-outline.svg" onMouseover='showConsoleLog("KX.AS.CODE_Runtime_Actions", "kx-launch");' onclick='openFullConsoleLog("KX.AS.CODE_Runtime_Actions", "kx-launch");' class="build-action-icon" alt="View Build Log" title="Click to open full log in new tab"><span class="consolelogtext" id='kxLaunchBuildConsoleLog'></span></span></div>
                </span>
            </div>

        <!--<style scoped="scoped" onload="getLaunchJobListForProfile('kx-main'); getLaunchJobListForProfile('kx-node');">   </style>-->
        <!--<style scoped="scoped" onload="getLaunchJobListForProfile(); getLaunchJobListForProfile();">   </style>-->
    </div>

    <style scoped="scoped" onload="populateReviewTable(); getBuildJobListForProfile('KX.AS.CODE_Runtime_Actions', 'kx-launch');">   </style>

    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (review_and_launch.groovy): ${e}"
}
