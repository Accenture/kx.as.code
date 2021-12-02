import groovy.json.JsonSlurper

def allowWorkloadsOnMaster
def infoText
def cssClass

try {
    println("Testing allowWorkloadsOnMaster 1")
    if ( STANDALONE_MODE ) {
        if (STANDALONE_MODE != "true") {
            println("IF -> STANDALONE_MODE: ${STANDALONE_MODE}")
            cssClass = "checkbox-slider round"
        } else {
            println("ELSE -> STANDALONE_MODE: ${STANDALONE_MODE}")
            allowWorkloadsOnMaster = true
            cssClass = "checkbox-slider-checked-disabled round"
        }
    } else {
        cssClass = "checkbox-slider round"
        def jsonFilePath = PROFILE
        def inputFile = new File(jsonFilePath)
        def parsedJson = new JsonSlurper().parse(inputFile)
        allowWorkloadsOnMaster = parsedJson.config.allowWorkloadsOnMaster
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
        <div class="outerWrapper" id="workloads-on-master-div" style="display: none">
            <div class="wrapper">
                <span class="span-toggle-text">Allow Workloads on Kubernetes Master</span><label for="workloads-on-master-toggle" class="checkbox-switch">
                <input type="checkbox" onclick="updateCheckbox(this.id);" id="workloads-on-master-toggle" value="${allowWorkloadsOnMaster}" checked="${allowWorkloadsOnMaster}">
                <span id="workloads-on-master-toggle-span" class="${cssClass}"></span>
            </label><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${infoText}"></span>
            </div>
        </div>
        <style scoped="scoped" onload="updateCheckbox('workloads-on-master-toggle');">   </style>
        <input type="hidden" id="workloads-on-master-toggle-name-value" name="value" value="${allowWorkloadsOnMaster}">
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (config_allowWorkloadsOnMaster): ${e}"
}
