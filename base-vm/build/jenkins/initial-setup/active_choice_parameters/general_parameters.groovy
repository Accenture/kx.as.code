import groovy.json.JsonSlurper

def infoTextBaseDomain
def infoTextBaseUser
def infoTextEnvironmentPrefix
def infoTextBasePassword
def config_baseDomain
def config_environmentPrefix
def config_baseUser
def config_basePassword
def generalParamsExtendedDescription

println("DEBUG Missing Var: ${PROFILE}")

try {
    def jsonFilePath = PROFILE
    def inputFile = new File(jsonFilePath)
    parsedJson = new JsonSlurper().parse(inputFile)
} catch(e) {
    println "Something went wrong in the GROOVY block (general_parameters.groovy): ${e}"
}

try {
    infoTextBaseDomain = "<p class='info-text-header'>[do‧ma‧in] /d̪oˈmaɪn/</p><p class='info-text-body'>This describes the domain name that all deployed services will be reachable by. Default is &quot;kx-as-code.local&quot;</p>"
    infoTextBaseUser = "<p class='info-text-header'>[us‧er] /ˈjuːzə/</p><p class='info-text-body'>The initial admin user for the base workstation. Default is &quot;kx.hero&quot;"
    infoTextEnvironmentPrefix = "<p class='info-text-header'>[team] /tiːm/</p><p class='info-text-body'>The additional sub-domain prepended to the base domain. This ensures separation where there are multiple deployments"
    infoTextBasePassword = "<p class='info-text-header'>[pass‧word] /pæswɜːɹd/</p><p class='info-text-body'>The initial password for the base workstation. Default is &quot;L3arnandshare&quot;"

    config_baseDomain = parsedJson.config.baseDomain
    config_environmentPrefix = parsedJson.config.environmentPrefix
    config_baseUser = parsedJson.config.baseUser
    config_basePassword = parsedJson.config.basePassword

    generalParamsExtendedDescription = "KX-Worker nodes are optional. On a local machine with lower amount of resources (equal to or below 16GB ram), a singe node standalone KX.AS.CODE deployment is advisable. In this case, just set the number of KX-Workers to 0. The 'allow workloads on master' toggle must be set to on in this case, else it will not be possible to deploy any workloads beyond the core tools and services. For VM hosts with higher available resources >16GB ram, feel free to install a full blown cluster and add some worker nodes!"

} catch(e) {
    println("Something went wrong in the GROOVY block (general_parameters.groovy): ${e}")
}

def infoTextStandaloneMode
def infoTextWorkloadOnMaster
def standaloneModeExtendedDescription


/*println("PREREQUISITES_CHECK: *${PREREQUISITES_CHECK}*")

if (PREREQUISITES_CHECK != "failed") {
    try {
        if (PREREQUISITES_CHECK == "standalone") {
            standaloneMode = true
            cssClass = "checkbox-slider-checked-disabled round"
            println("Inside standalone = true...")
        } else {
            println("Inside standalone = false...")
            standaloneMode = parsedJson.config.standaloneMode
            allowWorkloadsOnMaster = parsedJson.config.allowWorkloadsOnMaster
            cssClass = "checkbox-slider round"
        }

    } catch (e) {
        println("Something went wrong in the GROOVY block (general_parameters.groovy): ${e}")
    }
*/

infoTextStandaloneMode = "Determines whether to run with a single main node or node. This will automatically set KX-Workers to zero, Kx-Main to 1, and ensure allow-workloads on master is set to 1"
infoTextWorkloadOnMaster = "Determines the number of KX-Main nodes that will be provisioned in the cluster"
standaloneModeExtendedDescription = "If you set standalone mode to true, then the number of main nodes is automatically set to 1, and worked nodes set to 0 and disabled completely. If you have only build the main Vagrant box so far, then standalone mode will be enabled automatically"

try {
    // language=HTML
    def HTML = """
    <div id="general-parameters-div" style="display: none;">
        <h2>General Profile Parameters</h2>
        <span class="description-paragraph-span"><p>${generalParamsExtendedDescription}</p></span>
        <div class="input-box-div">
            <span class="input-box-span">
                <label for="general-param-base-domain" class="input-box-label">Base Domain</label>
                <input class="input-box" id="general-param-base-domain" type="text" placeholder="${config_baseDomain}" onchange="updateConcatenatedGeneralParamsReturnVariable();">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextBaseDomain}</span></span></div>
            </span>
            <span class="input-box-span">
                <label for="general-param-username" class="input-box-label">Username</label>
                <input class="input-box" id="general-param-username" type="text" placeholder="${config_baseUser}" onchange="updateConcatenatedGeneralParamsReturnVariable();">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextBaseUser}</span></span></div>
            </span>
        </div>
        <div class="input-box-div">
            <span class="input-box-span">
                <label for="general-param-team-name" class="input-box-label">Team Name</label>
                <input class="input-box" id="general-param-team-name" type="text" placeholder="${config_environmentPrefix}" onchange="updateConcatenatedGeneralParamsReturnVariable();">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextEnvironmentPrefix}</span></span></div>
            </span>
            <span class="input-box-span">
                <label for="general-param-password" class="input-box-label">Password</label>
                <input class="input-box" id="general-param-password" type="password" placeholder="${config_basePassword}" onchange="updateConcatenatedGeneralParamsReturnVariable();">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextBasePassword}</span></span></div>
            </span>
        </div>
    </div>  
    
    <div id="standalone-toggle-div" style="display: none;">
        <h2>Standalone or Cluster Mode</h2>
        <p>
        ${standaloneModeExtendedDescription}
        </p>
        <div class="wrapper">
            <span class="span-toggle-text">Enable Standalone Mode</span><label for="general-param-standalone-mode-toggle" class="checkbox-switch">
            <input type="checkbox" onclick="updateCheckbox(this.id); updateConcatenatedGeneralParamsReturnVariable();" id="general-param-standalone-mode-toggle" value="" checked=>
            <span id="general-param-standalone-mode-toggle-span" class=""></span>
        </label><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${infoTextStandaloneMode}"></span>
        </div>
        <style scoped="scoped" onload="updateCheckbox('general-param-standalone-mode-toggle');">   </style>
    </div>

    <div class="outerWrapper" id="workloads-on-master-div" style="display: none">
        <div class="wrapper">
            <span class="span-toggle-text">Allow Workloads on Kubernetes Master</span><label for="general-param-workloads-on-master-toggle" class="checkbox-switch">
            <input type="checkbox" onclick="updateCheckbox(this.id); updateConcatenatedGeneralParamsReturnVariable();" id="general-param-workloads-on-master-toggle" value="" checked="">
            <span id="general-param-workloads-on-master-toggle-span" class=""></span>
        </label><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${infoTextWorkloadOnMaster}"></span>
        </div>
        <style scoped="scoped" onload="updateCheckbox('general-param-workloads-on-master-toggle');">   </style>
    </div>

    <input type="hidden" id="general-param-standalone-mode-toggle-name-value" name="general-param-standalone-mode-toggle-name-value" value="">
    <input type="hidden" id="general-param-workloads-on-master-toggle-name-value" name="general-param-workloads-on-master-toggle-name-value" value="">
    <input type="hidden" id="concatenated-general-params" name="value" value="" >
    <style scoped="scoped" onload="updateConcatenatedGeneralParamsReturnVariable();">   </style>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (general_parameters.groovy): ${e}"
}
