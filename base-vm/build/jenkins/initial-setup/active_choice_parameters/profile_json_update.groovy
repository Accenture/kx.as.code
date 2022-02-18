import groovy.json.JsonSlurper
import groovy.json.JsonBuilder
import java.nio.file.Files

def BASE_DOMAIN
def BASE_USER
def ENVIRONMENT_PREFIX
def BASE_PASSWORD
def STANDALONE_MODE
def ALLOW_WORKLOADS_ON_KUBERNETES_MASTER
def NUMBER_OF_KX_MAIN_NODES
def KX_MAIN_ADMIN_CPU_CORES
def KX_MAIN_ADMIN_MEMORY
def NUMBER_OF_KX_WORKER_NODES
def KX_WORKER_NODES_CPU_CORES
def KX_WORKER_NODES_MEMORY

def storageParameterElements
def generalParameterElements

def updatedJson
def parsedJson
def jsonFilePath = PROFILE
def inputFile = new File(jsonFilePath)
def profileParentPath = inputFile.getParentFile().getName()

def templateName
def parsedTemplateJson
def jsonInputFile

def template_paths = []
def selectedTemplates = []
def destinationFile
def alreadyExistingTemplateFilesInProfile = []
def fileToDelete

new File('jenkins_shared_workspace/kx.as.code/templates/').eachFileMatch(~/^aq.*.json$/) { template_paths << it.path }
selectedTemplates = TEMPLATE_SELECTOR.split(';');
println("TEMPLATE_SELECTOR: ${TEMPLATE_SELECTOR}")
println("template_paths: ${template_paths}")

try {
    if ( USER_PROVISIONING ) {
        def userJsonFilePath = "jenkins_shared_workspace/kx.as.code/profiles/${profileParentPath}/users.json"
        def parsedUserJson = new JsonSlurper().parseText(USER_PROVISIONING)
        new File(userJsonFilePath).write(new JsonBuilder(parsedUserJson).toPrettyString())
    }
} catch (e) {
    println("Something went wrong in the groovy user provisioning block (profile_json_update.groovy): ${e}")
}

try {
    println("Before file search")
    def targetProfilePath="jenkins_shared_workspace/kx.as.code/profiles/${profileParentPath}"
    new File(targetProfilePath).eachFileMatch(~/^aq.*.json$/) { alreadyExistingTemplateFilesInProfile << it.path }
    alreadyExistingTemplateFilesInProfile.eachWithIndex { profileTemplateJson, i ->
            println("Found ${profileTemplateJson} already in profiles directory")
        if ( profileTemplateJson.contains("custom")) {
            println("${profileTemplateJson} contains the word \"custom\". Not deleting")
        } else {
            println("Deleting standard template ${profileTemplateJson}")
            fileToDelete = new File(profileTemplateJson)
            fileToDelete.delete()
        }
    }
    println("After file search")

    template_paths.eachWithIndex { file, i ->
        println("Processing file ${i} - ${file}")
        jsonInputFile = new File(file)
        parsedTemplateJson = new JsonSlurper().parse(jsonInputFile)
        templateName = parsedTemplateJson.title
        println("Parsed json and received title: ${templateName}")
        selectedTemplates.eachWithIndex { selectedTemplate, j ->
            if (selectedTemplate == templateName) {
                println("${templateName} is selected. Adding components to list")
                destinationFile = new File("${targetProfilePath}/${jsonInputFile.getName()}")
                println("Copying ${jsonInputFile.toPath()} to ${destinationFile.toPath()}")
                Files.copy(jsonInputFile.toPath(), destinationFile.toPath())
            } else {
                println("${templateName} not selected. Ignoring")
            }
        }
    }
} catch (e) {
    println("Something went wrong in the groovy template block (profile_json_update.groovy): ${e}")
}

