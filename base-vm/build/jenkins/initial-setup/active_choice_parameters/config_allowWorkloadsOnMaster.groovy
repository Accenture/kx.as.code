import groovy.json.JsonSlurper

def allowWorkloadsOnMaster
def infoText
def opacity
def cursor
def cssClass

try {
    println("Testing allowWorkloadsOnMaster 1")

    if (STANDALONE_MODE != "true") {
        println("IF -> STANDALONE_MODE: ${STANDALONE_MODE}")
        def jsonFilePath = PROFILE
        def inputFile = new File(jsonFilePath)
        def parsedJson = new JsonSlurper().parse(inputFile)
        allowWorkloadsOnMaster = parsedJson.config.allowWorkloadsOnMaster
        opacity = "0.7"
        cursor = "pointer"
        cssClass = "checkbox-slider round"
    } else {
        println("ELSE -> STANDALONE_MODE: ${STANDALONE_MODE}")
        allowWorkloadsOnMaster = true
        opacity = "0.1"
        cursor = "not-allowed"
        cssClass = "checkbox-slider-checked-disabled round"
    }

    println("Testing allowWorkloadsOnMaster 2")

    infoText = "Determines the number of KX-Main nodes that will be provisioned in the cluster"
} catch(e) {
    println "Something went wrong in the GROOVY block (config_allowWorkloadsOnMaster): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <body>
    <div class="outerWrapper" id="workloads-on-master-div" style="display: block">
    <div class="wrapper">
        <span class="span-toggle-text">Allow Workloads on Kubernetes Master</span><label for="workloads_on_master_checkbox" class="checkbox-switch">
        <input type="checkbox" onclick="if (${STANDALONE_MODE} !== true){ updateCheckbox(this, 'workloads_on_master_checkbox', ${STANDALONE_MODE})}" id="workloads_on_master_checkbox" name="value" value="${allowWorkloadsOnMaster}" checked="${allowWorkloadsOnMaster}">
        <span class="${cssClass}" style="opacity: ${opacity}; cursor: ${cursor}"></span>
    </label><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${infoText}"></span>
    </div>
    </div>
    <style scoped="scoped" onload="updateCheckbox(${allowWorkloadsOnMaster}, 'workloads_on_master_checkbox', ${STANDALONE_MODE});">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (config_allowWorkloadsOnMaster): ${e}"
}
