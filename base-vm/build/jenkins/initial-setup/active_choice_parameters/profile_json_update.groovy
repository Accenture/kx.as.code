import groovy.json.JsonSlurper
import groovy.json.JsonBuilder

def BASE_DOMAIN
def BASE_USER
def ENVIRONMENT_PREFIX
def BASE_PASSWORD
def ALLOW_WORKLOADS_ON_KUBERNETES_MASTER

def localVolumeParameterElements
def generalParameterElements

def updatedJson
def parsedJson
def jsonFilePath = PROFILE
def inputFile = new File(jsonFilePath)

try {

    parsedJson = new JsonSlurper().parse(inputFile)

    if ( GENERAL_PARAMETERS ) {
        generalParameterElements = GENERAL_PARAMETERS.split(';')
        BASE_DOMAIN = generalParameterElements[0]
        ENVIRONMENT_PREFIX = generalParameterElements[1]
        BASE_USER = generalParameterElements[2]
        BASE_PASSWORD = generalParameterElements[3]
    } else {
        BASE_DOMAIN = parsedJson.config.baseDomain
        ENVIRONMENT_PREFIX = parsedJson.config.environmentPrefix
        BASE_USER = parsedJson.config.baseUser
        BASE_PASSWORD = parsedJson.config.basePassword
    }

    if ( LOCAL_STORAGE_OPTIONS ) {
        localVolumeParameterElements = LOCAL_STORAGE_OPTIONS.split(';')
        println("localVolumeParameterElements: ${localVolumeParameterElements}")
        number1GbVolumes = localVolumeParameterElements[0].toInteger()
        number5GbVolumes = localVolumeParameterElements[1].toInteger()
        number10GbVolumes = localVolumeParameterElements[2].toInteger()
        number30GbVolumes = localVolumeParameterElements[3].toInteger()
        number50GbVolumes = localVolumeParameterElements[4].toInteger()
    } else {
        number1GbVolumes = parsedJson.config.local_volumes.one_gb
        number5GbVolumes = parsedJson.config.local_volumes.five_gb
        number10GbVolumes = parsedJson.config.local_volumes.ten_gb
        number30GbVolumes = parsedJson.config.local_volumes.thirty_gb
        number50GbVolumes = parsedJson.config.local_volumes.fifty_gb
    }

    def OLD_NUMBER_OF_KX_MAIN_NODES = parsedJson.config.vm_properties.main_node_count
    if (OLD_NUMBER_OF_KX_MAIN_NODES != NUMBER_OF_KX_MAIN_NODES && NUMBER_OF_KX_MAIN_NODES != "") {
        println("Updating NUMBER_OF_KX_MAIN_NODES to " + NUMBER_OF_KX_MAIN_NODES)
        parsedJson.config.vm_properties.main_node_count = NUMBER_OF_KX_MAIN_NODES.toInteger()
    }

    def OLD_KX_MAIN_ADMIN_CPU_CORES = parsedJson.config.vm_properties.main_admin_node_cpu_cores
    if (OLD_KX_MAIN_ADMIN_CPU_CORES != KX_MAIN_ADMIN_CPU_CORES && KX_MAIN_ADMIN_CPU_CORES != "") {
        println("Updating KX_MAIN_ADMIN_CPU_CORES to " + KX_MAIN_ADMIN_CPU_CORES)
        parsedJson.config.vm_properties.main_admin_node_cpu_cores = KX_MAIN_ADMIN_CPU_CORES.toInteger()
    }

    def OLD_KX_MAIN_ADMIN_MEMORY = parsedJson.config.vm_properties.main_admin_node_memory
    if (OLD_KX_MAIN_ADMIN_MEMORY != KX_MAIN_ADMIN_MEMORY && KX_MAIN_ADMIN_MEMORY != "") {
        parsedJson.config.vm_properties.main_admin_node_memory = KX_MAIN_ADMIN_MEMORY.toInteger()
    }

    if (STANDALONE_MODE) {
        def triggers = STANDALONE_MODE.split(',')
        STANDALONE_MODE = triggers[0]
        ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = triggers[1]

        println("STANDALONE_MODE: ${STANDALONE_MODE}")
        def OLD_STANDALONE_MODE = parsedJson.config.standaloneMode
        if (OLD_STANDALONE_MODE != STANDALONE_MODE && STANDALONE_MODE != null) {
            if (STANDALONE_MODE == "" || STANDALONE_MODE == false) {
                parsedJson.config.standaloneMode = false
            } else {
                parsedJson.config.standaloneMode = true
            }
        }

        println("ALLOW_WORKLOADS_ON_KUBERNETES_MASTER: ${ALLOW_WORKLOADS_ON_KUBERNETES_MASTER}")
        def OLD_ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = parsedJson.config.allowWorkloadsOnMaster
        if (OLD_ALLOW_WORKLOADS_ON_KUBERNETES_MASTER != ALLOW_WORKLOADS_ON_KUBERNETES_MASTER && ALLOW_WORKLOADS_ON_KUBERNETES_MASTER != null) {
            if (ALLOW_WORKLOADS_ON_KUBERNETES_MASTER == "" || ALLOW_WORKLOADS_ON_KUBERNETES_MASTER == false) {
                parsedJson.config.allowWorkloadsOnMaster = false
            } else {
                parsedJson.config.allowWorkloadsOnMaster = true
            }
        }
    }

    def OLD_BASE_DOMAIN = parsedJson.config.baseDomain
    if (OLD_BASE_DOMAIN != BASE_DOMAIN && BASE_DOMAIN != "") {
        parsedJson.config.baseDomain = BASE_DOMAIN
    }

    def OLD_ENVIRONMENT_PREFIX = parsedJson.config.environmentPrefix
    if (OLD_ENVIRONMENT_PREFIX != ENVIRONMENT_PREFIX && ENVIRONMENT_PREFIX != "") {
        parsedJson.config.environmentPrefix = ENVIRONMENT_PREFIX
    }

    def OLD_BASE_USER = parsedJson.config.baseUser
    if (OLD_BASE_USER != BASE_USER && BASE_USER != "") {
        parsedJson.config.baseUser = BASE_USER
    }

    def OLD_BASE_PASSWORD = parsedJson.config.basePassword
    if (OLD_BASE_PASSWORD != BASE_PASSWORD && BASE_PASSWORD != "") {
        parsedJson.config.basePassword = BASE_PASSWORD
    }

    def local_storage_num_one_gb = parsedJson.config.local_volumes.one_gb
    int number1GbVolumes = localVolumeParameterElements[0].toInteger()
    if (local_storage_num_one_gb.toInteger() != number1GbVolumes && number1GbVolumes != "") {
        parsedJson.config.local_volumes.one_gb = number1GbVolumes
    }

    def local_storage_num_five_gb = parsedJson.config.local_volumes.five_gb
    int number5GbVolumes = localVolumeParameterElements[1].toInteger()
    if (local_storage_num_five_gb.toInteger() != number5GbVolumes && number5GbVolumes != "") {
        parsedJson.config.local_volumes.five_gb = number1GbVolumes
    }

    def local_storage_num_ten_gb = parsedJson.config.local_volumes.ten_gb
    int number10GbVolumes = localVolumeParameterElements[2].toInteger()
    if (local_storage_num_ten_gb.toInteger() != number10GbVolumes && number10GbVolumes != "") {
        parsedJson.config.local_volumes.ten_gb = number10GbVolumes
    }

    def local_storage_num_thirty_gb = parsedJson.config.local_volumes.thirty_gb
    int number30GbVolumes = localVolumeParameterElements[3].toInteger()
    if (local_storage_num_thirty_gb.toInteger() != number30GbVolumes && number30GbVolumes != "") {
        parsedJson.config.local_volumes.thirty_gb = number30GbVolumes
    }

    def local_storage_num_fifty_gb = parsedJson.config.local_volumes.fifty_gb
    int number50GbVolumes = localVolumeParameterElements[4].toInteger()
    if (local_storage_num_fifty_gb.toInteger() != number50GbVolumes && number50GbVolumes != "") {
        parsedJson.config.local_volumes.fifty_gb = number50GbVolumes
    }

    def OLD_NETWORK_STORAGE_OPTIONS = parsedJson.config.glusterFsDiskSize
    if (OLD_NETWORK_STORAGE_OPTIONS != NETWORK_STORAGE_OPTIONS && NETWORK_STORAGE_OPTIONS != "") {
        parsedJson.config.baseUser = NETWORK_STORAGE_OPTIONS.toInteger()
    }

    updatedJson = new JsonBuilder(parsedJson).toPrettyString()

    new File(jsonFilePath).write(new JsonBuilder(parsedJson).toPrettyString())
    println(updatedJson)
    println("GENERAL_PARAMETERS: ${GENERAL_PARAMETERS}")
    println("BASE_DOMAIN: ${BASE_DOMAIN}")
    println("ENVIRONMENT_PREFIX: ${ENVIRONMENT_PREFIX}")
    println("BASE_USER: ${BASE_USER}")
    println("BASE_PASSWORD: ${BASE_PASSWORD}")
    println("PROFILE: ${PROFILE}")
    println("STANDALONE_MODE: ${STANDALONE_MODE}")
    println("KX_MAIN_ADMIN_MEMORY: ${KX_MAIN_ADMIN_MEMORY}")
    println("KX_MAIN_ADMIN_CPU_CORES: ${KX_MAIN_ADMIN_CPU_CORES}")
    println("ALLOW_WORKLOADS_ON_KUBERNETES_MASTER: ${ALLOW_WORKLOADS_ON_KUBERNETES_MASTER}")
    println("GENERAL_PARAMETERS: ${GENERAL_PARAMETERS}")
    println("NUMBER_OF_KX_MAIN_NODES: ${NUMBER_OF_KX_MAIN_NODES}")
    println("NETWORK_STORAGE_OPTIONS: ${NETWORK_STORAGE_OPTIONS}")
    println("LOCAL_STORAGE_OPTIONS: ${LOCAL_STORAGE_OPTIONS}")

    println("Bottom of update JSON groovy")
} catch(e) {
    println("Something went wrong in the GROOVY block (profile_json_update): ${e}")
}

try {
    // language=HTML
    def HTML = """
    <body>
    <p>
    BASE_DOMAIN: ${BASE_DOMAIN}, ENVIRONMENT_PREFIX: ${ENVIRONMENT_PREFIX}, BASE_USER: ${BASE_USER}, BASE_PASSWORD: ${BASE_PASSWORD}
    ${updatedJson}
    </p>
    </body>
    """
    return HTML
} catch (e) {
    println("Something went wrong in the HTML return block (profile_json_update): ${e}")
}
