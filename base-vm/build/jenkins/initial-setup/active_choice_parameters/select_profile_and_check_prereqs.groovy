import groovy.json.JsonSlurper
import groovy.json.JsonBuilder

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
def virtualboxMainExists
def virtualboxMainVersion
def virtualboxNodeExists
def virtualboxNodeVersion
def vmwareMainExists
def vmwareMainVersion
def vmwareNodeExists
def vmwareNodeVersion
def parallelsMainExists
def parallelsMainVersion
def parallelsNodeExists
def parallelsNodeVersion
def extendedDescription
def profilePaths = []
def boxDirectories = []

try {

    extendedDescription = "Welcome to KX.AS.CODE. In this panel you can select the profile. A check is made on the system to see if the necessary virtualization software and associated Vagrant plugins are installed, s well as availability of built Vagrant boxes. An attempt is made to automatically select the profile based on discovered pre-requisites."

    new File('jenkins_shared_workspace/kx.as.code/profiles/').eachDirMatch(~/.*vagrant.*/) { profilePaths << it.path }

    String underlyingOS
    println profilePaths

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
    println("After OS and before sort()")

    profilePaths.sort()
    profilePaths = profilePaths.join(",")
    profilePaths = profilePaths.replaceAll("\\\\", "/")
    println(profilePaths)
    println("End of get_profiles.groovy GROOVY code")
} catch(e) {
    println("Something went wrong in the GROOVY block (select_profile_and_check_prereqs.groovy): ${e}")
}

