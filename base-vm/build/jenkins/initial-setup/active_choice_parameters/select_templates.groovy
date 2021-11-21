import groovy.json.JsonSlurper
import groovy.json.JsonBuilder
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

try {
    template_paths = []
    new File('jenkins_shared_workspace/kx.as.code/templates/').eachFileMatch(~/^aq.*.json$/) { template_paths << it.path }

    template_paths_csv = template_paths.join(",")
    template_paths_csv = template_paths_csv.replaceAll("\\\\", "/")
    //println(template_paths_csv)

    for (int i = 0; i < template_paths.size(); i++) {

        jsonFilePath = template_paths[i]
        inputFile = new File(jsonFilePath)
        parsedJson = new JsonSlurper().parse(inputFile)

        template_id = i
        template_items = parsedJson.action_queues.install
        template_name = parsedJson.title
        template_description = parsedJson.description
        template_path = jsonFilePath.replaceAll("\\\\", "/")

        templateDefinitionsArray.add('[ "template_id":' + template_id + ',' + '"template_name":' + '"' + template_name + '",' + '"template_description":' + '"' + template_description + '",' + '"template_path":' + '"' + template_path + '"]')

        for (int j = 0; j < template_items.size(); j++) {
            category = parsedJson.action_queues.install[j].install_folder
            component = parsedJson.action_queues.install[j].name
            componentDirectory = "jenkins_shared_workspace/kx.as.code/auto-setup/${category}/${component}"
            metadataInputFilePath = "${componentDirectory}/metadata.json"
            //println(metadataInputFilePath)
            metadataInputFile = new File(metadataInputFilePath)
            metadataJson = new JsonSlurper().parse(metadataInputFile)
            description = metadataJson.Description
            shortcutText = metadataJson.shortcut_text
            shortcutIcon = metadataJson.shortcut_icon
            //println("/userContent/icons/${shortcutIcon}")
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
            templateComponentsArray.add('[' + '"template_id":' + template_id + ',' + '"shortcutText":' + '"' + shortcutText + '",' + '"shortcutIcon":' + '"' + "${shortcutIcon}" + '",' + '"description":' + '"' + description + '",' + '"category":' + '"' + category + '",' + '"component":' + '"' + component + '"]')
        }
    }

    //println(templateComponentsArray)
} catch(e) {
    println "Something went wrong in the GROOVY block (select_templates): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <head>
        <script>
            function getTemplates() {
                console.log("Inside getTemplates()");
                let templateDefinitionsArray='${templateDefinitionsArray}'.replaceAll('[', '{').replaceAll(']', '}').replaceAll('{{', '[{').replaceAll('}}', '}]');
                console.table(templateDefinitionsArray);
                let definitionsArray = JSON.parse(templateDefinitionsArray);
                console.table(definitionsArray);
                let templateId;
    
                try {
                    let selectedTemplate = document.getElementById("templates").value;
                    if ( selectedTemplate !== "-- Select Template --" ) {
                        console.log("Selected template: *" + selectedTemplate + "*");
                        let definitionArray = definitionsArray.find(template => template.template_name === selectedTemplate);
                        console.log("Found template definition id: " + definitionArray.template_id);
                        templateId = definitionArray.template_id;
                    } else {
                        templateId = -1;
                    }
                    getTemplateComponents(templateId);
                } catch(e){
                    console.log("Lookup failed");
                }
    
                return definitionsArray;
    
            }
    
            function getTemplateComponents(templateId) {
                let templateComponentsArray = [];
                let componentsArray = [];
                let componentItemInnerHTML
                document.getElementById('components-list').innerHTML = "";
                console.log("Inside getTemplateComponents(" + templateId + ")");
    
                if ( templateId === -1  || templateId === null || templateId === '' ) {
    
                    let shortcutIconPlaceholder = 'application-cog-outline.svg';
                    let categoryPlaceholder = 'Optional';
                    let shortcutTextPlaceholder = 'Templates';
                    let descriptionPlaceholder = 'Select from a pre-defined list of integrated application groups';
    
                    iDiv = document.createElement('div');
                    iDiv.id = "placeholder-template";
                    iDiv.className = 'component-item';
    
                    let componentItemInnerHTML = '<div class="component-outer-div">' +
                        '<div class="component-image-div">' +
                        '<img src="/userContent/icons/' + shortcutIconPlaceholder + '" width="60">' +
                        '</div>' +
                        '<div class="component-outer-text-div">' +
                        '<div class="component-category-div">' + categoryPlaceholder + '</div>' +
                        '<div class="component-title-div">' + shortcutTextPlaceholder + '</div>' +
                        '</div>' +
                        '</div>' +
                        '<div>' +
                        '   <span class="component-description-span">' + descriptionPlaceholder + '</span>' +
                        '</div>';
    
                    console.log(componentItemInnerHTML);
                    iDiv.innerHTML = componentItemInnerHTML;
                    document.getElementById('components-list').appendChild(iDiv);
    
                } else {
    
                    templateComponentsArray = '${templateComponentsArray}'.replaceAll('[', '{').replaceAll(']', '}').replaceAll('{{', '[{').replaceAll('}}', '}]');
                    console.table(templateComponentsArray);
                    componentsArray = JSON.parse(templateComponentsArray);
                    console.table(componentsArray);
                    let shortcutIcon
                    try {
                        let componentArray = componentsArray.findAll(templateComponent => templateComponent.template_id === templateId);
                        console.log("returned array size: " + componentArray.size());
                        for (let i = 0; i < componentArray.size(); i++) {
                            console.log("Found template components - shortcutText[" + i + "]: " + componentArray[i].shortcutText);
                            console.log("Found template components - category [" + i + "]: " + componentArray[i].category);
                            console.log("Found template components - description [" + i + "]: " + componentArray[i].description);
                            console.log("Found template components - shortcutIcon [" + i + "]: " + componentArray[i].shortcutIcon);
                            console.log("Found template components - component [" + i + "]: " + componentArray[i].component);
    
                            iDiv = document.createElement('div');
                            iDiv.id = componentArray[i].component;
                            iDiv.className = 'component-item';
    
                            if (componentArray[i].shortcutText !== "null" && componentArray[i].shortcutIcon !== "null") {
    
                                if (componentArray[i].shortcutIcon === "null") {
                                    shortcutIcon = 'application-cog-outline.svg';
                                } else {
                                    shortcutIcon = componentArray[i].shortcutIcon;
                                }
    
                                let componentItemInnerHTML = '<div class="component-outer-div">' +
                                    '<div class="component-image-div">' +
                                    '<img src="/userContent/icons/' + shortcutIcon + '" width="60">' +
                                    '</div>' +
                                    '<div class="component-outer-text-div">' +
                                    '<div class="component-category-div">' + componentArray[i].category.replace('_', ' ') + '</div>' +
                                    '<div class="component-title-div">' + componentArray[i].shortcutText + '</div>' +
                                    '</div>' +
                                    '</div>' +
                                    '<div>' +
                                    '   <span class="component-description-span">' + componentArray[i].description + '</span>' +
                                    '</div>';
                                console.log(componentItemInnerHTML);
                                iDiv.innerHTML = componentItemInnerHTML;
                                document.getElementById('components-list').appendChild(iDiv);
                            }
                        }
                    } catch (e) {
                        console.log("Lookup failed" + e)
                    }
                }
    
            }
    
            function populate_template_option_list() {
                console.log("populate_template_option_list()");
                let templates = getTemplates();
                console.log("templates.length: " + templates.length);
                document.getElementById("templates").options[0] = new Option("-- Select Template --", "-- Select Template --");
                for ( let i = 0; i < templates.length; i++ ) {
                    let templateName = templates[i].template_name;
                    console.log("Adding template to options: " + templateName + i);
                    document.getElementById("templates").options[i+1] = new Option(templateName, templateName);
                }
            }
    
            function hideDiv() {
                document.getElementById("templates-div").style.display = "none";
            }
        </script>
        <style>
    
            .capitalize {
                text-transform: capitalize;
            }
    
            .templates-select {
                -moz-appearance: none;
                -webkit-appearance: none;
                appearance: none;
                padding-left: 10px;
                cursor: pointer;
                border: none;
                width: 200px;
                height: 40px;
                border-top-right-radius: 5px;
                border-bottom-right-radius: 5px;
                background-image: url("/userContent/icons/chevron-down.svg");
                background-repeat: no-repeat;
                background-position: right;
                background-color: #efefef;
                outline: none;
                border: none;
                box-shadow: none;
            }
    
            select {
                height: 20px;
                -webkit-border-radius: 0;
                border: 0;
                outline: 1px solid #ccc;
                outline-offset: -1px;
            }
    
            .templates-select select {
                outline: none;
                border: none;
                box-shadow: none;
            }
    
            .templates-select:focus {
                outline: none;
                border: none;
                box-shadow: none;
            }
    
            .component-container {
                display: flex;
                padding: 10px;
                align-items: stretch;
                justify-content : flex-start;
                flex-wrap: wrap;
                flex-direction: row;
                max-width: 850px;
                gap: 10px 10px;
                row-gap: 10px;
                column-gap: 10px;
                background: rgba(117,0,192,0.05);
                display: -webkit-box;
                display: -moz-box;
                display: -ms-flexbox;
                display: -webkit-flex;
            }
    
            .component-item {
                display: block;
                padding: 20px;
                align-items: center;
                background: #FFFFFF;
                width: 200px;
                height: 200px;
            }
    
            .component-outer-div {
                display:inline-block;
            }
    
            .component-image-div {
                padding: 5px;
                padding-top: 10px;
                width: 40%;
                float: left;
            }
    
            .component-outer-text-div {
                padding: 5px;
                text-transform: capitalize;
                width:60%;
                height: 100px;
                float: right;
            }
    
            .component-category-div {
                text-transform: capitalize;
                padding-left: 15px;
                padding-top: 10px;
                color: #7500c0;
            }
    
            .component-title-div {
                padding-left: 15px;
            }
    
            .component-description-span {
                padding-left: 5px;
                width:100%;
                box-decoration-break: clone;
                -webkit-box-decoration-break: clone;
            }
    
        </style>
    </head>
    <body>
    <div id="templates-div" style="display: inline-block;">
        <label for="templates" class="input-box-label">Templates</label><select id="templates" class="templates-select capitalize" onchange="getTemplates();"></select></label>
        <style scoped="scoped" onload="populate_template_option_list(); getTemplateComponents(-1);">   </style>
        <div class="component-container" id="components-list">
        </div>
    </div>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (select_templates): ${e}"
}