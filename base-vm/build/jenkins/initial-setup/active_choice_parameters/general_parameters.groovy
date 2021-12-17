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
    println "Something went wrong in the GROOVY block (config_vm_properties_main_node_count): ${e}"
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
    println("Something went wrong in the GROOVY block (config_general_parameters): ${e}")
}

def standaloneMode
def allowWorkloadsOnMaster
def infoTextStandaloneMode
def infoTextWorkloadOnMaster
def standaloneModeExtendedDescription
def cssClass

println("PREREQUISITES_CHECK: *${PREREQUISITES_CHECK}*")

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

        infoTextStandaloneMode = "Determines whether to run with a single main node or node. This will automatically set KX-Workers to zero, Kx-Main to 1, and ensure allow-workloads on master is set to 1"
        infoTextWorkloadOnMaster = "Determines the number of KX-Main nodes that will be provisioned in the cluster"
        standaloneModeExtendedDescription = "If you set standalone mode to true, then the number of main nodes is automatically set to 1, and worked nodes set to 0 and disabled completely. If you have only build the main Vagrant box so far, then standalone mode will be enabled automatically"
    } catch (e) {
        println("Something went wrong in the GROOVY block (toggle_standalone_mode): ${e}")
    }

    try {
        // language=HTML
        def HTML = """
    <div id="general-parameters-div" style="display: none;">
        <h2>General Profile Parameters</h2>
        <span class="description-paragraph-span"><p>${generalParamsExtendedDescription}</p></span>
        <div class="input-box-div">
            <span class="input-box-span">
                <label for="base-domain" class="input-box-label">Base Domain</label>
                <input class="input-box" id="base-domain" type="text" placeholder="${config_baseDomain}" onchange="updateConcatenatedReturnVariable()">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextBaseDomain}</span></span></div>
            </span>
            <span class="input-box-span">
                <label for="username" class="input-box-label">Username</label>
                <input class="input-box" id="username" type="text" placeholder="${config_baseUser}" onchange="updateConcatenatedReturnVariable()">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextBaseUser}</span></span></div>
            </span>
        </div>
        <div class="input-box-div">
            <span class="input-box-span">
                <label for="team-name" class="input-box-label">Team Name</label>
                <input class="input-box" id="team-name" type="text" placeholder="${config_environmentPrefix}" onchange="updateConcatenatedReturnVariable()">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextEnvironmentPrefix}</span></span></div>
            </span>
            <span class="input-box-span">
                <label for="password" class="input-box-label">Password</label>
                <input class="input-box" id="password" type="password" placeholder="${config_basePassword}" onchange="updateConcatenatedReturnVariable()">
                <div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">${infoTextBasePassword}</span></span></div>
            </span>
        </div>
    </div>
    <input type="hidden" id="concatenated-general-params" name="value" value="" >
    
    
    
    <div id="standalone-toggle-div" style="display: none;">
        <h2>Standalone or Cluster Mode</h2>
        <p>
        ${standaloneModeExtendedDescription}
        </p>
        <div class="wrapper">
            <span class="span-toggle-text">Enable Standalone Mode</span><label for="standalone-mode-toggle" class="checkbox-switch">
            <input type="checkbox" onclick="updateCheckbox(this.id)" id="standalone-mode-toggle" value="${standaloneMode}" checked=${standaloneMode}>
            <span class="${cssClass}" id="standalone-mode-toggle-span"></span>
        </label><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${infoTextStandaloneMode}"></span>
        </div>
        <style scoped="scoped" onload="updateCheckbox('standalone-mode-toggle');">   </style>
    </div>

    <div class="outerWrapper" id="workloads-on-master-div" style="display: none">
        <div class="wrapper">
            <span class="span-toggle-text">Allow Workloads on Kubernetes Master</span><label for="workloads-on-master-toggle" class="checkbox-switch">
            <input type="checkbox" onclick="updateCheckbox(this.id);" id="workloads-on-master-toggle" value="${allowWorkloadsOnMaster}" checked="${allowWorkloadsOnMaster}">
            <span id="workloads-on-master-toggle-span" class="${cssClass}"></span>
        </label><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${infoTextWorkloadOnMaster}"></span>
        </div>
    </div>

    <input type="hidden" id="standalone-mode-toggle-name-value" name="value" value="${standaloneMode}">
    <style scoped="scoped" onload="updateCheckbox('workloads-on-master-toggle');">   </style>
    <input type="hidden" id="workloads-on-master-toggle-name-value" name="value" value="${allowWorkloadsOnMaster}">
 
    """
    return HTML
    } catch (e) {
        println "Something went wrong in the HTML return block (config_general_parameters): ${e}"
    }
}