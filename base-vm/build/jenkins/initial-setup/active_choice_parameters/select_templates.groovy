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
    
    def extendedDescription = "Here you can select an application group from a list of available templates. An application group is a set of applications that are commonly deployed together, and in many cases they will also be integrated within KX.AS.CODE."
    
    try {
        template_paths = []
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
        println "Something went wrong in the GROOVY block (select_templates.groovy): ${e}"
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
                        selectedTemplate = selectedTemplate.replaceAll("*","");
                        console.log("getTemplates() --> before if " + selectedTemplate)
                        if ( selectedTemplate !== "-- Select Templates --" ) {
                            console.log("getTemplates() --> Selected template: " + selectedTemplate);
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
                    let componentItemInnerHTML;
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
    
                        componentItemInnerHTML = '<div class="component-outer-div">' +
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
    
                                    componentItemInnerHTML = '<div class="component-outer-div">' +
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
    
                function populate_template_option_list(selectedTemplate) {
                    let templateNameOptionDisplayText;
                    let templateNameOption;
                    let selectedIndex = 0;
                    console.log("(1) populate_template_option_list(selectedTemplate) -> " + selectedTemplate);
                    selectedTemplate = (typeof selectedTemplate === 'undefined') ? '-- Select Templates --' : selectedTemplate;
                    console.log("(2) populate_template_option_list(selectedTemplate) -> " + selectedTemplate);
                    console.log("populate_template_option_list(" + selectedTemplate + ")");
                    let selectedTemplateList = document.getElementById("concatenated-templates-list").value.split(';');
                    let templates = getTemplates();
                    console.log("templates.length: " + templates.length);
                    document.getElementById("templates").options[0] = new Option("-- Select Templates --", "-- Select Templates --");
                    for ( let i = 0; i < templates.length; i++ ) {
                        if ( selectedTemplateList.includes(templates[i].template_name) === true ) { 
                            templateNameOptionDisplayText = templates[i].template_name + " \\u2606";
                            if ( selectedTemplate === templates[i].template_name ) {
                                selectedIndex = i+1;
                            }
                            console.log("templateNameOptionDisplayText: " + templateNameOptionDisplayText);
                        } else {
                            templateNameOptionDisplayText = templates[i].template_name;
                        }
                        templateNameOption = templates[i].template_name;
                        console.log("Adding template to options: " + templateNameOption + " - " + i);
                        document.getElementById("templates").options[i+1] = new Option(templateNameOptionDisplayText, templateNameOption);
                    }
                    console.log("(3) populate_template_option_list(selectedTemplate) -> " + selectedTemplate);
                    if ( selectedTemplate !== '-- Select Templates --') {
                        let e = document.getElementById("templates");
                        console.log("selectedIndex: " + selectedIndex + " e.options[selectedIndex].value: " + e.options[selectedIndex].value + " e.options[selectedIndex].text: " + e.options[selectedIndex].text);
                        if ( e.options[selectedIndex].value === selectedTemplate ) {
                            console.log("Setting options list to " + selectedTemplate);
                            document.getElementById("templates").value = selectedTemplate;
                            document.getElementById('button_remove_template').setAttribute( "onClick", "removeTemplateFromProfile();" );
                            document.getElementById('button_add_template').setAttribute( "onClick", "" );
                            document.getElementById('button_remove_template').style.opacity = "1.0";
                            document.getElementById('button_add_template').style.opacity = "0.2";
                            document.getElementById('button_remove_template').style.cursor = "pointer";
                            document.getElementById('button_add_template').style.cursor = "not-allowed";                        
                        } else {
                            console.log("Setting options list to " + selectedTemplate);
                            document.getElementById("templates").value = selectedTemplate;
                            document.getElementById('button_remove_template').setAttribute( "onClick", "" );
                            document.getElementById('button_add_template').setAttribute( "onClick", "addTemplateToProfile();" );
                            document.getElementById('button_remove_template').style.opacity = "0.2";
                            document.getElementById('button_add_template').style.opacity = "1.0";
                            document.getElementById('button_remove_template').style.cursor = "not-allowed";
                            document.getElementById('button_add_template').style.cursor = "pointer";
                        }
                    } else {
                        console.log("Setting options list to default placeholder --> document.getElementById(templates).options[0]: "  + document.getElementById("templates").options[0].value);
                        document.getElementById("templates").value = document.getElementById("templates").options[0].value;
                        document.getElementById('button_remove_template').setAttribute( "onClick", "" );
                        document.getElementById('button_add_template').setAttribute( "onClick", "" );
                        document.getElementById('button_remove_template').style.opacity = "0.2";
                        document.getElementById('button_add_template').style.opacity = "0.2";
                        document.getElementById('button_remove_template').style.cursor = "not-allowed";
                        document.getElementById('button_add_template').style.cursor = "not-allowed";
                    }
                }
    
                function addTemplateToProfile() {
                    let selectedTemplate = document.getElementById("templates").value;
                    console.log("Adding template to install: " + selectedTemplate);
                    let selectedTemplateList = document.getElementById("concatenated-templates-list").value.split(';');
                    console.log("DEBUG - selectedTemplateList: " + selectedTemplateList);
                    selectedTemplate = selectedTemplate.replaceAll("*","");
                    if ( selectedTemplateList.includes(selectedTemplate) === true || selectedTemplateList.includes(selectedTemplate + "*") === true ) {    
                        console.log("Template already included in array");
                    } else {            
                        selectedTemplateList.push(selectedTemplate);
                        console.log("selectedTemplateList: " + selectedTemplateList);
                        document.getElementById("concatenated-templates-list").value = selectedTemplateList.toString().replaceAll(',', ';').replace(/^;/,'');
                        populate_template_option_list(selectedTemplate);
                        let parentId = document.getElementById("concatenated-templates-list").parentNode.id;
                        jQuery('#' + parentId).trigger('change');
                    }
                }
                  function removeTemplateFromProfile() {
                    let selectedTemplate = document.getElementById("templates").value;
                    selectedTemplate = selectedTemplate.replaceAll("*","");
                    console.log("Removing template from install: " + selectedTemplate);
                    let selectedTemplateList = document.getElementById("concatenated-templates-list").value.split(';');
                    console.log("selectedTemplateList: " + selectedTemplateList);
                    if ( selectedTemplateList.includes(selectedTemplate) === true || selectedTemplateList.includes(selectedTemplate + "*") === true ) { 
                        selectedTemplateList = arrayRemove(selectedTemplateList, selectedTemplate)
                        console.log("selectedTemplateList: " + selectedTemplateList); 
                        document.getElementById("concatenated-templates-list").value = selectedTemplateList.toString();
                        console.log("removeTemplateFromProfile()-->populate_template_option_list(" + selectedTemplate + ")");
                        populate_template_option_list(selectedTemplate);
                        let parentId = document.getElementById("concatenated-templates-list").parentNode.id;
                        jQuery('#' + parentId).trigger('change');
                    } else {            
                        console.log("Template not included in array");
                    }
                }
                          
                function hideDiv() {
                    document.getElementById("templates-div").style.display = "none";
                }
     
                function arrayRemove(array, value) {  
                   return array.filter(function(element){ 
                       return element != value; 
                   });
                }
                   
            </script>
            
            <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" />
            
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
    
                 select, option {
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
                    max-width: 870px;
                    gap: 10px 10px;
                    row-gap: 10px;
                    column-gap: 10px;
                    background: rgba(117,0,192,0.05);
                    display: -webkit-box;
                    display: -moz-box;
                    display: -ms-flexbox;
                    display: -webkit-flex;
                    max-height: 4300px;
                    overflow-y: auto;
                    scrollbar-gutter: both-edges;
                    scrollbar-width: thin;
                }
    
                .component-container::-webkit-scrollbar {
                    width: 16px;
                }
                 
                .component-container::-webkit-scrollbar-track {
                    background-color: #efefef;
                    border-radius: 0px;
                }
                 
                .component-container::-webkit-scrollbar-thumb {
                    border: 5px solid transparent;
                    border-radius: 100px;
                    background-color: #e5c4ff;
                    background-clip: content-box;
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
    
                .button-add-remove-template {
                    display: inline-block;
                    width: 40px;
                    color: white;
                    background: #7500c0;
                    opacity: 0.7;
                    padding: 10px 0 10px 5px;
                    border: 0;
                    border-right: 0;
                    outline: 0;
                    text-align: center;                 
                }
                
                .button-add-remove-template-left {
                    border-top-right-radius: 0px;
                    border-bottom-right-radius: 0px;
                    border-top-left-radius: 5px;
                    border-bottom-left-radius: 5px;
                }
                
                
                .button-add-remove-template-right {
                    border-top-right-radius: 5px;
                    border-bottom-right-radius: 5px;
                    border-top-left-radius: 0px;
                    border-bottom-left-radius: 0px;           
                }
                
            </style>
        </head>
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
            <div class="component-container" id="components-list">
            </div>
        </div>
        </body>
        <input type="hidden" id="concatenated-templates-list" name="value" value="" >
        """
        return HTML
    } catch (e) {
        println "Something went wrong in the HTML return block (select_templates.groovy): ${e}"
    }
