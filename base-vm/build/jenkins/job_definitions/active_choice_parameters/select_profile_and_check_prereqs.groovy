    import groovy.json.JsonSlurper
    import groovy.json.JsonBuilder
    import static groovy.io.FileType.FILES
    import javax.swing.text.html.HTML

    def githubKxVersion
    def githubKubeVersion
    def localKxVersion
    def localKubeVersion
    def vagrantPluginName
    def vagrantPluginVersion
    def vagrantVmwarePluginInstalled
    def vagrantParallelsPluginInstalled
    def parallelsExecutableExists
    def vboxExecutableExists
    def vmwareExecutableExists
    def boxesList = []
    def virtualboxLocalVagrantBoxMainExists
    def virtualboxLocalVagrantBoxMainVersion
    def virtualboxLocalVagrantBoxNodeExists
    def virtualboxLocalVagrantBoxNodeVersion
    def vmwareLocalVagrantBoxMainExists
    def vmwareLocalVagrantBoxMainVersion
    def vmwareLocalVagrantBoxNodeExists
    def vmwareLocalVagrantBoxNodeVersion
    def parallelsLocalVagrantBoxMainExists
    def parallelsLocalVagrantBoxMainVersion
    def parallelsLocalVagrantBoxNodeExists
    def parallelsLocalVagrantBoxNodeVersion
    def extendedDescription
    def profilePaths = []
    def boxDirectories = []
    def currentDir
    def virtualboxKxMainVagrantCloudVersion
    def virtualboxKxNodeVagrantCloudVersion
    def vmwareDesktopKxMainVagrantCloudVersion
    def vmwareDesktopKxNodeVagrantCloudVersion
    def parallelsKxMainVagrantCloudVersion
    def parallelsKxNodeVagrantCloudVersion

    try {

        extendedDescription = "Welcome to KX.AS.CODE. In this panel you can select the profile. A check is made on the system to see if the necessary virtualization software and associated Vagrant plugins are installed, s well as availability of built Vagrant boxes. An attempt is made to automatically select the profile based on discovered pre-requisites."

        currentDir = new File(".").getAbsolutePath().replaceAll("\\\\", "/")
        currentDir = currentDir.substring(0, currentDir.length() - 1)

        new File("${currentDir}/jenkins_shared_workspace/kx.as.code/profiles/").eachDirMatch(~/.*vagrant.*/) { profilePaths << it.path }

        String underlyingOS

        def OS = System.getProperty("os.name", "generic").toLowerCase(Locale.ENGLISH);
        if ((OS.indexOf("mac") >= 0) || (OS.indexOf("darwin") >= 0)) {
            underlyingOS = "darwin"
        } else if (OS.indexOf("win") >= 0) {
            underlyingOS = "windows"
            profilePaths.removeAll { it.toLowerCase().endsWith('parallels') }
        } else if (OS.indexOf("nux") >= 0) {
            underlyingOS = "linux"
        } else {
            underlyingOS = "other"
        }

        profilePaths.sort()
        profilePaths = profilePaths.join(",")
        profilePaths = profilePaths.replaceAll("\\\\", "/")

    } catch (e) {
        println("Something went wrong in the GROOVY block (select_profile_and_check_prereqs.groovy): ${e}")
    }

    try {

        Process vagrantCloudAvailableKxBoxVersions = ["vagrant", "cloud", "search", "kxascode", "--sort-by", "updated", "--provider", "virtualbox", "--json"].execute()
        def parsedVagrantCloudBoxesJson = new JsonSlurper().parseText(vagrantCloudAvailableKxBoxVersions.text)

        def virtualboxKxMainVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll { it.providers == "virtualbox" && it.name == "kxascode/kx-main" }
        def virtualboxKxNodeVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll { it.providers == "virtualbox" && it.name == "kxascode/kx-node" }

        def vmwareDesktopKxMainVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll { it.providers == "vmware_desktop" && it.name == "kxascode/kx-main" }
        def vmwareDesktopKxNodeVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll { it.providers == "vmware_desktop" && it.name == "kxascode/kx-node" }

        def parallelsKxMainVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll { it.providers == "parallels" && it.name == "kxascode/kx-main" }
        def parallelsKxNodeVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll { it.providers == "parallels" && it.name == "kxascode/kx-node" }

        if (virtualboxKxMainVagrantCloudVersions) {
            virtualboxKxMainVagrantCloudVersion = virtualboxKxMainVagrantCloudVersions[0].version
        } else {
            virtualboxKxMainVagrantCloudVersion = "-"
        }

        if (virtualboxKxNodeVagrantCloudVersions) {
            virtualboxKxNodeVagrantCloudVersion = virtualboxKxNodeVagrantCloudVersions[0].version
        } else {
            virtualboxKxNodeVagrantCloudVersion = "-"
        }

        if (vmwareDesktopKxMainVagrantCloudVersions) {
            vmwareDesktopKxMainVagrantCloudVersion = vmwareDesktopKxMainVagrantCloudVersions[0].version
        } else {
            vmwareDesktopKxMainVagrantCloudVersion = "-"
        }

        if (vmwareDesktopKxNodeVagrantCloudVersions) {
            vmwareDesktopKxNodeVagrantCloudVersion = vmwareDesktopKxNodeVagrantCloudVersions[0].version
        } else {
            vmwareDesktopKxNodeVagrantCloudVersion = "-"
        }

        if (parallelsKxMainVagrantCloudVersions) {
            parallelsKxMainVagrantCloudVersion = parallelsKxMainVagrantCloudVersions[0].version
        } else {
            parallelsKxMainVagrantCloudVersion = "-"
        }

        if (parallelsKxNodeVagrantCloudVersions) {
            parallelsKxNodeVagrantCloudVersion = parallelsKxNodeVagrantCloudVersions[0].version
        } else {
            parallelsKxNodeVagrantCloudVersion = "-"
        }

    } catch (e) {
        println("Something went wrong in the GROOVY block -> getting vagrant cloud boxes (select_profile_and_check_prereqs.groovy): ${e}")
    }

    try {

        //TODO - change this away from hardcoded user URL - current entry for debugging only
        def githubVersionJson = new JsonSlurper().parse('https://raw.githubusercontent.com/patdel76/kx/main/versions.json'.toURL())
        githubKxVersion = githubVersionJson.kxascode
        githubKubeVersion = githubVersionJson.kubernetes

        def localVersionFile = "${currentDir}/jenkins_shared_workspace/kx.as.code/versions.json"
        def localVersionJson = new File(localVersionFile)
        def parsedLocalVersionJson = new JsonSlurper().parse(localVersionJson)

        localKxVersion = parsedLocalVersionJson.kxascode
        localKubeVersion = parsedLocalVersionJson.kubernetes


        def OS = System.getProperty("os.name", "generic").toLowerCase(Locale.ENGLISH);
        def virtualboxPath
        def vmwareWorkstationPath
        def vmwareVagrantWorkstationPlugin = "vagrant-vmware-desktop"
        def parallelsPath
        def parallelsVagrantPlugin = "vagrant-parallels"

        if ((OS.indexOf("mac") >= 0) || (OS.indexOf("darwin") >= 0)) {
            underlyingOS = "darwin"
            virtualboxPath = "/Applications/VirtualBox.app/Contents/MacOS/VirtualBox"
            vmwareWorkstationPath = "/Applications/VMware Fusion.app/Contents/MacOS/VMware Fusion"
            parallelsPath = "/Applications/Parallels Desktop.app/Contents/MacOS/prl_client_app"
        } else if (OS.indexOf("win") >= 0) {
            underlyingOS = "windows"
            virtualboxPath = "C:/Program Files/Oracle/VirtualBox/VirtualBox.exe"
            vmwareWorkstationPath = "C:/Program Files (x86)/VMware/VMware Workstation/vmware.exe"
        } else if (OS.indexOf("nux") >= 0) {
            underlyingOS = "linux"
            virtualboxPath = "/usr/bin/VirtualBox"
            vmwareWorkstationPath = "/usr/bin/vmware"
        } else {
            underlyingOS = "other"
        }

        def systemCheckJsonFilePath = "${currentDir}/jenkins_shared_workspace/kx.as.code/system-check.json"
        def systemCheckJsonFile = new File(systemCheckJsonFilePath)

        parallelsExecutableExists = ""
        if (underlyingOS == "darwin") {
            File parallelsExecutable = new File(parallelsPath)
            parallelsExecutableExists = parallelsExecutable.exists()
        } else {
            parallelsExecutableExists = false
        }

        File vboxExecutable = new File(virtualboxPath)
        vboxExecutableExists = vboxExecutable.exists()
        File vmwareExecutable = new File(vmwareWorkstationPath)
        vmwareExecutableExists = vmwareExecutable.exists()

        vagrantPluginList = 'vagrant plugin list'.execute().text
        vagrantPluginList = new String(vagrantPluginList).split('\n')

        for (vagrantPlugin in vagrantPluginList) {
            vagrantPluginSplit = vagrantPlugin.split(" ")
            vagrantPluginName = vagrantPluginSplit[0]
            vagrantPluginVersion = vagrantPluginSplit[1]
            if (vagrantPluginName == "vagrant-vmware-desktop") {
                vagrantVmwarePluginInstalled = true
            } else if (vagrantPluginName == "vagrant-parallels") {
                vagrantParallelsPluginInstalled = true
            }
        }

        def builder = new JsonBuilder()
        def jsonSlurper = new JsonSlurper()

        def vagrantJson = jsonSlurper.parseText('{ "system": { "vagrantVmwarePluginInstalled": "' + vagrantVmwarePluginInstalled + '", "vagrantParallelsPluginInstalled": "' + vagrantParallelsPluginInstalled + '", "parallelsExecutable": "' + parallelsExecutableExists + '", "vboxExecutable": "' + vboxExecutableExists + '", "vmwareExecutable": "' + vmwareExecutableExists + '"}}')

        def boxParentDir
        def boxFilename
        def splitboxVersion
        def splitboxProvider
        def splitboxNodeType
        def concatendatedBoxVar
        new File("${currentDir}/jenkins_shared_workspace/kx.as.code/base-vm/boxes/").traverse(type: FILES, maxDepth: 1) {
            if (it.name.endsWith('.box')) {
                boxParentDir = it.getParentFile().getName()
                boxFilename = it.name
                splitboxVersion = boxParentDir.substring(boxParentDir.lastIndexOf("-") + 1, boxParentDir.size())
                splitboxProvider = boxParentDir.substring(0, boxParentDir.lastIndexOf("-"))
                splitboxNodeType = boxFilename.substring(0, boxFilename.lastIndexOf("-"))
                boxDirectories << [splitboxVersion, splitboxProvider, splitboxNodeType]
            }
        }

        def filteredVirtualBoxKxNodeList = boxDirectories.findAll {
            it[1] == "virtualbox" && it[2] == "kx-node"
        }.sort { a, b -> a[0] <=> b[1] }

        def filteredVirtualBoxKxMainList = boxDirectories.findAll {
            it[1] == "virtualbox" && it[2] == "kx-main"
        }.sort { a, b -> a[0] <=> b[1] }

        println "filteredVirtualBoxKxNodeList list: " + filteredVirtualBoxKxNodeList
        println "filteredVirtualBoxKxMainList list: " + filteredVirtualBoxKxMainList

        if (filteredVirtualBoxKxMainList) {
            virtualboxLocalVagrantBoxMainVersion = filteredVirtualBoxKxMainList[0][0]
            virtualboxLocalVagrantBoxMainExists = "true"
            println "virtualboxLocalVagrantBoxMainVersion: " + virtualboxLocalVagrantBoxMainVersion
        }

        if (filteredVirtualBoxKxNodeList) {
            virtualboxLocalVagrantBoxNodeVersion = filteredVirtualBoxKxNodeList[0][0]
            virtualboxLocalVagrantBoxNodeExists = "true"
            println "virtualboxLocalVagrantBoxNodeVersion: " + virtualboxLocalVagrantBoxNodeVersion
        }

        def filteredVmwareDesktopKxNodeList = boxDirectories.findAll {
            it[1] == "vmware-desktop" && it[2] == "kx-node"
        }.sort{ a,b -> a[0] <=> b[1] }

        def filteredVmwareDesktopKxMainList = boxDirectories.findAll {
            it[1] == "vmware-desktop" && it[2] == "kx-main"
        }.sort{ a,b -> a[0] <=> b[1] }

        println "filteredVmwareDesktopKxNodeList list: " + filteredVmwareDesktopKxNodeList
        println "filteredVmwareDesktopKxMainList list: " + filteredVmwareDesktopKxMainList

        if (filteredVmwareDesktopKxMainList) {
            vmwareLocalVagrantBoxMainVersion = filteredVmwareDesktopKxMainList[0][0]
            vmwareLocalVagrantBoxMainExists = "true"
            println "vmwareLocalVagrantBoxMainVersion: " + vmwareLocalVagrantBoxMainVersion
        }

        if (filteredVmwareDesktopKxNodeList) {
            vmwareLocalVagrantBoxNodeVersion = filteredVmwareDesktopKxNodeList[0][0]
            vmwareLocalVagrantBoxNodeExists = "true"
            println "vmwareLocalVagrantBoxNodeVersion: " + vmwareLocalVagrantBoxNodeVersion
        }

        def filteredParallelsKxNodeList = boxDirectories.findAll {
            it[1] == "parallels" && it[2] == "kx-node"
        }.sort{ a,b -> a[0] <=> b[1] }

        def filteredParallelsKxMainList = boxDirectories.findAll {
            it[1] == "parallels" && it[2] == "kx-main"
        }.sort{ a,b -> a[0] <=> b[1] }

        println "filteredParallelsKxNodeList list: " + filteredParallelsKxNodeList
        println "filteredParallelsKxMainList list: " + filteredParallelsKxMainList

        if (filteredParallelsKxMainList) {
            parallelsLocalVagrantBoxMainVersion = filteredParallelsKxMainList[0][0]
            parallelsLocalVagrantBoxMainExists = "true"
            println "parallelsLocalVagrantBoxMainVersion: " + parallelsLocalVagrantBoxMainVersion
        }

        if (filteredParallelsKxNodeList) {
            parallelsLocalVagrantBoxNodeVersion = filteredParallelsKxNodeList[0][0]
            parallelsLocalVagrantBoxNodeExists = "true"
            println "parallelsLocalVagrantBoxNodeVersion: " + parallelsLocalVagrantBoxNodeVersion
        }

        def boxesJson = jsonSlurper.parseText('{ "boxes": { "virtualboxLocalVagrantBoxMainExists": "' + virtualboxLocalVagrantBoxMainExists + '", "virtualboxLocalVagrantBoxMainVersion": "' + virtualboxLocalVagrantBoxMainVersion + '", "virtualboxLocalVagrantBoxNodeExists": "' + virtualboxLocalVagrantBoxNodeExists + '", "virtualboxLocalVagrantBoxNodeVersion": "' + virtualboxLocalVagrantBoxNodeVersion + '", "vmwareLocalVagrantBoxMainExists": "' + vmwareLocalVagrantBoxMainExists + '", "vmwareLocalVagrantBoxMainVersion": "' + vmwareLocalVagrantBoxMainVersion + '", "vmwareLocalVagrantBoxNodeExists": "' + vmwareLocalVagrantBoxNodeExists + '", "vmwareLocalVagrantBoxNodeVersion": "' + vmwareLocalVagrantBoxNodeVersion + '", "parallelsLocalVagrantBoxMainExists": "' + parallelsLocalVagrantBoxMainExists + '", "parallelsLocalVagrantBoxMainVersion": "' + parallelsLocalVagrantBoxMainVersion + '", "parallelsLocalVagrantBoxNodeExists": "' + parallelsLocalVagrantBoxNodeExists + '", "parallelsLocalVagrantBoxNodeVersion": "' + parallelsLocalVagrantBoxNodeVersion + '"}}')
        try {
            builder boxesJson
            builder vagrantJson
            def mergedJson = boxesJson + vagrantJson
            builder mergedJson

            new File(systemCheckJsonFilePath).write(builder.toPrettyString())
        } catch (e) {
            println("Error creating and writing system check JSON file: " + e)
        }

    } catch (e) {
        println "Something went wrong in the GROOVY block (select_profile_and_check_prereqs.groovy): ${e}"
    }


    try {
        // language=HTML
        def HTML = """
    <body>
        <div id="headline-select-profile-div" style="display: none;">
        <span>
        <h1>Select Profile &amp; Check Pre-Requisites</h1>
        <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
        </div>
        <div id="select-profile-div" style="display: none;">
            <br>
            <label for="profiles" class="input-box-label" style="margin: 0px;">Profiles</label>
            <select id="profiles" class="profiles-select capitalize" value="Virtualbox" onchange="updateProfileAndPrereqsCheckTab();">
            </select>
            </label>
    </span>
    <span style="margin-left: 30px; display: inline-flex;">
            <span class="button-range-span">
                <span><button type="button" class="selection-label selection-label-header">Start Mode</button></span>
            </span>
            <span id="normal" class="button-range-span selection-span" onclick="updateStartModeSelection(this.id)">
                <span id="selection-normal-radio" class="selection-radio selection-radio-selected"><img id="selection-normal-svg" src="/userContent/icons/radiobox-marked.svg" class="svg-blue"></span><span id="selection-normal-label" class="selection-label selection-label-selected">Normal</span>
            </span>
            <span id="lite" class="button-range-span selection-span" onclick="updateStartModeSelection(this.id)">
                <span id="selection-lite-radio" class="selection-radio selection-radio-unselected"><img id="selection-lite-svg" src="/userContent/icons/radiobox-blank.svg" class="svg-blue"></span><span id="selection-lite-label" class="selection-label selection-label-unselected">Lite</span>
            </span>
            <span id="minimal" class="button-range-span selection-span" onclick="updateStartModeSelection(this.id)">
                <span id="selection-minimal-radio" class="selection-radio selection-radio-unselected"><img id="selection-minimal-svg" src="/userContent/icons/radiobox-blank.svg" class="svg-blue"></span><span id="selection-minimal-label" class="selection-label selection-label-unselected" style="border: 1px solid var(--kx-material-primary-70); border-width: 1px 1px 1px 0; border-radius: 0 5px 5px 0px;">Minimal</span>
            </span>
    </span>
            
        </div>
        <input type="hidden" id="concatenated-profile-selection" name="value" value="">
        <style scoped="scoped" onload="populate_profile_option_list();">   </style>

        <div id="prerequisites-div" style="display: none;">
            <br>
            <h2>Pre-requisite Checks</h2>
            <div span style="width: 1100px; height: 100px; display: flex;">
            <span style="width: 100%; height: 100px; display: inline-block;">
                <span style="height: 33px;"><h4>Virtualization Pre-Requisites</h4></span>
                <div><span class="checklist-span"><img src="" id="virtualization-svg" class="" style="height: 33px;" alt="virtualization-svg" /></span><span id="virtualization-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="local-main-version-status-svg" class="" alt="local-main-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Local KX-Main Box Version: </span><span id="kx-main-local-box-version" class="checklist-span" style="width: 140px;display:inline-block;"></span><span class="checklist-span"><img src="" id="cloud-main-version-status-svg" class="" alt="cloud-main-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Cloud KX-Main Box Version: </span><span id="kx-main-vagrant-cloud-box-version" class="checklist-span" style="width: 100px;display:inline-block;"></span></div>
                <div><span class="checklist-span"><img src="" id="vagrant-plugin-svg" class="" style="height: 33px;" alt="vagrant-plugin-svg" /></span><span id="vagrant-plugin-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="local-node-version-status-svg" class="" alt="local-node-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Local KX-Node Box Version: </span><span id="kx-node-local-box-version" class="checklist-span" style="width: 140px;display:inline-block;"></span><span class="checklist-span"><img src="" id="cloud-node-version-status-svg" class="" alt="cloud-node-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Cloud Kx-Node Box Version: </span><span id="kx-node-vagrant-cloud-box-version" class="checklist-span" style="width: 100px;display:inline-block;"></span></div>
            </span>
            </div>
            <br>
            <div style="width: 500px; height: 80px; display: inline-block;">
                <span style="height: 33px;"><h4>KX.AS.CODE Source</h4></span>
                <div><span class="checklist-span" style="width: 35px; height: 46px; display: inline-block; vertical-align: top;"><img src="" id="version-check-svg" class="" alt="version-check-svg" /></span><span class="checklist-span" style="width: 450px; height: 66px; display: inline-block; vertical-align: top;" id="version-check-message"></span></div>
            </div>
            <style scoped="scoped" onload="getAvailableLocalBoxes(); getAvailableCloudBoxes(); compareVersions(); checkVagrantPreRequisites(); updateProfileSelection(); change_panel_selection('config-panel-profile-selection');">   </style>
            <input type="hidden" id="system-prerequisites-check" name="system-prerequisites-check" value="">
        </div>

        <div id="profile-builds-div" style="display: none;">
            <br>

            <div class="div-border-text-inline">
                <h2 class="h2-header-in-line"><span class="span-h2-header-in-line"><img class="svg-blue" src="/userContent/icons/robot-industrial-outline.svg" height="25" width="25">&nbsp;Builder Config Panel</span></h2>
                <div class="div-inner-h2-header-in-line-wrapper">
                    <span class="description-paragraph-span"><p>Below you can see the last executed builds for each image tpe if there were any. If none, then click the play button for each type of node.</p></span>
                </div>
                <div style="width: 100%;">
                    <span style="width: 940px;">
                        <span class="build-action-text-label">KX-Main Build Date: </span><span id="kx-main-build-timestamp" class="build-action-text-value"></span>
                        <span class="build-action-text-label" style="width: 100px;">Build Status: </span><span id="kx-main-build-result" class="build-action-text-value build-action-text-value-result" style="width: 100px; margin-right: 20px; display: inline-flex; line-height: normal;"></span>
                        <span class="build-action-text-label" style="width: 110px; margin-left: 20px;">Build Version: </span><span id="kx-main-build-kx-version" style="width: 100px;" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-action-text-label" style="width: 110px;">Kube Version: </span><span id="kx-main-build-kube-version" style="width: 80px;" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-number-span" style="margin-right: 25px;" id="kx-main-build-number-link"></span>
                    </span>
                    <span class='span-rounded-border'>
                        <img src='/userContent/icons/play.svg' class="build-action-icon" title="Start Build" alt="Start Build" onclick='triggerBuild("kx-main");' />|
                        <img src='/userContent/icons/cancel.svg' class="build-action-icon" title="Cancel Build" alt="Cancel Build" onclick='stopTriggeredBuild("KX.AS.CODE_Image_Builder", "kx-main");' />|
                        <div class="console-log"><span class="console-log-span"><img src="/userContent/icons/text-box-outline.svg" onMouseover='showConsoleLog("KX.AS.CODE_Image_Builder", "kx-main");' onclick='openFullConsoleLog("KX.AS.CODE_Image_Builder", "kx-main");' class="build-action-icon" alt="View Build Log" title="Click to open full log in new tab"><span class="consolelogtext" id='kxMainBuildConsoleLog'></span></span></div>
                    </span>
                </div>
                    <div style="width: 100%;">
                        <span style="width: 940px;">
                        <span class="build-action-text-label">KX-Node Build Date: </span><span id="kx-node-build-timestamp" class="build-action-text-value"></span>
                        <span class="build-action-text-label" style="width: 100px;">Build Status: </span><span id="kx-node-build-result" class="build-action-text-value build-action-text-value-result" style="width: 100px; margin-right: 20px; display: inline-flex; line-height: normal;"></span>
                        <span class="build-action-text-label" style="width: 110px; margin-left: 20px;">Build Version: </span><span id="kx-node-build-kx-version" style="width: 100px;" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-action-text-label" style="width: 110px;">Kube Version: </span><span id="kx-node-build-kube-version" style="width: 80px;" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-number-span" style="margin-right: 25px;" id="kx-node-build-number-link"></span>
                    </span>
                    <span class='span-rounded-border'>
                        <img src='/userContent/icons/play.svg' class="build-action-icon" title="Start Build" alt="Start Build" onclick='triggerBuild("kx-node");' />|
                        <img src='/userContent/icons/cancel.svg' class="build-action-icon" title="Cancel Build" alt="Cancel Build" onclick='stopTriggeredBuild("KX.AS.CODE_Image_Builder", "kx-node");' />|
                        <div class="console-log"><span class="console-log-span"><img src="/userContent/icons/text-box-outline.svg" onMouseover='showConsoleLog("KX.AS.CODE_Image_Builder", "kx-node");' onclick='openFullConsoleLog("KX.AS.CODE_Image_Builder", "kx-node");' class="build-action-icon" alt="View Build Log" title="Click to open full log in new tab"><span class="consolelogtext" id='kxNodeBuildConsoleLog'></span></span></div>
                    </span>
                </div>
                <style scoped='scoped' onload='getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-main"); getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-node");'>   </style>
                
                <input type="hidden" id="local-kx-version" value='${localKxVersion}' >
                <input type="hidden" id="github-kx-version" value='${githubKxVersion}' >
                <input type="hidden" id="local-kube-version" value='${localKubeVersion}' >
                <input type="hidden" id="github-kube-version" value='${githubKubeVersion}' >
                <input type="hidden" id="profile-paths" value='${profilePaths}' >
                <input type="hidden" id="virtualbox-local-vagrant-box-main-version" value='${virtualboxLocalVagrantBoxMainVersion}' >
                <input type="hidden" id="virtualbox-local-vagrant-box-node-version" value='${virtualboxLocalVagrantBoxNodeVersion}' >
                <input type="hidden" id="vmware-local-vagrant-box-main-version" value='${vmwareLocalVagrantBoxMainVersion}' >
                <input type="hidden" id="vmware-local-vagrant-box-node-version" value='${vmwareLocalVagrantBoxNodeVersion}' >
                <input type="hidden" id="parallels-local-vagrant-box-main-version" value='${parallelsLocalVagrantBoxMainVersion}' >
                <input type="hidden" id="parallels-local-vagrant-box-node-version" value='${parallelsLocalVagrantBoxNodeVersion}' >
                <input type="hidden" id="virtualbox-kx-main-vagrant-cloud-version" value='${virtualboxKxMainVagrantCloudVersion}' >
                <input type="hidden" id="virtualbox-Kx-node-vagrant-cloud-version" value='${virtualboxKxNodeVagrantCloudVersion}' >
                <input type="hidden" id="vmware-desktop-kx-main-vagrant-cloud-version" value='${vmwareDesktopKxMainVagrantCloudVersion}' >
                <input type="hidden" id="vmware-desktop-kx-node-vagrant-cloud-version" value='${vmwareDesktopKxNodeVagrantCloudVersion}' >
                <input type="hidden" id="parallels-kx-main-vagrant-cloud-Version" value='${parallelsKxMainVagrantCloudVersion}' >
                <input type="hidden" id="parallels-kx-node-vagrant-cloud-version" value='${parallelsKxNodeVagrantCloudVersion}' >
                <input type="hidden" id="vbox-executable-exists" value='${vboxExecutableExists}' >
                <input type="hidden" id="parallels-executable-exists" value='${parallelsExecutableExists}' >
                <input type="hidden" id="vmware-executable-exists" value='${vmwareExecutableExists}' >
                <input type="hidden" id="vbox-vagrant-plugin-installed" value='true' >
                <input type="hidden" id="vmware-vagrant-plugin-installed" value='${vagrantVmwarePluginInstalled}' >
                <input type="hidden" id="parallels-vagrant-plugin-installed" value='${vagrantParallelsPluginInstalled}' >
                <input type="hidden" id="virtualbox-local-vagrant-box-main-exists" value='${virtualboxLocalVagrantBoxMainExists}' >
                <input type="hidden" id="virtualbox-local-vagrant-box-node-exists" value='${virtualboxLocalVagrantBoxNodeExists}' >
                <input type="hidden" id="vmware-local-vagrant-box-main-exists" value='${vmwareLocalVagrantBoxMainExists}' >
                <input type="hidden" id="vmware-local-vagrant-box-node-exists" value='${vmwareLocalVagrantBoxNodeExists}' >
                <input type="hidden" id="parallels-local-vagrant-box-main-exists" value='${parallelsLocalVagrantBoxMainExists}' >
                <input type="hidden" id="parallels-local-vagrant-box-node-exists" value='${parallelsLocalVagrantBoxNodeExists}' >
                
            </div>
        </div>
    </body>
    """
        return HTML
    } catch (e) {
        println "Something went wrong in the HTML return block (select_profile_and_check_prereqs.groovy): ${e}"
    }


