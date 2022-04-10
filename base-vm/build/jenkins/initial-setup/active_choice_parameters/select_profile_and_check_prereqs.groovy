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
def virtuallocalVagrantBoxMainVersion
def virtualboxNodeExists
def virtuallocalVagrantBoxNodeVersion
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
    println("PROFILE UPDATE CURRENT DIR: ${currentDir}")

    new File("${currentDir}/jenkins_shared_workspace/kx.as.code/profiles/").eachDirMatch(~/.*vagrant.*/) { profilePaths << it.path }

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

    Process vagrantCloudAvailableKxBoxVersions = [ "vagrant", "cloud", "search", "kxascode", "--sort-by", "updated", "--provider", "virtualbox", "--json" ].execute()
    def parsedVagrantCloudBoxesJson = new JsonSlurper().parseText(vagrantCloudAvailableKxBoxVersions.text)
    println(parsedVagrantCloudBoxesJson)

    def virtualboxKxMainVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll{it.providers == "virtualbox" && it.name == "kxascode/kx-main"}
    def virtualboxKxNodeVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll{it.providers == "virtualbox" && it.name == "kxascode/kx-node"}

    def vmwareDesktopKxMainVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll{it.providers == "vmware_desktop" && it.name == "kxascode/kx-main"}
    def vmwareDesktopKxNodeVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll{it.providers == "vmware_desktop" && it.name == "kxascode/kx-node"}

    def parallelsKxMainVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll{it.providers == "parallels" && it.name == "kxascode/kx-main"}
    def parallelsKxNodeVagrantCloudVersions = parsedVagrantCloudBoxesJson.findAll{it.providers == "parallels" && it.name == "kxascode/kx-node"}

    if (virtualboxKxMainVagrantCloudVersions) {
        println("virtualboxKxMainVagrantCloudVersion: ${virtualboxKxMainVagrantCloudVersions[0].version}")
        virtualboxKxMainVagrantCloudVersion = virtualboxKxMainVagrantCloudVersions[0].version
    } else {
        virtualboxKxMainVagrantCloudVersion = "-"
    }

    if (virtualboxKxNodeVagrantCloudVersions) {
        println("virtualboxKxNodeVagrantCloudVersion: ${virtualboxKxNodeVagrantCloudVersions[0].version}")
        virtualboxKxNodeVagrantCloudVersion = virtualboxKxNodeVagrantCloudVersions[0].version
    } else {
        virtualboxKxNodeVagrantCloudVersion = "-"
    }

    if (vmwareDesktopKxMainVagrantCloudVersions) {
        println("vmwareDesktopKxMainVagrantCloudVersion: ${vmwareDesktopKxMainVagrantCloudVersions[0].version}")
        vmwareDesktopKxMainVagrantCloudVersion = vmwareDesktopKxMainVagrantCloudVersions[0].version
    } else {
        vmwareDesktopKxMainVagrantCloudVersion = "-"
    }

    if (vmwareDesktopKxNodeVagrantCloudVersions) {
        println("vmwareDesktopKxNodeVagrantCloudVersion: ${vmwareDesktopKxNodeVagrantCloudVersions[0].version}")
        vmwareDesktopKxNodeVagrantCloudVersion = vmwareDesktopKxNodeVagrantCloudVersions[0].version
    } else {
        vmwareDesktopKxNodeVagrantCloudVersion = "-"
    }

    if (parallelsKxMainVagrantCloudVersions) {
        println("parallelsKxMainVagrantCloudVersion: ${parallelsKxMainVagrantCloudVersions[0].version}")
        parallelsKxMainVagrantCloudVersion = parallelsKxMainVagrantCloudVersions[0].version
    } else {
        parallelsKxMainVagrantCloudVersion = "-"
    }

    if (parallelsKxNodeVagrantCloudVersions) {
        println("parallelsKxNodeVagrantCloudVersion: ${parallelsKxNodeVagrantCloudVersions[0].version}")
        parallelsKxNodeVagrantCloudVersion = parallelsKxNodeVagrantCloudVersions[0].version
    } else {
        parallelsKxNodeVagrantCloudVersion = "-"
    }

} catch(e) {
    println("Something went wrong in the GROOVY block -> getting vagrant cloud boxes (select_profile_and_check_prereqs.groovy): ${e}")
}