try {
    println("Entered check prerequisites - BEGINNING")

    //TODO - changes this away from hardcoded user URL - current entry for debugging only
    def githubVersionJson = new JsonSlurper().parse('https://raw.githubusercontent.com/patdel76/kx/main/versions.json'.toURL())
    githubKxVersion = githubVersionJson.kxascode
    githubKubeVersion = githubVersionJson.kubernetes

    def localVersionFile = 'jenkins_shared_workspace/kx.as.code/versions.json'
    def localVersionJson = new File(localVersionFile)
    def parsedLocalVersionJson = new JsonSlurper().parse(localVersionJson)

    localKxVersion = parsedLocalVersionJson.kxascode
    localKubeVersion = parsedLocalVersionJson.kubernetes

    println("Check prerequisites - Before OS check")

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

    println("Check prerequisites - After OS check")
    def systemCheckJsonFilePath = 'jenkins_shared_workspace/kx.as.code/system-check.json'
    def systemCheckJsonFile = new File(systemCheckJsonFilePath)

    // TODO - changed to (!) for debugging only
    if (! systemCheckJsonFile.exists()) {

        def parsedJson = new JsonSlurper().parse(systemCheckJsonFile)
        println("parsedJson.boxes:" + parsedJson.boxes)
        println("parsedJson.system:" + parsedJson.system)

        parallelsExecutableExists = parsedJson.system.parallelsExecutable
        vboxExecutableExists = parsedJson.system.vboxExecutable
        vmwareExecutableExists = parsedJson.system.vmwareExecutable

        vagrantVmwarePluginInstalled = parsedJson.system.vagrantVmwarePluginInstalled
        vagrantParallelsPluginInstalled = parsedJson.system.vagrantParallelsPluginInstalled

        virtualboxMainExists = parsedJson.boxes.virtualboxMainExists
        virtualboxMainVersion = parsedJson.boxes.virtualboxMainVersion
        virtualboxNodeExists = parsedJson.boxes.virtualboxNodeExists
        virtualboxNodeVersion = parsedJson.boxes.virtualboxNodeVersion
        vmwareMainExists = parsedJson.boxes.vmwareMainExists
        vmwareMainVersion = parsedJson.boxes.vmwareMainVersion
        vmwareNodeExists = parsedJson.boxes.vmwareNodeExists
        vmwareNodeVersion = parsedJson.boxes.vmwareNodeVersion
        parallelsMainExists = parsedJson.boxes.parallelsMainExists
        parallelsMainVersion = parsedJson.boxes.parallelsMainVersion
        parallelsNodeExists = parsedJson.boxes.parallelsNodeExists
        parallelsNodeVersion = parsedJson.boxes.parallelsNodeVersion

    } else {

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

        println("vagrant: ${vagrantJson}")

        new File("jenkins_shared_workspace/kx.as.code/base-vm/boxes/").eachDir {boxDirectories << it.name }
        println(boxDirectories)
        println("box 0: ${boxDirectories[0]}")
        println("box 1: ${boxDirectories[1]}")
        println("box 3: ${boxDirectories[3]}")
        println(boxDirectories[0].substring(0,boxDirectories[0].lastIndexOf("-")))
        println(boxDirectories[3].substring(0,boxDirectories[3].lastIndexOf("-")))

        println(boxDirectories[3].substring(0,boxDirectories[3].lastIndexOf("-")).length())

        boxDirectories[3].substring(0,boxDirectories[3].lastIndexOf("-")).length()
        boxDirectories[0].length()

        println("*1*")
        println(boxDirectories[3].lastIndexOf("-").toString().length())
        println("*2*")

        println(boxDirectories[2].substring(0,boxDirectories[2].lastIndexOf("-")))
        println(boxDirectories[2].substring(boxDirectories[2].substring(0,boxDirectories[2].lastIndexOf("-")).length()+1,boxDirectories[2].length()))

        def boxDirectoryList = []
        def provider
        def version
        boxDirectories.eachWithIndex { boxDirectory, i ->
            println boxDirectory
            println i
            boxProvider = boxDirectories[i].substring(0,boxDirectories[i].lastIndexOf("-"))
            boxVersion = boxDirectories[i].substring(boxDirectories[i].substring(0,boxDirectories[i].lastIndexOf("-")).length()+1,boxDirectories[i].length())
            println("provider: ${boxProvider}, version: ${boxVersion}")

            new File("jenkins_shared_workspace/kx.as.code/base-vm/boxes/${boxDirectory}/").eachFile {boxDirectoryList << it.name }
            boxDirectoryList.eachWithIndex { box, j ->
                if (box.endsWith('.box')) {
                    boxName = box.substring(0,box.lastIndexOf("-"))
                    println("provider: ${boxProvider}, box: ${boxName}, version: ${boxVersion}")
                    if(boxName == "kx-main" || boxName == "kx-node") {
                        boxesList.add('"' + boxName + " " + boxProvider + " " + boxVersion + '"')
                        if (boxName == "kx-main" && boxProvider == "virtualbox") {
                            virtualboxMainExists = "true"
                            virtualboxMainVersion = boxVersion
                        }
                        if (boxName == "kx-node" && boxProvider == "virtualbox") {
                            virtualboxNodeExists = "true"
                            virtualboxNodeVersion = boxVersion
                        }
                        if (boxName == "kx-main" && boxProvider == "vmware-desktop") {
                            vmwareMainExists = "true"
                            vmwareMainVersion = boxVersion

                        }
                        if (boxName == "kx-node" && boxProvider == "vmware-desktop") {
                            vmwareNodeExists = "true"
                            vmwareNodeVersion = boxVersion

                        }
                        if (boxName == "kx-main" && boxProvider == "parallels") {
                            parallelsMainExists = "true"
                            parallelsMainVersion = boxVersion

                        }
                        if (boxName == "kx-node" && boxProvider == "parallels") {
                            parallelsNodeExists = "true"
                            parallelsNodeVersion = boxVersion
                        }
                    }
                }
            }
        }
        println(boxesList)
        println("All boxes: " + boxesList)
        println("0: " + boxesList[0])
        println("1: " + boxesList[1])

        def boxesJson = jsonSlurper.parseText('{ "boxes": { "virtualboxMainExists": "' + virtualboxMainExists + '", "virtualboxMainVersion": "' + virtualboxMainVersion + '", "virtualboxNodeExists": "' + virtualboxNodeExists + '", "virtualboxNodeVersion": "' + virtualboxNodeVersion + '", "vmwareMainExists": "' + vmwareMainExists + '", "vmwareMainVersion": "' + vmwareMainVersion + '", "vmwareNodeExists": "' + vmwareNodeExists + '", "vmwareNodeVersion": "' + vmwareNodeVersion + '", "parallelsMainExists": "' + parallelsMainExists + '", "parallelsMainVersion": "' + parallelsMainVersion + '", "parallelsNodeExists": "' + parallelsNodeExists + '", "parallelsNodeVersion": "' + parallelsNodeVersion + '"}}')

        println(boxesJson)

        try {
            builder boxesJson
            builder vagrantJson

            def mergedJson = boxesJson + vagrantJson

            builder mergedJson

            println builder.toPrettyString()

            new File(systemCheckJsonFilePath).write(builder.toPrettyString())
        } catch (e) {
            println("Error creating and writing system check JSON file: " + e)
        }

        println("existingBoxes" + existingBoxes)

    }

    println("Check prerequisites - EOF")

} catch(e) {
    println "Something went wrong in the GROOVY block (select_profile_and_check_prereqs.groovy): ${e}"
}

