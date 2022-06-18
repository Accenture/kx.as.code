import java.lang.management.*
import groovy.json.JsonSlurper

def extendedDescription

try {
    extendedDescription = "The charts below show how the selections you made fit with the physical resources available. If any of the charts are red, you should look to make corrections. For the storage parameters, as the volumes are thinly provisioned, an overallocation is not a problem, as long as you don't intend to use the full space."
} catch(e) {
    println("Something went wrong in the GROOVY block (config_review_and_launch.groovy): ${e}")
}

long freePhysicalMemorySize
long totalPhysicalMemorySize
int totalSystemCores
def currentSystemDisk
long totalSystemDisk
long freeSystemDisk
long usableSystemDisk
int remainingDiskSpace

int kxMainMemory
int kxMainNumber
int kxMainCpuCores
int kxWorkerMemory
int kxWorkerNumber
int kxWorkerCpuCores

def normalPieColour = "var(--kx-success-green-70)"
def warningPieColour = "var(--kx-warning-orange-70)"
def alertPieColour = "var(--kx-error-red-70)"

def normalPieTextColour = "var(--kx-success-green-100)"
def warningPieTextColour = "var(--kx-warning-orange-100)"
def alertPieTextColour = "var(--kx-error-red-100)"

def cpuPieColour
def memoryPieColour
def diskPieColour

int overallStorageRequired
int overallStorageNeededPercentage
int overallRemainingPercentage
int overallTotalNeededMemory
int overallTotalNeededCpuCores
int overallUsedCpuCoresPercentage
int overallUsedMemoryPercentage
int overallRemainingCpuCoresPercentage
int overallRemainingMemoryPercentage

def parsedJson
def jsonFilePath = PROFILE.split(";")[0]
def inputFile = new File(jsonFilePath)

def ALLOW_WORKLOADS_ON_KUBERNETES_MASTER

def kxMainRunningVms = []
def kxWorkerRunningVms = []
def numKxMainRunningVms = []
def numKxWorkerRunningVms = []

def virtualboxCliPath
def vmwareCliPath
def parallelsCliPath

