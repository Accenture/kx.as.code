import groovy.json.JsonSlurper

def infoTextBaseDomain
def infoTextBaseUser
def infoTextEnvironmentPrefix
def infoTextBasePassword
def config_baseDomain
def config_environmentPrefix
def config_baseUser
def config_basePassword
def extendedDescription

println("DEBUG Missing Var: ${PROFILE}")

try {
    infoTextBaseDomain = "<p class='info-text-header'>[do‧ma‧in] /d̪oˈmaɪn/</p><p class='info-text-body'>This describes the domain name that all deployed services will be reachable by. Default is &quot;kx-as-code.local&quot;</p>"
    infoTextBaseUser = "<p class='info-text-header'>[us‧er] /ˈjuːzə/</p><p class='info-text-body'>The initial admin user for the base workstation. Default is &quot;kx.hero&quot;"
    infoTextEnvironmentPrefix = "<p class='info-text-header'>[team] /tiːm/</p><p class='info-text-body'>The additional sub-domain prepended to the base domain. This ensures separation where there are multiple deployments"
    infoTextBasePassword = "<p class='info-text-header'>[pass‧word] /pæswɜːɹd/</p><p class='info-text-body'>The initial password for the base workstation. Default is &quot;L3arnandshare&quot;"

    def jsonFilePath = PROFILE

    def inputFile = new File(jsonFilePath)
    def parsedJson = new JsonSlurper().parse(inputFile)

    config_baseDomain = parsedJson.config.baseDomain
    config_environmentPrefix = parsedJson.config.environmentPrefix
    config_baseUser = parsedJson.config.baseUser
    config_basePassword = parsedJson.config.basePassword

    extendedDescription = "KX-Worker nodes are optional. On a local machine with lower amount of resources (equal to or below 16GB ram), a singe node standalone KX.AS.CODE deployment is advisable. In this case, just set the number of KX-Workers to 0. The 'allow workloads on master' toggle must be set to on in this case, else it will not be possible to deploy any workloads beyond the core tools and services. For VM hosts with higher available resources >16GB ram, feel free to install a full blown cluster and add some worker nodes!"

} catch(e) {
    println("Something went wrong in the GROOVY block (config_general_parameters): ${e}")
}

try {
    // language=HTML
    def HTML = """
    <div id="general-parameters-div" style="display: none;">
        <h2>General Profile Parameters</h2>
        <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
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
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (config_general_parameters): ${e}"
}