try {
    // language=HTML
    def HTML = """
      <script>

            async function triggerBuild(nodeType) {
                let jenkinsCrumb = getCrumb();
                console.log("Jenkins Crumb received = " + jenkinsCrumb.value);

                let formData = new FormData();
                formData.append('kx_vm_user', document.getElementById('general-param-username').value);
                formData.append('kx_vm_password', document.getElementById('general-param-password').value);
                formData.append('vagrant_compute_engine_build', 'false');
                formData.append('kx_version_override', '');
                formData.append('kx_domain', document.getElementById('general-param-base-domain').value);
                formData.append('kx_main_hostname', nodeType);
                formData.append('profile', document.getElementById('profiles').value);
                formData.append('profile_path', document.getElementById('selected-profile-path').value);
                formData.append('node_type', nodeType);

                const config = {
                    method: 'POST',
                    headers: {
                        'Authorization': 'Basic ' + btoa('admin:admin'),
                        'Jenkins-Crumb': jenkinsCrumb.value
                    },
                    body: formData
                }

                let response = await fetch('http://localhost:8081/job/Actions/job/KX.AS.CODE_Image_Builder/buildWithParameters', config);
                let data = await response.text();
                console.log(data);
            }

            function populate_profile_option_list() {
                let profiles = "${profilePaths}".split(',');
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
                let profilePaths = "${profilePaths}".split(',');
                let profilePath = profilePaths[selectedOptionNumber] + '/profile-config.json'
                console.log("profileName: " + profilePath)
                document.getElementById("selected-profile-path").value = profilePath;
                document.getElementById("selected-profile-path").setAttribute("selected-profile-path", profilePath) ;
                let parentId = document.getElementById("selected-profile-path").parentNode.id;
                console.log(parentId);
                jQuery('#' + parentId).trigger('change');
            }

          function getAvailableBoxes() {

              console.log("DEBUG: getAvailableBoxes()");
              let boxMainVersion;
              let boxNodeVersion;
              let selectedProfile = document.getElementById("profiles").value;

              try {
                  console.log("Selected profile: " + selectedProfile);
                  switch (selectedProfile) {
                      case "virtualbox":
                          boxMainVersion = "${virtualboxMainVersion}";
                          boxNodeVersion = "${virtualboxNodeVersion}";
                          break;
                      case "vmware-desktop":
                          boxMainVersion = "${vmwareMainVersion}";
                          boxNodeVersion = "${vmwareNodeVersion}";
                          break;
                      case "parallels":
                          boxMainVersion = "${parallelsMainVersion}";
                          boxNodeVersion = "${parallelsNodeVersion}";
                          break;
                      default:
                          console.log("Weird, box type not known. Normally the box type is either VirtualBox, VMWare or Parallels");
                  }

                  console.log('boxMainVersion: ' + boxMainVersion);
                  console.log('boxNodeVersion: ' + boxNodeVersion);

                  if ( boxMainVersion !== "null" ) {
                    document.getElementById("kx-main-version").innerHTML = boxMainVersion;
                    document.getElementById("main-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                    document.getElementById("main-version-status-svg").className = "checklist-status-icon svg-bright-green";
                  } else {
                    document.getElementById("kx-main-version").innerHTML = "<i>Not found</i>";
                    document.getElementById("main-version-status-svg").src = "/userContent/icons/alert-outline.svg";
                    document.getElementById("main-version-status-svg").className = "checklist-status-icon svg-orange-red";
                  }

                  if ( boxNodeVersion !== "null" ) {
                      document.getElementById("kx-node-version").innerHTML = boxNodeVersion;
                      document.getElementById("node-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                      document.getElementById("node-version-status-svg").className = "checklist-status-icon svg-bright-green";
                  } else {
                      document.getElementById("kx-node-version").innerHTML = "<i>Not found</i>";
                      document.getElementById("node-version-status-svg").src = "/userContent/icons/alert-outline.svg";
                      document.getElementById("node-version-status-svg").className = "checklist-status-icon svg-orange-red";
                      document.getElementById('standalone-mode-toggle').value = "true";
                      document.getElementById('workloads_on_master_checkbox').value = "true";
                  }

              } catch(e) {
                    console.log("Error getting box versions: " + e);
              }
          }

          function compareVersions() {
              let githubKxVersion = "${githubKxVersion}";
              let githubKubeVersion = "${githubKubeVersion}";
              let localKxVersion = "${localKxVersion}";
              let localKubeVersion = "${localKubeVersion}";

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

          function checkVagrantPreRequisites() {
              console.log("DEBUG: Inside checkVagrantPreRequisites");
              let selectedProfile = document.getElementById("profiles").value;
              let virtualizationExecutableExists = "";
              let vagrantPluginInstalled = "";

              if ( selectedProfile === "virtualbox" ) {
                  virtualizationExecutableExists = "${vboxExecutableExists}";
                  vagrantPluginInstalled = "true";
              } else if ( selectedProfile === "vmware-desktop" ) {
                  virtualizationExecutableExists = "${vmwareExecutableExists}";
                  vagrantPluginInstalled = "${vagrantVmwarePluginInstalled}";
              } else if ( selectedProfile === "parallels" ) {
                  virtualizationExecutableExists = "${parallelsExecutableExists}";
                  vagrantPluginInstalled = "${vagrantParallelsPluginInstalled}";
              }

              if ( virtualizationExecutableExists === "true" ) {
                  document.getElementById("virtualization-svg").className = "checklist-status-icon svg-bright-green";
                  document.getElementById("virtualization-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                  document.getElementById("virtualization-text").innerHTML = selectedProfile + " is installed";
              } else {
                  document.getElementById("virtualization-svg").className = "checklist-status-icon svg-orange-red";
                  document.getElementById("virtualization-svg").src = "/userContent/icons/alert-outline.svg";
                  document.getElementById("virtualization-text").innerHTML = selectedProfile + " could not be found";
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

          function updateProfileSelection() {
              let selectedProfile = document.getElementById("profiles").value;
              let parallelsExecutableExists = "${parallelsExecutableExists}";
              let vboxExecutableExists = "${vboxExecutableExists}";
              let vmwareExecutableExists = "${vmwareExecutableExists}";
              let vboxVagrantPluginInstalled = "true";
              let vmwareVagrantPluginInstalled = "${vagrantVmwarePluginInstalled}";
              let parallelsPluginInstalled = "${vagrantParallelsPluginInstalled}";
              let virtualboxMainExists = "${virtualboxMainExists}";
              let virtualboxNodeExists = "${virtualboxNodeExists}";
              let vmwareMainExists = "${vmwareMainExists}";
              let vmwareNodeExists = "${vmwareNodeExists}";
              let parallelsMainExists = "${parallelsMainExists}";
              let parallelsNodeExists = "${parallelsNodeExists}";

              console.log("DEBUG: Selected profile: " + selectedProfile);

              let defaultProfile = "";
              let prerequisitesCheckResult = "";
              let selectedProfileCheckResult = "";

              if (sessionStorage.getItem('hasCodeRunBefore') === null) {
                  if ( vboxExecutableExists === "true" && vboxVagrantPluginInstalled === "true" && virtualboxMainExists === "true" && virtualboxNodeExists === "true") {
                      defaultProfile = "virtualbox";
                      if (selectedProfile === "virtualbox") { selectedProfileCheckResult = "full"; }
                      prerequisitesCheckResult = "full";
                  } else if ( vmwareExecutableExists === "true" && vmwareVagrantPluginInstalled === "true" && vmwareMainExists === "true" && vmwareNodeExists === "true" ) {
                      defaultProfile = "vmware-desktop";
                      prerequisitesCheckResult = "full";
                  } else if ( parallelsExecutableExists === "true" && parallelsPluginInstalled === "true" && parallelsMainExists === "true" && parallelsNodeExists === "true" ) {
                      defaultProfile = "parallels";
                      prerequisitesCheckResult = "full";
                  } else if ( vboxExecutableExists === "true" && vboxVagrantPluginInstalled === "true" && virtualboxMainExists === "true" ) {
                      defaultProfile = "virtualbox";
                      prerequisitesCheckResult = "standalone";
                  } else if ( vmwareExecutableExists === "true" && vmwareVagrantPluginInstalled === "true" && vmwareMainExists === "true" ) {
                      defaultProfile = "vmware-desktop";
                      prerequisitesCheckResult = "standalone";
                  } else if ( parallelsExecutableExists === "true" && parallelsPluginInstalled === "true" && parallelsMainExists === "true" ) {
                      defaultProfile = "parallels";
                      prerequisitesCheckResult = "standalone";
                  } else {
                      console.log("DEBUG: Inside else DEFAULT block");
                      prerequisitesCheckResult = "failed";
                  }

                  console.log("default profile will be set to " + defaultProfile);
                  document.getElementById("profiles").value = defaultProfile;

                  // Pre-requisite value must be either "full", "standalone" or "failed"
                  document.getElementById("system-prerequisites-check").value = prerequisitesCheckResult;
                  sessionStorage.hasCodeRunBefore = true;
              }

              if (sessionStorage.getItem('hasCodeRunBefore') !== null) {
                  if ( selectedProfile === "virtualbox" && vboxExecutableExists === "true" && vboxVagrantPluginInstalled === "true" && virtualboxMainExists === "true" && virtualboxNodeExists === "true") {
                      selectedProfileCheckResult = "full";
                  } else if ( selectedProfile === "vmware-desktop" && vmwareExecutableExists === "true" && vmwareVagrantPluginInstalled === "true" && vmwareMainExists === "true" && vmwareNodeExists === "true" ) {
                      selectedProfileCheckResult = "full";
                  } else if ( selectedProfile === "parallels" && parallelsExecutableExists === "true" && parallelsPluginInstalled === "true" && parallelsMainExists === "true" && parallelsNodeExists === "true" ) {
                      selectedProfileCheckResult = "full";
                  } else if ( selectedProfile === "virtualbox" && vboxExecutableExists === "true" && vboxVagrantPluginInstalled === "true" && virtualboxMainExists === "true" ) {
                      selectedProfileCheckResult = "standalone"
                  } else if ( selectedProfile === "vmware-desktop" && vmwareExecutableExists === "true" && vmwareVagrantPluginInstalled === "true" && vmwareMainExists === "true" ) {
                      selectedProfileCheckResult = "standalone";
                  } else if ( selectedProfile === "parallels" && parallelsExecutableExists === "true" && parallelsPluginInstalled === "true" && parallelsMainExists === "true" ) {
                      selectedProfileCheckResult = "standalone";
                  } else {
                      console.log("DEBUG: Inside else SELECTED block");
                      selectedProfileCheckResult = "failed";
                  }

                  // Pre-requisite value must be either "full", "standalone" or "failed"
                  document.getElementById("system-prerequisites-check").value = selectedProfileCheckResult;
                  console.log("selected profile prerequisite check result: " + selectedProfileCheckResult);

              }
              change_panel_selection('config-panel-profile-selection');
          }

      </script>

      <style>

            .capitalize {
                text-transform: capitalize;
            }

            .profiles-select {
                -moz-appearance: none;
                -webkit-appearance: none;
                appearance: none;
                padding-left: 10px;
                margin: -4px;
                cursor: pointer;
                border: none;
                width: 200px;
                height: 40px;
                border-top-right-radius: 5px;
                border-bottom-right-radius: 5px;
                background-image: url("/userContent/icons/chevron-down.svg");
                background-repeat: no-repeat;
                background-position: right;
                background-color: #efefef;
                outline: none;
                border: none;
                box-shadow: none;
            }

            select {
                height: 20px;
                -webkit-border-radius: 0;
                border: 0;
                outline: 1px solid #ccc;
                outline-offset: -1px;
            }

            .profiles-select select {
                 outline: none;
                 border: none;
                 box-shadow: none;
             }

            .profiles-select:focus {
                outline: none;
                border: none;
                box-shadow: none;
            }

          .checklist-status-icon {
              width: 25px;
              height: 25px;
          }

        .console-log {
            position: relative;
            display: inline-block;
        }

        .console-log .consolelogtext {
            width: 800px;
            height: 450px;
            background-color: #404c50;
            color: #ffffff;
            text-align: left;
            padding: 5px 5px;
            border-top-right-radius: 10px;
            border-top-left-radius: 10px;
            border-bottom-left-radius: 10px;
            visibility: hidden;
            position: absolute;
            top: -445px;
            left: -800px;
            z-index: 10;
        }

        .console-log:hover .consolelogtext {
            visibility: visible;
        }

         .console-log-span {
            width: 50px;
            margin-right: 15px;
        }

        .build-number-span {
            width: 40px;
            text-align: center;
            vertical-align: middle;
            display: inline-block;
            margin-right: 20px;
        }

        .build-action-icon {
            width: 30px;
            height: 30px;
            border: none;
            color: #404c50;
            padding: 2px 2px;
            text-decoration: none;
            margin: 2px 2px;
            cursor: pointer;
        }

        .build-action-icon:hover {
            opacity: 50%;
        }

        .build-action-text-label {
            width: 200px;
            height: 30px;
            border: none;
            color: #404c50;
            padding: 2px 2px;
            text-decoration: none;
            margin: 2px 2px;
            display: inline-block;
            vertical-align: middle;
        }

        .build-action-text-value {
            width: 150px;
            height: 30px;
            border: none;
            color: #404c50;
            padding: 2px 2px;
            text-decoration: none;
            margin: 2px 2px;
            display: inline-block;
            vertical-align: middle;
        }

        .build-action-text-value-result {
            width: 100px;
        }

        .span-rounded-border {
            border: 1px solid black;
            border-radius: 5px;
            display: inline-block;
            margin: 2px;
            padding: 1px;
            vertical-align: middle;
        }

      </style>
    <body>
        <div id="headline-select-profile-div" style="display: none;">
        <h1>Select Profile & Check Pre-Requisites</h1>
        <span class="description-paragraph-span"><p>${extendedDescription }</p></span>
        </div>
        <div id="select-profile-div" style="display: none;">
            <br>
            <label for="profiles" class="input-box-label" style="margin: 0px;">Profiles</label>
            <select id="profiles" class="profiles-select capitalize" value="Virtualbox" onchange="update_selected_value(); getAvailableBoxes(); compareVersions(); checkVagrantPreRequisites(); updateProfileSelection();">
            </select>
            </label>
        </div>
        <input type="hidden" id="selected-profile-path" name="value" value="">
        <style scoped="scoped" onload="populate_profile_option_list();">   </style>

        <div id="prerequisites-div" style="display: none;">
            <br>
            <h2>Pre-requisite Checks</h2>
            <div span style="width: 1100px; height: 100px; display: flex;">
            <span style="width: 680px; height: 100px; display: inline-block;">          
                <span style="height: 33px;"><h4>Virtualization Pre-Requisites</h4></span>
                <div><span class="checklist-span"><img src="" id="virtualization-svg" class="" style="height: 33px;" alt="virtualization-svg" /></span><span id="virtualization-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="main-version-status-svg" class="" alt="main-version-status-svg" /></span><span>KX-Main Box Version: v</span><span id="kx-main-version" class="checklist-span"></span></div>
                <div><span class="checklist-span"><img src="" id="vagrant-plugin-svg" class="" style="height: 33px;" alt="vagrant-plugin-svg" /></span><span id="vagrant-plugin-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="node-version-status-svg" class="" alt="node-version-status-svg" /></span><span>KX-Node Box Version: v</span><span id="kx-node-version" class="checklist-span"></span></div>
            </span>
            <span style="width: 400px; height: 100px; display: inline-block;">   
                <span style="height: 33px;"><h4>KX.AS.CODE Source</h4></span>
                <div><span class="checklist-span" style="width: 35px; height: 66px; display: inline-block; vertical-align: top;"><img src="" id="version-check-svg" class="" alt="version-check-svg" /></span><span class="checklist-span" style="width: 350px; height: 66px; display: inline-block; vertical-align: top;" id="version-check-message"></span></div>
            </span>
            </div>

            <style scoped="scoped" onload="getAvailableBoxes(); compareVersions(); checkVagrantPreRequisites(); updateProfileSelection(); change_panel_selection('config-panel-profile-selection');">   </style>
            <input type="hidden" id="system-prerequisites-check" name="system-prerequisites-check" value="">
        </div>

        <div id="profile-builds-div" style="display: none;">
            <br><br>
            
            <div class="div-border-text-inline">
                <h2 class="h2-header-in-line"><span class="span-h2-header-in-line">🚧 Build VM images</</span></h2>
                <div class="div-inner-h2-header-in-line-wrapper">
                <span class="description-paragraph-span"><p>Below you can see the last executed builds for each image tpe if there were any. If none, then click the play button for each type of node.</p></span>
                <div>
                    <span>
                        <span class="build-action-text-label">Last KX-Main Build Date: </span><span id="kx-main-build-timestamp" class="build-action-text-value"></span>
                        <span class="build-action-text-label">Last KX-Main Build Status: </span><span id="kx-main-build-result" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-number-span" id="kx-main-build-number-link"></span>
                    </span>
                    <span class='span-rounded-border'>
                        <img src='/userContent/icons/play.svg' class="build-action-icon" title="Start Build" alt="Start Build" onclick='triggerBuild("kx-main");' />|
                        <img src='/userContent/icons/cancel.svg' class="build-action-icon" title="Cancel Build" alt="Cancel Build" onclick='stopTriggeredBuild("KX.AS.CODE_Image_Builder", "kx-main");' />|
                        <img src='/userContent/icons/refresh.svg' class="build-action-icon" title="Refresh Data" alt="Refresh Data" onclick='getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-main");' />|
                        <div class="console-log"><span class="console-log-span"><img src="/userContent/icons/text-box-outline.svg" onMouseover='showConsoleLog("KX.AS.CODE_Image_Builder", "kx-main");' onclick='openFullConsoleLog("KX.AS.CODE_Image_Builder", "kx-main");' class="build-action-icon" alt="View Build Log" title="Click to open full log in new tab"><span class="consolelogtext" id='kxMainBuildConsoleLog'></span></span></div>
                    </span>
                </div>
                <div>
                    <span>
                        <span class="build-action-text-label">Last KX-Node Build Date: </span><span id="kx-node-build-timestamp" class="build-action-text-value"></span>
                        <span class="build-action-text-label">Last KX-Node Build Status: </span><span id="kx-node-build-result" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-number-span" id="kx-node-build-number-link"></span>
                    </span>
                    <span class='span-rounded-border'>
                        <img src='/userContent/icons/play.svg' class="build-action-icon" title="Start Build" alt="Start Build" onclick='triggerBuild("kx-node");' />|
                        <img src='/userContent/icons/cancel.svg' class="build-action-icon" title="Cancel Build" alt="Cancel Build" onclick='stopTriggeredBuild("KX.AS.CODE_Image_Builder", "kx-node");' />|
                        <img src='/userContent/icons/refresh.svg' class="build-action-icon" title="Refresh Data" alt="Refresh Data" onclick='getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-node");' />|
                        <div class="console-log"><span class="console-log-span"><img src="/userContent/icons/text-box-outline.svg" onMouseover='showConsoleLog("KX.AS.CODE_Image_Builder", "kx-node");' onclick='openFullConsoleLog("KX.AS.CODE_Image_Builder", "kx-node");' class="build-action-icon" alt="View Build Log" title="Click to open full log in new tab"><span class="consolelogtext" id='kxNodeBuildConsoleLog'></span></span></div>
                    </span>
                </div>
                <!--<style scoped="scoped" onload="getBuildJobListForProfile('kx-main'); getBuildJobListForProfile('kx-node');">   </style>-->
                <style scoped='scoped' onload='getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-main"); getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-node");'>   </style>
            </div>
        </div>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (select_profile_and_check_prereqs.groovy): ${e}"
}