try {
    println("Entered check prerequisites - BEGINNING")

    //TODO - change this away from hardcoded user URL - current entry for debugging only
    def githubVersionJson = new JsonSlurper().parse('https://raw.githubusercontent.com/patdel76/kx/main/versions.json'.toURL())
    githubKxVersion = githubVersionJson.kxascode
    githubKubeVersion = githubVersionJson.kubernetes
    println("githubKxVersion: ${githubKxVersion}, githubKubeVersion: ${githubKubeVersion}")

    def localVersionFile = "${currentDir}/jenkins_shared_workspace/kx.as.code/versions.json"
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
    println("vboxExecutableExists: ${vboxExecutableExists}")
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

    new File("${currentDir}/jenkins_shared_workspace/kx.as.code/base-vm/boxes/").eachDir {boxDirectories << it.name }
    println(boxDirectories)

    def boxDirectoryList = []
    def provider
    def version
    boxDirectories.eachWithIndex { boxDirectory, i ->
        println boxDirectory
        println i
        boxProvider = boxDirectories[i].substring(0,boxDirectories[i].lastIndexOf("-"))
        boxVersion = boxDirectories[i].substring(boxDirectories[i].substring(0,boxDirectories[i].lastIndexOf("-")).length()+1,boxDirectories[i].length())
        println("provider: ${boxProvider}, version: ${boxVersion}")

        new File("${currentDir}/jenkins_shared_workspace/kx.as.code/base-vm/boxes/${boxDirectory}/").eachFile {boxDirectoryList << it.name }
        boxDirectoryList.eachWithIndex { box, j ->
            if (box.endsWith('.box')) {
                boxName = box.substring(0,box.lastIndexOf("-"))
                println("provider: ${boxProvider}, box: ${boxName}, version: ${boxVersion}")
                if(boxName == "kx-main" || boxName == "kx-node") {
                    boxesList.add('"' + boxName + " " + boxProvider + " " + boxVersion + '"')
                    if (boxName == "kx-main" && boxProvider == "virtualbox") {
                        virtualboxMainExists = "true"
                        virtuallocalVagrantBoxMainVersion = boxVersion
                    }
                    if (boxName == "kx-node" && boxProvider == "virtualbox") {
                        virtualboxNodeExists = "true"
                        virtuallocalVagrantBoxNodeVersion = boxVersion
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

    def boxesJson = jsonSlurper.parseText('{ "boxes": { "virtualboxMainExists": "' + virtualboxMainExists + '", "virtuallocalVagrantBoxMainVersion": "' + virtuallocalVagrantBoxMainVersion + '", "virtualboxNodeExists": "' + virtualboxNodeExists + '", "virtuallocalVagrantBoxNodeVersion": "' + virtuallocalVagrantBoxNodeVersion + '", "vmwareMainExists": "' + vmwareMainExists + '", "vmwareMainVersion": "' + vmwareMainVersion + '", "vmwareNodeExists": "' + vmwareNodeExists + '", "vmwareNodeVersion": "' + vmwareNodeVersion + '", "parallelsMainExists": "' + parallelsMainExists + '", "parallelsMainVersion": "' + parallelsMainVersion + '", "parallelsNodeExists": "' + parallelsNodeExists + '", "parallelsNodeVersion": "' + parallelsNodeVersion + '"}}')

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

    //println("existingBoxes" + existingBoxes)
    println("Check prerequisites - END")

} catch(e) {
    println "Something went wrong in the GROOVY block (select_profile_and_check_prereqs.groovy): ${e}"
}


try {
    // language=HTML
    def HTML = """
      <script>
            function getLocalKxVersion() {
                let localKxVersion = "${localKxVersion}";
                return localKxVersion;
            }

            function getGithubKxVersion() {
                let githubKxVersion = "${githubKxVersion}";
                return githubKxVersion;
            }

            function getLocalKubeVersion() {
                let localKubeVersion = "${localKubeVersion}";
                return localKubeVersion;
            }

            function getGithubKubeVersion() {
                 let githubKubeVersion = "${githubKubeVersion}";
                 return githubKubeVersion;
            }

            function getProfilePaths() {
                let profilePaths = "${profilePaths}";
                return profilePaths;
            }

          function getAvailableLocalBoxes() {
              console.log("DEBUG: getAvailableLocalBoxes()");
              let localVagrantBoxMainVersion;
              let localVagrantBoxNodeVersion;
              let selectedProfile = document.getElementById("profiles").value;
              try {
                  console.log("Selected profile: " + selectedProfile);
                  switch (selectedProfile) {
                      case "virtualbox":
                          localVagrantBoxMainVersion = "${virtuallocalVagrantBoxMainVersion}";
                          localVagrantBoxNodeVersion = "${virtuallocalVagrantBoxNodeVersion}";
                          break;
                      case "vmware-desktop":
                          localVagrantBoxMainVersion = "${vmwareMainVersion}";
                          localVagrantBoxNodeVersion = "${vmwareNodeVersion}";
                          break;
                      case "parallels":
                          localVagrantBoxMainVersion = "${parallelsMainVersion}";
                          localVagrantBoxNodeVersion = "${parallelsNodeVersion}";
                          break;
                      default:
                          console.log("Weird, box type not known. Normally the box type is either VirtualBox, VMWare or Parallels");
                  }
                  console.log('localVagrantBoxMainVersion: ' + localVagrantBoxMainVersion);
                  console.log('localVagrantBoxNodeVersion: ' + localVagrantBoxNodeVersion);
                  if ( localVagrantBoxMainVersion !== "null" ) {
                    document.getElementById("kx-main-local-box-version").innerHTML = localVagrantBoxMainVersion;
                    document.getElementById("local-main-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                    document.getElementById("local-main-version-status-svg").className = "checklist-status-icon svg-bright-green";
                  } else {
                    document.getElementById("kx-main-local-box-version").innerHTML = "<i>Not found</i>";
                    document.getElementById("local-main-version-status-svg").src = "/userContent/icons/alert-outline.svg";
                    document.getElementById("local-main-version-status-svg").className = "checklist-status-icon svg-orange-red";
                  }

                  if ( localVagrantBoxNodeVersion !== "null" ) {
                      document.getElementById("kx-node-local-box-version").innerHTML = localVagrantBoxNodeVersion;
                      document.getElementById("local-node-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                      document.getElementById("local-node-version-status-svg").className = "checklist-status-icon svg-bright-green";
                  } else {
                      document.getElementById("kx-node-local-box-version").innerHTML = "<i>Not found</i>";
                      document.getElementById("local-node-version-status-svg").src = "/userContent/icons/alert-outline.svg";
                      document.getElementById("local-node-version-status-svg").className = "checklist-status-icon svg-orange-red";
                      document.getElementById('standalone-mode-toggle').value = "true";
                      document.getElementById('workloads_on_master_checkbox').value = "true";
                  }

              } catch(e) {
                    console.log("Error getting box versions: " + e);
              }
          }

          function getAvailableCloudBoxes() {
              console.log("DEBUG: getAvailableCloudBoxes()");
              let cloudVagrantBoxMainVersion;
              let cloudVagrantBoxNodeVersion;
              let selectedProfile = document.getElementById("profiles").value;
              try {
                  console.log("getAvailableCloudBoxes() -> Selected profile: " + selectedProfile);
                  switch (selectedProfile) {
                      case "virtualbox":
                          cloudVagrantBoxMainVersion = "${virtualboxKxMainVagrantCloudVersion}";
                          cloudVagrantBoxNodeVersion = "${virtualboxKxNodeVagrantCloudVersion}";
                          break;
                      case "vmware-desktop":
                          cloudVagrantBoxMainVersion = "${vmwareDesktopKxMainVagrantCloudVersion}";
                          cloudVagrantBoxNodeVersion = "${vmwareDesktopKxNodeVagrantCloudVersion}";
                          break;
                      case "parallels":
                          cloudVagrantBoxMainVersion = "${parallelsKxMainVagrantCloudVersion}";
                          cloudVagrantBoxNodeVersion = "${parallelsKxNodeVagrantCloudVersion}";
                          break;
                      default:
                          console.log("Weird, box type not known. Normally the box type is either VirtualBox, VMWare or Parallels");
                  }
                  console.log('cloudVagrantBoxMainVersion: ' + cloudVagrantBoxMainVersion);
                  console.log('cloudVagrantBoxNodeVersion: ' + cloudVagrantBoxNodeVersion);
                  if ( cloudVagrantBoxMainVersion !== "null" ) {
                    document.getElementById("kx-main-vagrant-cloud-box-version").innerHTML = cloudVagrantBoxMainVersion;
                    document.getElementById("cloud-main-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                    document.getElementById("cloud-main-version-status-svg").className = "checklist-status-icon svg-bright-green";
                  } else {
                    document.getElementById("kx-main-vagrant-cloud-box-version").innerHTML = "<i>Not found</i>";
                    document.getElementById("cloud-main-version-status-svg").src = "/userContent/icons/alert-outline.svg";
                    document.getElementById("cloud-main-version-status-svg").className = "checklist-status-icon svg-orange-red";
                  }

                  if ( cloudVagrantBoxNodeVersion !== "null" ) {
                      document.getElementById("kx-node-vagrant-cloud-box-version").innerHTML = cloudVagrantBoxNodeVersion;
                      document.getElementById("cloud-node-version-status-svg").src = "/userContent/icons/checkbox-marked-circle-outline.svg";
                      document.getElementById("cloud-node-version-status-svg").className = "checklist-status-icon svg-bright-green";
                  } else {
                      document.getElementById("kx-node-vagrant-cloud-box-version").innerHTML = "<i>Not found</i>";
                      document.getElementById("cloud-node-version-status-svg").src = "/userContent/icons/alert-outline.svg";
                      document.getElementById("cloud-node-version-status-svg").className = "checklist-status-icon svg-orange-red";
                      document.getElementById('standalone-mode-toggle').value = "true";
                      document.getElementById('workloads_on_master_checkbox').value = "true";
                  }

              } catch(e) {
                    console.log("Error getting box versions: " + e);
              }
          }
          
          function checkVagrantPreRequisites() {
              console.log("DEBUG: Inside checkVagrantPreRequisites");
              let selectedProfile = document.getElementById("profiles").value;
              let virtualizationExecutableExists = "";
              let vagrantPluginInstalled = "";
              console.log("VirtualBox exists: ${vboxExecutableExists}");
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
    <body>
        <div id="headline-select-profile-div" style="display: none;">
        <h1>Select Profile &amp; Check Pre-Requisites</h1>
        <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
        </div>
        <div id="select-profile-div" style="display: none;">
            <br>
            <label for="profiles" class="input-box-label" style="margin: 0px;">Profiles</label>
            <select id="profiles" class="profiles-select capitalize" value="Virtualbox" onchange="updateProfileAndPrereqsCheckTab();">
            </select>
            </label>
        </div>
        <input type="hidden" id="selected-profile-path" name="value" value="">
        <style scoped="scoped" onload="populate_profile_option_list();">   </style>

        <div id="prerequisites-div" style="display: none;">
            <br>
            <h2>Pre-requisite Checks</h2>
            <div span style="width: 1100px; height: 100px; display: flex;">
            <span style="width: 100%; height: 100px; display: inline-block;">
                <span style="height: 33px;"><h4>Virtualization Pre-Requisites</h4></span>
                <div><span class="checklist-span"><img src="" id="virtualization-svg" class="" style="height: 33px;" alt="virtualization-svg" /></span><span id="virtualization-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="local-main-version-status-svg" class="" alt="local-main-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Local KX-Main Box Version: </span><span id="kx-main-local-box-version" class="checklist-span" style="width: 100px;display:inline-block;"></span><span class="checklist-span"><img src="" id="cloud-main-version-status-svg" class="" alt="cloud-main-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Cloud KX-Main Box Version: </span><span id="kx-main-vagrant-cloud-box-version" class="checklist-span" style="width: 100px;display:inline-block;"></span></div>
                <div><span class="checklist-span"><img src="" id="vagrant-plugin-svg" class="" style="height: 33px;" alt="vagrant-plugin-svg" /></span><span id="vagrant-plugin-text" class="checklist-span" style="width: 300px;display:inline-block;"></span><span class="checklist-span"><img src="" id="local-node-version-status-svg" class="" alt="local-node-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Local KX-Node Box Version: </span><span id="kx-node-local-box-version" class="checklist-span" style="width: 100px;display:inline-block;"></span><span class="checklist-span"><img src="" id="cloud-node-version-status-svg" class="" alt="cloud-node-version-status-svg" /></span><span style="width: 200px;display:inline-block;">Cloud Kx-Node Box Version: </span><span id="kx-node-vagrant-cloud-box-version" class="checklist-span" style="width: 100px;display:inline-block;"></span></div>
            </span>
            </div>
            <br>
            <div style="width: 400px; height: 100px; display: inline-block;">
                <span style="height: 33px;"><h4>KX.AS.CODE Source</h4></span>
                <div><span class="checklist-span" style="width: 35px; height: 66px; display: inline-block; vertical-align: top;"><img src="" id="version-check-svg" class="" alt="version-check-svg" /></span><span class="checklist-span" style="width: 350px; height: 66px; display: inline-block; vertical-align: top;" id="version-check-message"></span></div>
            </div>
            <style scoped="scoped" onload="getAvailableLocalBoxes(); getAvailableCloudBoxes(); compareVersions(); checkVagrantPreRequisites(); updateProfileSelection(); change_panel_selection('config-panel-profile-selection');">   </style>
            <input type="hidden" id="system-prerequisites-check" name="system-prerequisites-check" value="">
        </div>

        <div id="profile-builds-div" style="display: none;">
            <br>

            <div class="div-border-text-inline">
                <h2 class="h2-header-in-line"><span class="span-h2-header-in-line">🚧 Build VM images</span></h2>
                <div class="div-inner-h2-header-in-line-wrapper">
                    <span class="description-paragraph-span"><p>Below you can see the last executed builds for each image tpe if there were any. If none, then click the play button for each type of node.</p></span>
                </div>
                <div style="width: 100%;">
                    <span style="width: 940px;">
                        <span class="build-action-text-label" style="width: 150px">KX-Main Build Date: </span><span id="kx-main-build-timestamp" class="build-action-text-value"></span>
                        <span class="build-action-text-label" style="width: 100px;">Build Status: </span><span id="kx-main-build-result" class="build-action-text-value build-action-text-value-result" style="width: 100px; margin-right: 5px; display: inline-flex;"></span>
                        <span class="build-action-text-label" style="width: 110px;">Build Version: </span><span id="kx-main-build-kx-version" style="width: 50px;" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-action-text-label" style="width: 110px;">Kube Version: </span><span id="kx-main-build-kube-version" style="width: 80px;" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-number-span" id="kx-main-build-number-link"></span>
                    </span>
                    <span class='span-rounded-border'>
                        <img src='/userContent/icons/play.svg' class="build-action-icon" title="Start Build" alt="Start Build" onclick='triggerBuild("kx-main");' />|
                        <img src='/userContent/icons/cancel.svg' class="build-action-icon" title="Cancel Build" alt="Cancel Build" onclick='stopTriggeredBuild("KX.AS.CODE_Image_Builder", "kx-main");' />|
                        <img src='/userContent/icons/refresh.svg' class="build-action-icon" title="Refresh Data" alt="Refresh Data" onclick='getBuildJobListForProfile("KX.AS.CODE_Image_Builder", "kx-main");' />|
                        <div class="console-log"><span class="console-log-span"><img src="/userContent/icons/text-box-outline.svg" onMouseover='showConsoleLog("KX.AS.CODE_Image_Builder", "kx-main");' onclick='openFullConsoleLog("KX.AS.CODE_Image_Builder", "kx-main");' class="build-action-icon" alt="View Build Log" title="Click to open full log in new tab"><span class="consolelogtext" id='kxMainBuildConsoleLog'></span></span></div>
                    </span>
                </div>
                    <div style="width: 100%;">
                        <span style="width: 940px;">
                        <span class="build-action-text-label" style="width: 150px">KX-Node Build Date: </span><span id="kx-node-build-timestamp" class="build-action-text-value"></span>
                        <span class="build-action-text-label" style="width: 100px;">Build Status: </span><span id="kx-node-build-result" class="build-action-text-value build-action-text-value-result" style="width: 100px; margin-right: 5px; display: inline-flex;"></span>
                        <span class="build-action-text-label" style="width: 110px;">Build Version: </span><span id="kx-node-build-kx-version" style="width: 50px;" class="build-action-text-value build-action-text-value-result"></span>
                        <span class="build-action-text-label" style="width: 110px;">Kube Version: </span><span id="kx-node-build-kube-version" style="width: 80px;" class="build-action-text-value build-action-text-value-result"></span>                        <span class="build-number-span" id="kx-node-build-number-link"></span>
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