try {

    def OS = System.getProperty("os.name", "generic").toLowerCase(Locale.ENGLISH);

    if ((OS.indexOf("mac") >= 0) || (OS.indexOf("darwin") >= 0)) {
        underlyingOS = "darwin"
        virtualboxCliPath = "/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
        vmwareCliPath = "/Applications/VMware\\ Fusion.app/Contents/Public/vmrun"
        parallelsCliPath = "/Applications/Parallels Desktop.app/Contents/MacOS/prlctl"
    } else if (OS.indexOf("win") >= 0) {
        underlyingOS = "windows"
        virtualboxCliPath = "C:/Program Files/Oracle/VirtualBox/VBoxManage.exe"
        vmwareCliPath = "C:/Program Files (x86)/VMware/VMware Workstation/vmrun.exe"
    } else if (OS.indexOf("nux") >= 0) {
        underlyingOS = "linux"
        virtualboxCliPath = "/usr/bin/vboxmanage"
        vmwareCliPath = "/usr/bin/vmrun"
    } else {
        underlyingOS = "other"
    }

    parsedJson = new JsonSlurper().parse(inputFile)

    mb = 1024 * 1024;
    gb = mb * 1024;

    def os = ManagementFactory.operatingSystemMXBean;
    freePhysicalMemorySize = os.getFreePhysicalMemorySize() / mb;
    totalPhysicalMemorySize = os.getTotalPhysicalMemorySize() / mb;

    totalSystemCores = Runtime.getRuntime().availableProcessors();

    File f = new File("/");
    currentSystemDisk = f.getAbsolutePath();
    totalSystemDisk = f.getTotalSpace() / gb;
    freeSystemDisk = f.getFreeSpace() / gb;
    usableSystemDisk = f.getUsableSpace() / gb;

    int number1GbVolumes
    int number5GbVolumes
    int number10GbVolumes
    int number30GbVolumes
    int number50GbVolumes
    int networkStorageVolume

    if ( STORAGE_PARAMETERS ) {
        def storageParameterElements = STORAGE_PARAMETERS.split(';')
        number1GbVolumes = storageParameterElements[0].toInteger()
        number5GbVolumes = storageParameterElements[1].toInteger()
        number10GbVolumes = storageParameterElements[2].toInteger()
        number30GbVolumes = storageParameterElements[3].toInteger()
        number50GbVolumes = storageParameterElements[4].toInteger()
        networkStorageVolume = storageParameterElements[5].toInteger()
    } else {
        number1GbVolumes = parsedJson.config.local_volumes.one_gb.toInteger()
        number5GbVolumes = parsedJson.config.local_volumes.five_gb.toInteger()
        number10GbVolumes = parsedJson.config.local_volumes.ten_gb.toInteger()
        number30GbVolumes = parsedJson.config.local_volumes.thirty_gb.toInteger()
        number50GbVolumes = parsedJson.config.local_volumes.fifty_gb.toInteger()
        networkStorageVolume = parsedJson.config.glusterFsDiskSize.toInteger()
    }

    int totalLocalDiskSpace = totalSystemDisk.toInteger()
    remainingDiskSpace = freeSystemDisk.toInteger()
    int totalLocalVolumesStorageRequired

    if ( GENERAL_PARAMETERS ) {
        generalParameterElements = GENERAL_PARAMETERS.split(';')
        BASE_DOMAIN = generalParameterElements[0]
        ENVIRONMENT_PREFIX = generalParameterElements[1]
        BASE_USER = generalParameterElements[2]
        BASE_PASSWORD = generalParameterElements[3]
        STANDALONE_MODE = generalParameterElements[4]
        ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = generalParameterElements[5]
        DISABLE_LINUX_DESKTOP = generalParameterElements[6]
    } else {
        BASE_DOMAIN = parsedJson.config.baseDomain
        ENVIRONMENT_PREFIX = parsedJson.config.environmentPrefix
        BASE_USER = parsedJson.config.baseUser
        BASE_PASSWORD = parsedJson.config.basePassword
        STANDALONE_MODE = parsedJson.config.standaloneMode
        ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = parsedJson.config.allowWorkloadsOnMaster
        DISABLE_LINUX_DESKTOP = parsedJson.config.disableLinuxDesktop
    }

    if ( KX_MAIN_NODES_CONFIG ) {
        kxMainNodesConfigArray = KX_MAIN_NODES_CONFIG.split(';')
        NUMBER_OF_KX_MAIN_NODES = kxMainNodesConfigArray[0]
        KX_MAIN_ADMIN_CPU_CORES = kxMainNodesConfigArray[1]
        KX_MAIN_ADMIN_MEMORY = kxMainNodesConfigArray[2]
    } else {
        NUMBER_OF_KX_MAIN_NODES = parsedJson.config.main_node_count
        KX_MAIN_ADMIN_CPU_CORES = parsedJson.config.main_admin_node_cpu_cores
        KX_MAIN_ADMIN_MEMORY = parsedJson.config.main_admin_node_memory
    }

    if ( KX_WORKER_NODES_CONFIG ) {
        kxWorkerNodesConfigArray = KX_WORKER_NODES_CONFIG.split(';')
        NUMBER_OF_KX_WORKER_NODES = kxWorkerNodesConfigArray[0]
        KX_WORKER_NODES_CPU_CORES = kxWorkerNodesConfigArray[1]
        KX_WORKER_NODES_MEMORY = kxWorkerNodesConfigArray[2]
    } else {
        NUMBER_OF_KX_WORKER_NODES = parsedJson.config.worker_node_count
        KX_WORKER_NODES_CPU_CORES = parsedJson.config.worker_node_cpu_cores
        KX_WORKER_NODES_MEMORY = parsedJson.config.worker_node_memory
    }

    if ( NUMBER_OF_KX_MAIN_NODES ) {
        kxMainNumber = NUMBER_OF_KX_MAIN_NODES.toInteger()
    } else {
        kxMainNumber = parsedJson.config.vm_properties.main_node_count
    }

    if ( NUMBER_OF_KX_WORKER_NODES ) {
        kxWorkerNumber = NUMBER_OF_KX_WORKER_NODES.toInteger()
    } else {
        kxWorkerNumber = parsedJson.config.vm_properties.worker_node_count
    }

    if (ALLOW_WORKLOADS_ON_KUBERNETES_MASTER == "true") {
        totalLocalVolumesStorageRequired = (number1GbVolumes + (number5GbVolumes * 5) + (number10GbVolumes * 10) + (number30GbVolumes * 30) + (number50GbVolumes * 50)) * (kxMainNumber + kxWorkerNumber)
    } else {
        totalLocalVolumesStorageRequired = (number1GbVolumes + (number5GbVolumes * 5) + (number10GbVolumes * 10) + (number30GbVolumes * 30) + (number50GbVolumes * 50)) * kxWorkerNumber
    }

    def baseSystemHddSize = 40
    def totalBaseSystemHddSize = baseSystemHddSize * (kxMainNumber + kxWorkerNumber)
    overallStorageRequired = totalBaseSystemHddSize + totalLocalVolumesStorageRequired + networkStorageVolume

    overallStorageNeededPercentage = (overallStorageRequired / remainingDiskSpace) * 100
    overallRemainingPercentage = 100 - overallStorageNeededPercentage

    int slaveTotalMemory = totalPhysicalMemorySize.toInteger()
    int slaveFreeMemory = freePhysicalMemorySize.toInteger()
    int usedMemory = slaveTotalMemory - slaveFreeMemory

    if ( KX_MAIN_ADMIN_MEMORY ) {
        kxMainMemory = KX_MAIN_ADMIN_MEMORY.toInteger()
    } else {
        kxMainMemory = parsedJson.config.vm_properties.main_admin_node_memory
    }

    if ( KX_MAIN_ADMIN_CPU_CORES ) {
        kxMainCpuCores = KX_MAIN_ADMIN_CPU_CORES.toInteger()
    } else {
        kxMainCpuCores = parsedJson.config.vm_properties.main_admin_node_cpu_cores
    }

    int totalNeededMainNodeMemory = kxMainMemory * kxMainNumber
    int totalNeededMainNodeCpuCores = kxMainCpuCores * kxMainNumber

    if ( KX_WORKER_NODES_MEMORY ) {
        kxWorkerMemory = KX_WORKER_NODES_MEMORY.toInteger()
    } else {
        kxWorkerMemory = parsedJson.config.vm_properties.worker_node_memory
    }

    if ( KX_WORKER_NODES_CPU_CORES ) {
        kxWorkerCpuCores = KX_WORKER_NODES_CPU_CORES.toInteger()
    } else {
        kxWorkerCpuCores = parsedJson.config.vm_properties.worker_node_cpu_cores
    }

    NUMBER_OF_KX_WORKER_NODES = NUMBER_OF_KX_WORKER_NODES ?: "0"
    KX_WORKER_NODES_MEMORY = KX_WORKER_NODES_MEMORY ?: "0"
    KX_WORKER_NODES_CPU_CORES = KX_WORKER_NODES_CPU_CORES ?: "0"

    int totalNeededWorkerNodeMemory = kxWorkerMemory * kxWorkerNumber
    int totalNeededWorkerNodeCpuCores = kxWorkerCpuCores * kxWorkerNumber

    overallTotalNeededMemory = totalNeededMainNodeMemory + totalNeededWorkerNodeMemory
    overallTotalNeededCpuCores = totalNeededMainNodeCpuCores + totalNeededWorkerNodeCpuCores

    overallUsedCpuCoresPercentage = (overallTotalNeededCpuCores / totalSystemCores.toInteger()) * 100
    overallUsedMemoryPercentage = (overallTotalNeededMemory / slaveTotalMemory) * 100

    overallRemainingCpuCoresPercentage = 100 - overallUsedCpuCoresPercentage
    overallRemainingMemoryPercentage = 100 - overallUsedMemoryPercentage

    if (overallUsedCpuCoresPercentage >= 90 && overallUsedCpuCoresPercentage < 100) {
        cpuPieColour = warningPieColour
        cpuPieTextColour = warningPieTextColour
    } else if (overallUsedCpuCoresPercentage >= 100) {
        cpuPieColour = alertPieColour
        cpuPieTextColour = alertPieTextColour
    } else {
        cpuPieColour = normalPieColour
        cpuPieTextColour = normalPieTextColour
    }

    if (overallUsedMemoryPercentage >= 90 && overallUsedMemoryPercentage < 100) {
        memoryPieColour = warningPieColour
        memoryPieTextColour = warningPieTextColour
    } else if (overallUsedMemoryPercentage >= 100) {
        memoryPieColour = alertPieColour
        memoryPieTextColour = alertPieTextColour
    } else {
        memoryPieColour = normalPieColour
        memoryPieTextColour = normalPieTextColour
    }

    if (overallStorageNeededPercentage >= 90 && overallStorageNeededPercentage < 100) {
        diskPieColour = warningPieColour
        diskPieTextColour = warningPieTextColour
    } else if (overallStorageNeededPercentage >= 100) {
        diskPieColour = alertPieColour
        diskPieTextColour = alertPieTextColour
    } else {
        diskPieColour = normalPieColour
        diskPieTextColour = normalPieTextColour
    }

    // Check running VMs
    def runningVirtualMachines
    def runningVirtualMachinesList = []

    if ( PROFILE.contains("vmware-desktop")) {
        File vmwareCliPathExists = new File(vmwareCliPath)
        if ( vmwareCliPathExists.exists() ) {
            runningVirtualMachines = "${vmwareCliPath} list".execute().text
            runningVirtualMachinesList = new String(runningVirtualMachines).split('\n')
            kxMainRunningVms = runningVirtualMachinesList.findAll { it =~ /kx.as.code-(.*)-main(.*)/ }
            kxWorkerRunningVms = runningVirtualMachinesList.findAll { it =~ /kx.as.code-(.*)-worker(.*)/ }
        }
    } else if ( PROFILE.contains("parallels") ) {
        File parallelsCliPathExists = new File(parallelsCliPath)
        if ( parallelsCliPathExists.exists() ) {
            Process runningVirtualMachinesProcess = ["${parallelsCliPath}", "list"].execute()
            virtualMachinesList = new String(runningVirtualMachinesProcess.text).split('\n')
            runningVirtualMachinesList = virtualMachinesList.findAll { it.contains('running') }
            kxMainRunningVms = runningVirtualMachinesList.findAll { it =~ /kx.as.code-(.*)-main(.*)/ }
            kxWorkerRunningVms = runningVirtualMachinesList.findAll { it =~ /kx.as.code-(.*)-worker(.*)/ }
        }
    } else if ( PROFILE.contains("virtualbox")) {
        File virtualboxCliPathExists = new File(virtualboxCliPath)
        if ( virtualboxCliPathExists.exists() ) {
            runningVirtualMachines = "${virtualboxCliPath} list runningvms".execute().text
            runningVirtualMachinesList = new String(runningVirtualMachines).split('\n')
            kxMainRunningVms = runningVirtualMachinesList.findAll { it =~ /kx.as.code-(.*)-main(.*)/ }
            kxWorkerRunningVms = runningVirtualMachinesList.findAll { it =~ /kx.as.code-(.*)-worker(.*)/ }
        }
    }

} catch(e) {
    println "Something went wrong in the GROOVY block (config_review_and_launch.groovy): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <body>
      <div id="review-and-launch-div" style="display: none;">
        <div style="display: inline-flex; vertical-align: middle; flex-wrap: nowrap;"><span><h1>Review &amp; Launch</h1></span><span id="kx-launch-running-vms" data-text="KX.AS.CODE is already running! Main nodes: ${kxMainRunningVms.size()} Workers nodes: ${kxWorkerRunningVms.size()}" class="warning-span-large tooltip"><img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image-large svg-orange-red" alt="already_running_warning" /></span></div>
        <div class="flex-wrapper" style="display: flex;">
        <span class="description-paragraph-span" style="height: 70px;"><p>${extendedDescription}</p></span>
        <br><br>
            <div class="wrapper" style="width: 100%;">
                <div class="svg-item">
                    <svg width="250px" height="250px" viewBox="0 0 40 40" class="donut">
                        <circle class="donut-hole" cx="20" cy="20" r="15.91549430918954" fill="#fff"></circle>
                        <circle class="donut-ring" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5"></circle>
                        <circle style="stroke: ${cpuPieColour};" class="donut-segment donut-segment-cpu" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5" stroke-dasharray="${overallUsedCpuCoresPercentage} ${overallRemainingCpuCoresPercentage}" stroke-dashoffset="25"></circle>
                        <g class="donut-text donut-text-cpu">
                            <text y="27%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data pie-label">Processor</tspan>
                            </text>
                            <text y="50%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-percent" style="fill: ${cpuPieTextColour};">${overallUsedCpuCoresPercentage}%</tspan>
                            </text>
                            <text y="63%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data">${overallTotalNeededCpuCores} / ${totalSystemCores} Cores</tspan>
                            </text>
                        </g>
                    </svg>
                </div>

                <div class="svg-item">
                    
                    <svg width="250px" height="250px" viewBox="0 0 40 40" class="donut">
                        <circle class="donut-hole" cx="20" cy="20" r="15.91549430918954" fill="#fff"></circle>
                        <circle class="donut-ring" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5"></circle>
                        <circle style="stroke: ${memoryPieColour};" class="donut-segment donut-segment-memory" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5" stroke-dasharray="${overallUsedMemoryPercentage} ${overallRemainingMemoryPercentage}" stroke-dashoffset="25"></circle>
                        <g class="donut-text donut-text-memory">
                            <text y="27%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data pie-label">Memory</tspan>
                            </text>
                            <text y="50%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-percent" style="fill: ${memoryPieTextColour};">${overallUsedMemoryPercentage}%</tspan>
                            </text>
                            <text y="63%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data">${(overallTotalNeededMemory.toInteger() / 1024).toInteger()} / ${(totalPhysicalMemorySize / 1024).toInteger()} GB</tspan>
                            </text>
                        </g>
                    </svg>
                </div>

                <div class="svg-item">
                    <svg width="250px" height="250px" viewBox="0 0 40 40" class="donut">
                        <circle class="donut-hole" cx="20" cy="20" r="15.91549430918954" fill="#fff"></circle>
                        <circle class="donut-ring" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5"></circle>
                        <circle style="stroke: ${diskPieColour};" class="donut-segment donut-segment-disk" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5" stroke-dasharray="${overallStorageNeededPercentage} ${overallRemainingPercentage}" stroke-dashoffset="25"></circle>
                        <g class="donut-text donut-text-disk">
                            <text y="27%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data pie-label">Disk</tspan>
                            </text>
                            <text y="50%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-percent" style="fill: ${diskPieTextColour};">${overallStorageNeededPercentage}%</tspan>
                            </text>
                            <text y="63%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data">${overallStorageRequired} / ${remainingDiskSpace} GB</tspan>
                            </text>
                        </g>
                    </svg>
                </div>
            </div>
            <br><br>
        <div style="width: 100%; height: 120px; display: flex; justify-content: space-evenly;">
            <div class="flex-item">
                <div class="table">
                    <div class="row">
                        <div class="cell cell-label">Standalone Mode</div>
                        <div class="cell cell-value" id="summary-standalone-mode-value"></div>
                    </div>
                    <div class="row">
                        <div class="cell cell-label">Allow Workloads on K8s Master</div>
                        <div class="cell cell-value" id="summary-workloads-on-master-value"></div>
                    </div>
                    <div class="row">
                        <div class="cell cell-label">Disable Linux Desktop</div>
                        <div class="cell cell-value" id="summary-disable-desktop-value"></div>
                    </div>
                </div>
            </div>
            <div class="flex-item">
                <div class="table">
                    <div class="row">
                        <div class="cell cell-label">Number of KX-Main Nodes</div>
                        <div class="cell cell-value" id="summary-main-nodes-number-value"></div>
                    </div>
                    <div class="row">
                        <div class="cell cell-label">Number of KX-Worker Nodes</div>
                        <div class="cell cell-value" id="summary-worker-nodes-number-value"></div>
                    </div>
                     <div class="row">
                        <div class="cell cell-label">Selected Install Groups</div>
                        <div class="cell cell-value">
                            <div class="tooltip-info">
                                <div id="list-templates-to-install">0 templates</div>
                                <span id="list-templates-tooltip-text" class="tooltiptext"></span>
                            </div>
                        </div>
                    </div>                   
                </div>
            </div>
         </div>

            <div class="div-border-text-inline">
                <h2 class="h2-header-in-line"><span class="span-h2-header-in-line"><img class="svg-blue" src="/userContent/icons/rocket-launch-outline.svg" height="25" width="25">&nbsp;Launcher Config Panel</span></h2>
                <div class="div-inner-h2-header-in-line-wrapper">
                    <span class="description-paragraph-span"><p>Here you can start, stop and destroy the KX.AS.CODE environment. KX.AS.CODE will be deployed to \"<span id="summary-profile-value" ></span>\" started in \"<span id="summary-start-mode-value" ></span>\" mode.
                    </div>

                <div class="div-inner-h2-header-in-line-wrapper">
                    <span style="vertical-align: middle; display: inline-block;">
                        <span class="launch-action-text-label" style="width: 50px;">Date: </span><span id="kx-launch-build-timestamp" class="build-action-text-value"></span>
                        <span class="launch-action-text-label" style="width: 70px; ">Status: </span><span id="kx-launch-build-result" style="width: 100px; margin-right: 20px; display: inline-flex;"></span>
                        <span class="launch-action-text-label" style="width: 100px;">Last Action: </span><span id="kx-launch-last-action" class="build-action-text-value" style="width: 50px;"></span>
                        <span class="launch-action-text-label" style="width: 100px;">KX-Version:</span><span id="kx-launch-build-kx-version" class="build-action-text-value build-action-text-value-result" style="width: 80px;"></span>
                        <span class="launch-action-text-label" style="width: 115px;">Kube-Version:</span><span id="kx-launch-build-kube-version" class="build-action-text-value build-action-text-value-result" style="width: 80px;"></span>
                        <span class="build-number-span" id="kx-launch-build-number-link"></span>
                    </span>
                    <span id="launcher-config-panel-actions" class='span-rounded-border'>
                        <img src='/userContent/icons/play.svg' class="build-action-icon" title="Start Environment" alt="Start Environment" onclick='performRuntimeAction("up");' id="build-kx-launch-play-button"/>|
                        <img src='/userContent/icons/stop.svg' class="build-action-icon" title="Stop Environment" alt="Stop Environment" onclick='performRuntimeAction("halt");' />|
                        <img src='/userContent/icons/cancel.svg' class="build-action-icon" title="Delete Environment" alt="Delete Environment" onclick='performRuntimeAction("destroy");' />|
                        <div class="console-log"><span class="console-log-span"><img src="/userContent/icons/text-box-outline.svg" onMouseover='showConsoleLog("KX.AS.CODE_Runtime_Actions", "kx-launch");' onclick='openFullConsoleLog("KX.AS.CODE_Runtime_Actions", "kx-launch");' class="build-action-icon" alt="View Build Log" title="Click to open full log in new tab"><span class="consolelogtext" id='kxLaunchBuildConsoleLog'></span></span></div>
                    </span>
                                    </div>
                </div>
            </div>
         </div>
    </div>
    <style scoped="scoped" onload="populateReviewTable(); getBuildJobListForProfile('KX.AS.CODE_Runtime_Actions', 'kx-launch'); displayOrHideKxAlreadyRunningWarning(${kxMainRunningVms.size()});">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (config_review_and_launch.groovy): ${e}"
}

