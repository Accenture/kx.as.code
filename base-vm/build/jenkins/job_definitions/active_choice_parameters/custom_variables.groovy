import groovy.json.JsonSlurper

def parsedCustomVariables
def profileParentPath

try {

    File profilePath = new File(PROFILE.split(";")[0])
    profileParentPath = profilePath.getParentFile()

    File customVariablesJsonFile = new File("${profileParentPath}/customVariables.json")

    if ( customVariablesJsonFile.exists() ) {
        parsedCustomVariables = customVariablesJsonFile.text.replace("\n", "").replace("\r", "").replace(" ", "")
    }
} catch (e) {
    println("Something went wrong in the groovy custom variable block (custom_variables.groovy): ${e}")
}


try {

    // language=HTML
    def HTML = """
<body>
    <div id="custom-variables-div" style="display: none;">

    <h1>Custom Variables</h1>
    <div><span class="description-paragraph-span"><p>Here you can set key/value pairs that can be used by solutions when they are being installed. For example, you my want to set a branch name here, that can be used as input into a build process later on. The variables can be used to replace placeholders in static config files or bash scripts with <code>{{variable_key_name}}</code> and <code>\${variable_key_name}</code> respectively</p></span></div>
    <br><br>
    <div class="custom-variables-table">
      <div class="custom-variable-header">
        <div class="custom-variable-cell">
            Key<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
        <div class="custom-variable-cell">
            Value<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
      </div>
      <div class="custom-variable-rowGroup">
        <div class="custom-variable-row">
            <div class="custom-variable-cell">
                <span class="input-box-span">
                    <input class="input-box custom-variable-input-box" id="custom-variable-key" onkeyup="nospaces(this);" type="text" value="">
                </span>
            </div>
            <div class="custom-variable-cell">
                <span class="input-box-span">
                    <input class="input-box custom-variable-input-box" id="custom-variable-value" type="text"  value="">
                </span>
            </div>
            <div class="custom-variable-image-cell">
               <img src="/userContent/icons/table-row-plus-after.svg" title='add custom variable' alt="add custom variable" onclick='addCustomVariableToTable();'>
            </div>
            </div>
        </div>
    </div>

    <br><br>
    <div class="custom-variable-table-container" id="div-custom-variable-table-container">
    <div class="custom-variable-table">
      <div class="custom-variable-header">
        <div class="custom-variable-cell">
            Key<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
        <div class="custom-variable-cell">
            Value<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
        <div class="custom-variable-image-cell">
        </div>
      </div>
      <div class="custom-variable-rowGroup" id='custom-variable-row-group'>
      </div>
    </div>
    </div>
</div>
</body>

<input type="hidden" id="concatenated-custom-variables-list" name="value" value="" >
<input type="hidden" id="customVariablesJson" value='${parsedCustomVariables}' >
<style scoped="scoped" onload="buildInitialCustomVariablesTableFromJson(document.getElementById('customVariablesJson').value);">   </style>
"""
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (custom_variables.groovy): ${e}"
}