try {

    parsedJson = new JsonSlurper().parse(inputFile)

    if ( GENERAL_PARAMETERS ) {
        generalParameterElements = GENERAL_PARAMETERS.split(';')
        BASE_DOMAIN = generalParameterElements[0]
        ENVIRONMENT_PREFIX = generalParameterElements[1]
        BASE_USER = generalParameterElements[2]
        BASE_PASSWORD = generalParameterElements[3]
        STANDALONE_MODE = generalParameterElements[4]
        ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = generalParameterElements[5]
        println("Retrieved BASE_DOMAIN: ${BASE_DOMAIN} (profile_json_update.groovy)")
        println("Retrieved ENVIRONMENT_PREFIX: ${ENVIRONMENT_PREFIX} (profile_json_update.groovy)")
        println("Retrieved BASE_USER: ${BASE_USER} (profile_json_update.groovy)")
        println("Retrieved BASE_PASSWORD: ${BASE_PASSWORD} (profile_json_update.groovy)")
        println("Retrieved STANDALONE_MODE: ${STANDALONE_MODE} (profile_json_update.groovy)")
        println("Retrieved ALLOW_WORKLOADS_ON_KUBERNETES_MASTER: ${ALLOW_WORKLOADS_ON_KUBERNETES_MASTER} (profile_json_update.groovy)")
    }

    if ( KX_MAIN_NODES_CONFIG ) {

        kxMainNodesConfigArray = KX_MAIN_NODES_CONFIG.split(';')
        NUMBER_OF_KX_MAIN_NODES = kxMainNodesConfigArray[0]
        KX_MAIN_ADMIN_CPU_CORES = kxMainNodesConfigArray[1]
        KX_MAIN_ADMIN_MEMORY = kxMainNodesConfigArray[2]
    }

    if ( KX_WORKER_NODES_CONFIG ) {
        kxWorkerNodesConfigArray = KX_WORKER_NODES_CONFIG.split(';')
        NUMBER_OF_KX_WORKER_NODES = kxWorkerNodesConfigArray[0]
        KX_WORKER_NODES_CPU_CORES = kxWorkerNodesConfigArray[1]
        KX_WORKER_NODES_MEMORY = kxWorkerNodesConfigArray[2]
    }

    if (STORAGE_PARAMETERS) {
        storageParameterElements = STORAGE_PARAMETERS.split(';')
    }

    def OLD_NUMBER_OF_KX_MAIN_NODES = parsedJson.config.vm_properties.main_node_count
    if (OLD_NUMBER_OF_KX_MAIN_NODES != NUMBER_OF_KX_MAIN_NODES && NUMBER_OF_KX_MAIN_NODES != "" && NUMBER_OF_KX_MAIN_NODES) {
        println("Updating NUMBER_OF_KX_MAIN_NODES to " + NUMBER_OF_KX_MAIN_NODES)
        parsedJson.config.vm_properties.main_node_count = NUMBER_OF_KX_MAIN_NODES.toInteger()
    }

    def OLD_KX_MAIN_ADMIN_CPU_CORES = parsedJson.config.vm_properties.main_admin_node_cpu_cores
    if (OLD_KX_MAIN_ADMIN_CPU_CORES != KX_MAIN_ADMIN_CPU_CORES && KX_MAIN_ADMIN_CPU_CORES != "" && KX_MAIN_ADMIN_CPU_CORES) {
        println("Updating KX_MAIN_ADMIN_CPU_CORES to " + KX_MAIN_ADMIN_CPU_CORES)
        parsedJson.config.vm_properties.main_admin_node_cpu_cores = KX_MAIN_ADMIN_CPU_CORES.toInteger()
    }

    def OLD_KX_MAIN_ADMIN_MEMORY = parsedJson.config.vm_properties.main_admin_node_memory
    if (OLD_KX_MAIN_ADMIN_MEMORY != KX_MAIN_ADMIN_MEMORY && KX_MAIN_ADMIN_MEMORY != "" && KX_MAIN_ADMIN_MEMORY) {
        parsedJson.config.vm_properties.main_admin_node_memory = KX_MAIN_ADMIN_MEMORY.toInteger()
    }
    
    def OLD_NUMBER_OF_KX_WORKER_NODES = parsedJson.config.vm_properties.worker_node_count
    if (OLD_NUMBER_OF_KX_WORKER_NODES != NUMBER_OF_KX_WORKER_NODES && NUMBER_OF_KX_WORKER_NODES != "" && NUMBER_OF_KX_WORKER_NODES) {
        println("Updating NUMBER_OF_KX_WORKER_NODES to " + NUMBER_OF_KX_WORKER_NODES)
        parsedJson.config.vm_properties.worker_node_count = NUMBER_OF_KX_WORKER_NODES.toInteger()
    }

    def OLD_KX_WORKER_NODES_CPU_CORES = parsedJson.config.vm_properties.worker_node_cpu_cores
    if (OLD_KX_WORKER_NODES_CPU_CORES != KX_WORKER_NODES_CPU_CORES && KX_WORKER_NODES_CPU_CORES != "" && KX_WORKER_NODES_CPU_CORES) {
        println("Updating KX_WORKER_NODES_CPU_CORES to " + KX_WORKER_NODES_CPU_CORES)
        parsedJson.config.vm_properties.worker_node_cpu_cores = KX_WORKER_NODES_CPU_CORES.toInteger()
    }

    def OLD_KX_WORKER_NODES_MEMORY = parsedJson.config.vm_properties.worker_node_memory
    if (OLD_KX_WORKER_NODES_MEMORY != KX_WORKER_NODES_MEMORY && KX_WORKER_NODES_MEMORY != "" && KX_WORKER_NODES_MEMORY) {
        println("Updating KX_WORKER_NODES_MEMORY to " + KX_WORKER_NODES_MEMORY)
        parsedJson.config.vm_properties.worker_node_memory = KX_WORKER_NODES_MEMORY.toInteger()
    }

    if (BASE_DOMAIN) {
        def OLD_BASE_DOMAIN = parsedJson.config.baseDomain
        if (OLD_BASE_DOMAIN != BASE_DOMAIN && BASE_DOMAIN != "") {
            println("Updating BASE_DOMAIN to " + BASE_DOMAIN)
            parsedJson.config.baseDomain = BASE_DOMAIN
        }
    } else {
        println("BASE_DOMAIN not changed. Skipping JSON update for this property")
        BASE_DOMAIN = parsedJson.config.baseDomain
    }

    if (ENVIRONMENT_PREFIX) {
        println("Updating ENVIRONMENT_PREFIX to " + ENVIRONMENT_PREFIX)
        parsedJson.config.environmentPrefix = ENVIRONMENT_PREFIX
    } else {
        println("ENVIRONMENT_PREFIX not changed. Skipping JSON update for this property")
        ENVIRONMENT_PREFIX = parsedJson.config.environmentPrefix
    }

    if (BASE_USER) {
        println("Updating BASE_USER to " + BASE_USER)
        parsedJson.config.baseUser = "${BASE_USER}"
        println("BASE_USER JSON after update: ${parsedJson.config.baseUser}")
    } else {
        println("BASE_USER not changed. Skipping JSON update for this property")
        BASE_USER = parsedJson.config.baseUser
    }

    if (BASE_PASSWORD) {
        println("Updating BASE_PASSWORD to " + BASE_PASSWORD)
        parsedJson.config.basePassword = "${BASE_PASSWORD}"
        println("BASE_PASSWORD JSON after update: ${parsedJson.config.basePassword}")
    } else {
        println("BASE_PASSWORD not changed. Skipping JSON update for this property")
        BASE_PASSWORD = parsedJson.config.basePassword
    }

    if (STANDALONE_MODE) {
        println("Updating STANDALONE_MODE to " + STANDALONE_MODE)
        parsedJson.config.standaloneMode = STANDALONE_MODE
    } else {
        println("STANDALONE_MODE not changed. Skipping JSON update for this property")
        STANDALONE_MODE = parsedJson.config.standaloneMode
    }

    if (ALLOW_WORKLOADS_ON_KUBERNETES_MASTER) {
        println("Updating ALLOW_WORKLOADS_ON_KUBERNETES_MASTER to " + ALLOW_WORKLOADS_ON_KUBERNETES_MASTER)
        parsedJson.config.allowWorkloadsOnMaster = ALLOW_WORKLOADS_ON_KUBERNETES_MASTER
    } else {
        println("ALLOW_WORKLOADS_ON_KUBERNETES_MASTER not changed. Skipping JSON update for this property")
        ALLOW_WORKLOADS_ON_KUBERNETES_MASTER = parsedJson.config.allowWorkloadsOnMaster
    }

    def local_storage_num_one_gb = parsedJson.config.local_volumes.one_gb
    int number1GbVolumes = storageParameterElements[0].toInteger()
    if (local_storage_num_one_gb.toInteger() != number1GbVolumes && number1GbVolumes != "" && number1GbVolumes) {
        parsedJson.config.local_volumes.one_gb = number1GbVolumes
    }

    def local_storage_num_five_gb = parsedJson.config.local_volumes.five_gb
    int number5GbVolumes = storageParameterElements[1].toInteger()
    if (local_storage_num_five_gb.toInteger() != number5GbVolumes && number5GbVolumes != "" && number5GbVolumes) {
        parsedJson.config.local_volumes.five_gb = number1GbVolumes
    }

    def local_storage_num_ten_gb = parsedJson.config.local_volumes.ten_gb
    int number10GbVolumes = storageParameterElements[2].toInteger()
    if (local_storage_num_ten_gb.toInteger() != number10GbVolumes && number10GbVolumes != "" && number10GbVolumes) {
        parsedJson.config.local_volumes.ten_gb = number10GbVolumes
    }

    def local_storage_num_thirty_gb = parsedJson.config.local_volumes.thirty_gb
    int number30GbVolumes = storageParameterElements[3].toInteger()
    if (local_storage_num_thirty_gb.toInteger() != number30GbVolumes && number30GbVolumes != "" && number30GbVolumes) {
        parsedJson.config.local_volumes.thirty_gb = number30GbVolumes
    }

    def local_storage_num_fifty_gb = parsedJson.config.local_volumes.fifty_gb
    int number50GbVolumes = storageParameterElements[4].toInteger()
    if (local_storage_num_fifty_gb.toInteger() != number50GbVolumes && number50GbVolumes != "" && number50GbVolumes) {
        parsedJson.config.local_volumes.fifty_gb = number50GbVolumes
    }

    def OLD_NETWORK_STORAGE_OPTIONS = parsedJson.config.glusterFsDiskSize
    int NETWORK_STORAGE_OPTIONS = storageParameterElements[5].toInteger()
    if (OLD_NETWORK_STORAGE_OPTIONS != NETWORK_STORAGE_OPTIONS && NETWORK_STORAGE_OPTIONS != "" && NETWORK_STORAGE_OPTIONS) {
        parsedJson.config.glusterFsDiskSize = NETWORK_STORAGE_OPTIONS
    }

    println("DEBUG 1: BASE_USER (${BASE_USER}) JSON after update: ${parsedJson.config.baseUser}")
    println("DEBUG 1: BASE_PASSWORD (${BASE_PASSWORD}) JSON after update: ${parsedJson.config.basePassword}")

    updatedJson = new JsonBuilder(parsedJson).toPrettyString()

    println("DEBUG 2: BASE_USER (${BASE_USER}) JSON after update: ${parsedJson.config.baseUser}")
    println("DEBUG 2: BASE_PASSWORD (${BASE_PASSWORD}) JSON after update: ${parsedJson.config.basePassword}")

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
    println("NUMBER_OF_KX_MAIN_NODES: ${NUMBER_OF_KX_MAIN_NODES}")
    println("NETWORK_STORAGE_OPTIONS: ${NETWORK_STORAGE_OPTIONS}")
    println("STORAGE_PARAMETERS: ${STORAGE_PARAMETERS}")

    println("Bottom of update JSON groovy")
} catch(e) {
    println("Something went wrong in the GROOVY block (profile_json_update.groovy): ${e}")
}

try {
    // language=HTML
    def HTML = """
    <body>
    </body>
    """
    return HTML
} catch (e) {
    println("Something went wrong in the HTML return block (profile_json_update.groovy): ${e}")
}
