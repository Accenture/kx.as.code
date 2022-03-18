import java.lang.management.*
import groovy.json.JsonSlurper

def extendedDescription

try {
    extendedDescription = "The charts below show how the selections you made above fit in line with the resources available on your system. If any of the charts are red, you should look to make corrections in the previous tabs. For the storage parameters, this is not critical, as the volumes are thinly provisioned anyway, so an overallocation is not a problem, as long as you don't intend to use the full space."
} catch(e) {
    println "Something went wrong in the GROOVY block (check_host_system.groovy): ${e}"
}

long freePhysicalMemorySize
long totalPhysicalMemorySize
int totalSystemCores
def currentSystemDisk
long totalSystemDisk
long freeSystemDisk
long usableSystemDisk

int kxMainMemory
int kxMainNumber
int kxMainCpuCores
int kxWorkerMemory
int kxWorkerNumber
int kxWorkerCpuCores

def normalPieColour = "#9f4dd3"
def warningPieColour = "#FF6200"
def alertPieColour = "#f44336"

def cpuPieColor
def memoryPieColor
def diskPieColor

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
def jsonFilePath = PROFILE
def inputFile = new File(jsonFilePath)

def ALLOW_WORKLOADS_ON_KUBERNETES_MASTER

try {

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
        println("storageParameterElements: ${storageParameterElements} (check_host_system.groovy)")
        number1GbVolumes = storageParameterElements[0].toInteger()
        number5GbVolumes = storageParameterElements[1].toInteger()
        number10GbVolumes = storageParameterElements[2].toInteger()
        number30GbVolumes = storageParameterElements[3].toInteger()
        number50GbVolumes = storageParameterElements[4].toInteger()
        networkStorageVolume = storageParameterElements[5].toInteger()
    } else {
        number1GbVolumes = parsedJson.config.local_volumes.one_gb
        number5GbVolumes = parsedJson.config.local_volumes.five_gb
        number10GbVolumes = parsedJson.config.local_volumes.ten_gb
        number30GbVolumes = parsedJson.config.local_volumes.thirty_gb
        number50GbVolumes = parsedJson.config.local_volumes.fifty_gb
        networkStorageVolume = parsedJson.config.glusterFsDiskSize
    }

    println("number1GbVolumes ${number1GbVolumes}")
    println("number5GbVolumes ${number5GbVolumes}")
    println("number10GbVolumes ${number10GbVolumes}")
    println("number30GbVolumes ${number30GbVolumes}")
    println("number50GbVolumes ${number50GbVolumes}")
    println("networkStorageVolume ${networkStorageVolume}")

    int totalLocalDiskSpace = totalSystemDisk.toInteger()
    int remainingDiskSpace = freeSystemDisk.toInteger()
    int totalLocalStorageRequired

    println("DEBUG --> 1 (check_host_system.groovy)")

    if ( GENERAL_PARAMETERS ) {
        generalParameterElements = GENERAL_PARAMETERS.split(';')
        BASE_DOMAIN = generalParameterElements[0]
        ENVIRONMENT_PREFIX = generalParameterElements[1]
        BASE_USER = generalParameterElements[2]
        BASE_PASSWORD = generalParameterElements[3]
        STANDALONE_MODE = generalParameterElements[4]
        ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = generalParameterElements[5]
    } else {
        BASE_DOMAIN = parsedJson.config.baseDomain
        ENVIRONMENT_PREFIX = parsedJson.config.environmentPrefix
        BASE_USER = parsedJson.config.baseUser
        BASE_PASSWORD = parsedJson.config.basePassword
        STANDALONE_MODE = parsedJson.config.standaloneMode
        ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = parsedJson.config.allowWorkloadsOnMaster
    }

    if (ALLOW_WORKLOADS_ON_KUBERNETES_MASTER == "true") {
        println("DEBUG --> 1.4.1 (check_host_system.groovy)")
        totalLocalStorageRequired = (number1GbVolumes + (number5GbVolumes * 5) + (number10GbVolumes * 10) + (number30GbVolumes * 30) + (number50GbVolumes * 50)) * (kxMainNumber + kxWorkerNumber)
    } else {
        println("DEBUG --> 1.4.2 (check_host_system.groovy)")
        totalLocalStorageRequired = (number1GbVolumes + (number5GbVolumes * 5) + (number10GbVolumes * 10) + (number30GbVolumes * 30) + (number50GbVolumes * 50)) * kxWorkerNumber
    }
    println("DEBUG --> 1.5 (check_host_system.groovy)")

    overallStorageRequired = totalLocalStorageRequired + networkStorageVolume

    overallStorageNeededPercentage = (overallStorageRequired / remainingDiskSpace) * 100
    overallRemainingPercentage = 100 - overallStorageNeededPercentage

    int slaveTotalMemory = totalPhysicalMemorySize.toInteger()
    int slaveFreeMemory = freePhysicalMemorySize.toInteger()
    println("DEBUG --> 2 (check_host_system.groovy)")
    int usedMemory = slaveTotalMemory - slaveFreeMemory
    //int usedMemoryPercentage = (usedMemory / slaveTotalMemory) * 100
    //int freeMemoryPercentage = (slaveFreeMemory / slaveTotalMemory) * 100

    println("KX_MAIN_NODES_CONFIG: ${KX_MAIN_NODES_CONFIG} (check_host_system.groovy)")
    if ( KX_MAIN_NODES_CONFIG ) {
        kxMainNodesConfigArray = KX_MAIN_NODES_CONFIG.split(';')
        NUMBER_OF_KX_MAIN_NODES = kxMainNodesConfigArray[0]
        KX_MAIN_ADMIN_CPU_CORES = kxMainNodesConfigArray[1]
        KX_MAIN_ADMIN_MEMORY = kxMainNodesConfigArray[2]
    }

    println("KX_WORKER_NODES_CONFIG: ${KX_WORKER_NODES_CONFIG} (check_host_system.groovy)")
    if ( KX_WORKER_NODES_CONFIG ) {
        kxWorkerNodesConfigArray = KX_WORKER_NODES_CONFIG.split(';')
        NUMBER_OF_KX_WORKER_NODES = kxWorkerNodesConfigArray[0]
        KX_WORKER_NODES_CPU_CORES = kxWorkerNodesConfigArray[1]
        KX_WORKER_NODES_MEMORY = kxWorkerNodesConfigArray[2]
    }

    if ( KX_MAIN_ADMIN_MEMORY ) {
        kxMainMemory = KX_MAIN_ADMIN_MEMORY.toInteger()
    } else {
        kxMainMemory = parsedJson.config.vm_properties.main_admin_node_memory
    }

    if ( NUMBER_OF_KX_MAIN_NODES ) {
        kxMainNumber = NUMBER_OF_KX_MAIN_NODES.toInteger()
    } else {
        kxMainNumber = parsedJson.config.vm_properties.main_node_count
    }

    if ( KX_MAIN_ADMIN_CPU_CORES ) {
        kxMainCpuCores = KX_MAIN_ADMIN_CPU_CORES.toInteger()
    } else {
        kxMainCpuCores = parsedJson.config.vm_properties.main_admin_node_cpu_cores
    }

    int totalNeededMainNodeMemory = kxMainMemory * kxMainNumber
    int totalNeededMainNodeCpuCores = kxMainCpuCores * kxMainNumber

    if ( KX_WORKER_NODES_MEMORY ) {
        kxWorkerMemory = KX_MAIN_ADMIN_MEMORY.toInteger()
    } else {
        kxWorkerMemory = parsedJson.config.vm_properties.worker_node_memory
    }

    if ( NUMBER_OF_KX_WORKER_NODES ) {
        kxWorkerNumber = NUMBER_OF_KX_MAIN_NODES.toInteger()
    } else {
        kxWorkerNumber = parsedJson.config.vm_properties.worker_node_count
    }

    if ( KX_WORKER_NODES_CPU_CORES ) {
        kxWorkerCpuCores = KX_MAIN_ADMIN_CPU_CORES.toInteger()
    } else {
        kxWorkerCpuCores = parsedJson.config.vm_properties.worker_node_cpu_cores
    }

    NUMBER_OF_KX_WORKER_NODES = NUMBER_OF_KX_WORKER_NODES ?: "0"
    KX_WORKER_NODES_MEMORY = KX_WORKER_NODES_MEMORY ?: "0"
    KX_WORKER_NODES_CPU_CORES = KX_WORKER_NODES_CPU_CORES ?: "0"

    println("NUMBER_OF_KX_MAIN_NODES (check_host_system.groovy): ${NUMBER_OF_KX_MAIN_NODES}")
    println("NUMBER_OF_KX_WORKER_NODES (check_host_system.groovy): ${NUMBER_OF_KX_WORKER_NODES}")
    println("KX_WORKER_NODES_MEMORY (check_host_system.groovy): ${KX_WORKER_NODES_MEMORY}")
    println("KX_WORKER_NODES_CPU_CORES (check_host_system.groovy): ${KX_WORKER_NODES_CPU_CORES}")

    int totalNeededWorkerNodeMemory = kxWorkerMemory * kxWorkerNumber
    int totalNeededWorkerNodeCpuCores = kxWorkerCpuCores * kxWorkerNumber

    println("DEBUG --> 3 (check_host_system.groovy)")

    overallTotalNeededMemory = totalNeededMainNodeMemory + totalNeededWorkerNodeMemory
    overallTotalNeededCpuCores = totalNeededMainNodeCpuCores + totalNeededWorkerNodeCpuCores

    overallUsedCpuCoresPercentage = (overallTotalNeededCpuCores / totalSystemCores.toInteger()) * 100
    overallUsedMemoryPercentage = (overallTotalNeededMemory / slaveTotalMemory) * 100

    overallRemainingCpuCoresPercentage = 100 - overallUsedCpuCoresPercentage
    overallRemainingMemoryPercentage = 100 - overallUsedMemoryPercentage

    if (overallUsedCpuCoresPercentage >= 90 && overallUsedCpuCoresPercentage < 100) {
        cpuPieColor = warningPieColour
    } else if (overallUsedCpuCoresPercentage >= 100) {
        cpuPieColor = alertPieColour
    } else {
        cpuPieColor = normalPieColour
    }

    if (overallUsedMemoryPercentage >= 90 && overallUsedMemoryPercentage < 100) {
        memoryPieColor = warningPieColour
    } else if (overallUsedMemoryPercentage >= 100) {
        memoryPieColor = alertPieColour
    } else {
        memoryPieColor = normalPieColour
    }

    if (overallStorageNeededPercentage >= 90 && overallStorageNeededPercentage < 100) {
        diskPieColor = warningPieColour
    } else if (overallStorageNeededPercentage >= 100) {
        diskPieColor = alertPieColour
    } else {
        diskPieColor = normalPieColour
    }

} catch(e) {
    println "Something went wrong in the GROOVY block (check_host_system.groovy): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <body>

        <div id="header-system-check-div" style="display: none;">
            <h2>System Check</h2>
            <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
        </div>

        <div id="system-check-div" style="width: 800px; display: none;">
            <div class="wrapper" style="width: 800px;">
                <div class="svg-item">
                    <svg width="200px" height="200px" viewBox="0 0 40 40" class="donut">
                        CPU
                        <circle class="donut-hole" cx="20" cy="20" r="15.91549430918954" fill="#fff"></circle>
                        <circle class="donut-ring" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5"></circle>
                        <circle style="stroke: ${cpuPieColor};" class="donut-segment donut-segment-cpu" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5" stroke-dasharray="${overallUsedCpuCoresPercentage} ${overallRemainingCpuCoresPercentage}" stroke-dashoffset="25"></circle>
                        <g class="donut-text donut-text-cpu">

                            <text y="50%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-percent" style="fill: ${cpuPieColor};">${overallUsedCpuCoresPercentage}%</tspan>
                            </text>
                            <text y="60%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data">${overallTotalNeededCpuCores} CPU Cores</tspan>
                            </text>
                        </g>
                    </svg>
                </div>

                <div class="svg-item">
                    <svg width="200px" height="200px" viewBox="0 0 40 40" class="donut">
                        Memory
                        <circle class="donut-hole" cx="20" cy="20" r="15.91549430918954" fill="#fff"></circle>
                        <circle class="donut-ring" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5"></circle>
                        <circle style="stroke: ${memoryPieColor};" class="donut-segment donut-segment-memory" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5" stroke-dasharray="${overallUsedMemoryPercentage} ${overallRemainingMemoryPercentage}" stroke-dashoffset="25"></circle>
                        <g class="donut-text donut-text-memory">

                            <text y="50%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-percent" style="fill: ${memoryPieColor};">${overallUsedMemoryPercentage}%</tspan>
                            </text>
                            <text y="60%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data">${overallTotalNeededMemory / 1024} GB Memory</tspan>
                            </text>
                        </g>++
                    </svg>
                </div>

                <div class="svg-item">
                    <svg width="200px" height="200px" viewBox="0 0 40 40" class="donut">
                        Disk Space
                        <circle class="donut-hole" cx="20" cy="20" r="15.91549430918954" fill="#fff"></circle>
                        <circle class="donut-ring" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5"></circle>
                        <circle style="stroke: ${diskPieColor};" class="donut-segment donut-segment-disk" cx="20" cy="20" r="15.91549430918954" fill="transparent" stroke-width="3.5" stroke-dasharray="${overallStorageNeededPercentage} ${overallRemainingPercentage}" stroke-dashoffset="25"></circle>
                        <g class="donut-text donut-text-disk">

                            <text y="50%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-percent" style="fill: ${diskPieColor};">${overallStorageNeededPercentage}%</tspan>
                            </text>
                            <text y="60%" transform="translate(0, 2)">
                                <tspan x="50%" text-anchor="middle" class="donut-data">${overallStorageRequired} GB Disk Space</tspan>
                            </text>
                        </g>
                    </svg>
                </div>
            </div>
        </div>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (check_host_system.groovy): ${e}"
}
