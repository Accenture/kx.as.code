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

try {
    println("Entered check prerequisites - BEGINNING")

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

    if (systemCheckJsonFile.exists()) {

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
            } else if (vagrantPluginName == "parallels") {
                vagrantParallelsPluginInstalled = true
            }
        }

        def builder = new JsonBuilder()
        def jsonSlurper = new JsonSlurper()

        def vagrantJson = jsonSlurper.parseText('{ "system": { "vagrantVmwarePluginInstalled": "' + vagrantVmwarePluginInstalled + '", "vagrantParallelsPluginInstalled": "' + vagrantParallelsPluginInstalled + '", "parallelsExecutable": "' + parallelsExecutableExists + '", "vboxExecutable": "' + vboxExecutableExists + '", "vmwareExecutable": "' + vmwareExecutableExists + '"}}')

        println("vagrant: ${vagrantJson}")

        def existingBoxes = 'vagrant box list'.execute().text
        def boxes = new String(existingBoxes).split('\n')
        println("existingBoxes" + existingBoxes)

        println("[0]: " + boxes[0])
        println("[1]: " + boxes[1])

        for (box in boxes) {
            boxItem = box.split(" ")
            boxName = boxItem[0].trim()
            boxProvider = boxItem[1].trim().replaceAll("[(),]", "").replaceAll("_", "-")
            boxVersion = boxItem[2].trim().replaceAll("[()]", "")
            println(boxName + " " + boxProvider + " " + boxVersion)
            boxesList.add('"' + boxName + " " + boxProvider + " " + boxVersion + '"')
            if (boxName == "kx.as.code-main" && boxProvider == "virtualbox") {
                virtualboxMainExists = "true"
                virtualboxMainVersion = boxVersion
            }
            if (boxName == "kx.as.code-node" && boxProvider == "virtualbox") {
                virtualboxNodeExists = "true"
                virtualboxNodeVersion = boxVersion
            }
            if (boxName == "kx.as.code-main" && boxProvider == "vmware-desktop") {
                vmwareMainExists = "true"
                vmwareMainVersion = boxVersion

            }
            if (boxName == "kx.as.code-node" && boxProvider == "vmware-desktop") {
                vmwareNodeExists = "true"
                vmwareNodeVersion = boxVersion

            }
            if (boxName == "kx.as.code-main" && boxProvider == "parallels") {
                parallelsMainExists = "true"
                parallelsMainVersion = boxVersion

            }
            if (boxName == "kx.as.code-node" && boxProvider == "parallels") {
                parallelsNodeExists = "true"
                parallelsNodeVersion = boxVersion
            }
        }
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
    println "Something went wrong in the GROOVY block (check_prerequisites): ${e}"
}

try {
    // language=HTML
    def HTML = """
      <script>

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
                    document.getElementById("kx-main-version").innerHTML = "v" + boxMainVersion;
                    document.getElementById("main-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                    document.getElementById("main-version-status-svg").className = "checklist-status-icon svg-bright-green";
                  } else {
                    document.getElementById("kx-main-version").innerHTML = "<i>Not found</i>";
                    document.getElementById("main-version-status-svg").src = "/userContent/icons/alert-outline.svg";
                    document.getElementById("main-version-status-svg").className = "checklist-status-icon svg-orange-red";
                  }

                  if ( boxNodeVersion !== "null" ) {
                      document.getElementById("kx-node-version").innerHTML = "v" + boxNodeVersion;
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

          }

      </script>

      <style>

          .checklist-status-icon {
              width: 25px;
              height: 25px;
          }

      </style>
    <body>
        <div id="prerequisites-div" style="display: none;">
            <h2>Pre-requisite Checks</h2>
            <h4>Virtualization Pre-Requisites</h4>
            <div><span class="checklist-span"><img src="" id="virtualization-svg" class="" alt="virtualization-svg" /></span><span id="virtualization-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="main-version-status-svg" class="" alt="main-version-status-svg" /></span><span class="checklist-span">KX-Main Box Version: </span><span id="kx-main-version" class="checklist-span"></span></div>
            <div><span class="checklist-span"><img src="" id="vagrant-plugin-svg" class="" alt="vagrant-plugin-svg" /></span><span id="vagrant-plugin-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="node-version-status-svg" class="" alt="node-version-status-svg" /></span><span class="checklist-span">KX-Node Box Version: </span><span id="kx-node-version" class="checklist-span"></span></div>
            <br>
            <h4>KX.AS.CODE Source</h4>
            <div><span class="checklist-span"><img src="" id="version-check-svg" class="" alt="version-check-svg" /></span><span class="checklist-span" id="version-check-message"></span></div>
            <br>
            <style scoped="scoped" onload="getAvailableBoxes(); compareVersions(); checkVagrantPreRequisites(); updateProfileSelection(); change_panel_selection('config-panel-profile-selection');">   </style>
        </div>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (check_prerequisites): ${e}"
}
