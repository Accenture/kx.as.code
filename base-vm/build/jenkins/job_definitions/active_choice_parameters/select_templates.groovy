import groovy.json.JsonSlurper
import java.nio.file.*

def componentDirectory
def metadataInputFilePath
def category
def component
def metadataInputFile
def metadataJson
def shortcutIcon
def shortcutText
def description
def jsonFilePath
def inputFile
def parsedJson
def template_items = []
def templateComponentsArray = []
def templateDefinitionsArray = []
def template_id
def template_name
def template_description
def template_path
def selectedTemplates
def profileParentPath = ""
def template_paths = []
def existingTemplatesInSelectedProfile = ""
def profile_template_paths = []
def extendedDescription = "Here you can select an application group from a list of available templates. An application group is a set of applications that are commonly deployed together, and in many cases they will also be integrated within KX.AS.CODE."

try {

    //File profilePath = new File("C:/Git/kx.as.code_test/base-vm/build/jenkins/jenkins_shared_workspace/kx.as.code/profiles/vagrant-virtualbox/profile-config.json")
    File profilePath = new File(PROFILE.split(";")[0])
    parsedJson = new JsonSlurper().parse(profilePath)
    selectedTemplates = parsedJson.config.selectedTemplates
    println("Received selectedTemplates from profile JSON: ${selectedTemplates}")

    profileParentPath = profilePath.getParentFile().toString()
    new File(profileParentPath).eachFileMatch(~/^aq.*.json$/) { profile_template_paths << it.path }

    for (int i = 0; i < profile_template_paths.size(); i++) {

        jsonFilePath = profile_template_paths[i];
        inputFile = new File(jsonFilePath);
        parsedJson = new JsonSlurper().parse(inputFile);
        if ( existingTemplatesInSelectedProfile == "" ) {
            existingTemplatesInSelectedProfile = parsedJson.title
        } else {
            existingTemplatesInSelectedProfile = existingTemplatesInSelectedProfile +  "," + parsedJson.title
        }
    }
    new File('jenkins_shared_workspace/kx.as.code/templates/').eachFileMatch(~/^aq.*.json$/) { template_paths << it.path }
    template_paths_csv = template_paths.join(",")
    template_paths_csv = template_paths_csv.replaceAll("\\\\", "/")

    for (int i = 0; i < template_paths.size(); i++) {

        jsonFilePath = template_paths[i]
        inputFile = new File(jsonFilePath)
        parsedJson = new JsonSlurper().parse(inputFile)

        template_id = i
        template_items = parsedJson.action_queues.install
        template_name = parsedJson.title
        template_description = parsedJson.description
        template_path = jsonFilePath.replaceAll("\\\\", "/")

        templateDefinitionsArray.add('{ "template_id":' + template_id + ',' + '"template_name":' + '"' + template_name + '",' + '"template_description":' + '"' + template_description + '",' + '"template_path":' + '"' + template_path + '"}')

        for (int j = 0; j < template_items.size(); j++) {
            category = parsedJson.action_queues.install[j].install_folder
            component = parsedJson.action_queues.install[j].name
            componentDirectory = "jenkins_shared_workspace/kx.as.code/auto-setup/${category}/${component}"
            metadataInputFilePath = "${componentDirectory}/metadata.json"
            metadataInputFile = new File(metadataInputFilePath)
            metadataJson = new JsonSlurper().parse(metadataInputFile)
            description = metadataJson.Description
            shortcutText = metadataJson.shortcut_text
            shortcutIcon = metadataJson.shortcut_icon
            try {
                //Files.copy(jenkins_shared_workspace/kx.as.code/auto-setup/${category}/${component}/${shortcutIcon}, jenkins_home/userContent/icons/${shortcutIcon})
                def fileEx = new File("jenkins_shared_workspace/kx.as.code/auto-setup/${category}/${component}/${shortcutIcon}")
                def fileDest = new File("jenkins_home/userContent/icons/${shortcutIcon}")
                def fileExPath = fileEx.toPath()
                def fileDestPath = fileDest.toPath()
                Files.copy(fileExPath, fileDestPath, StandardCopyOption.COPY_ATTRIBUTES)
            } catch (e) {
                println e
            }
            templateComponentsArray.add('{' + '"template_id":' + template_id + ',' + '"shortcutText":' + '"' + shortcutText + '",' + '"shortcutIcon":' + '"' + "${shortcutIcon}" + '",' + '"description":' + '"' + description + '",' + '"category":' + '"' + category + '",' + '"component":' + '"' + component + '"}')
        }
    }
} catch(e) {
    println "Something went wrong in the GROOVY block (select_templates.groovy): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <body>
    <div id="templates-div" style="display: none;">
        <h1>Application Groups</h1>
        <div><span class="description-paragraph-span"><p>${extendedDescription}</p></span></div>
        <br>
        <label for="templates" class="input-box-label">Templates</label><select id="templates" class="templates-select capitalize" onchange="getTemplates(); populate_template_option_list(this.value);"></select></label>
        <span class='span-rounded-border'>
            <img id="button_remove_template" src='/userContent/icons/minus-box-multiple-outline.svg' class="build-action-icon" title="Remove Template" alt="Remove Template" onclick='removeTemplateFromProfile();' />
            <img id="button_add_template" src='/userContent/icons/plus-box-multiple-outline.svg' class="build-action-icon" title="Add Template" alt="Add Template" onclick='addTemplateToProfile();' />
        </span>
        <style scoped="scoped" onload="populate_template_option_list(); getTemplateComponents(-1);">   </style>
        <div style="display: flex">
            <span><div class="component-container" id="components-list"></div></span>
            <span>
                <div>
                    <span class="selected-component-container-title">Selected Application Groups</span>
                    <span class="selected-component-container" id="selected-components-list"/>
                </div>
            </span>
        </div>
    </div>
    </body>
    <input type="hidden" id="concatenated-templates-list" name="value" value="${selectedTemplates}" >
    <input type="hidden" id="profile-template-paths" value='${existingTemplatesInSelectedProfile}' >
    <input type="hidden" id="template-definitions-array" value='${templateDefinitionsArray}' >
    <input type="hidden" id="template-components-array" value='${templateComponentsArray}' >
    <style scoped="scoped" onload="selectTemplatesAlreadyExistingInProfile(document.getElementById('profile-template-paths').value);">   </style>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (select_templates.groovy): ${e}"
}
