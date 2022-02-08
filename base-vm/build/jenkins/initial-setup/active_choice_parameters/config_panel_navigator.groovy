try {
    // language=HTML
    def HTML = """
    <body>
    <script>
        function hideParameterDivs() {
            let configDivs = [
                "select-profile-div",
                "prerequisites-div",
                "profile-builds-div",
                "standalone-toggle-div",
                "worker-cpu-count-div",
                "worker-node-count-div",
                "main-node-count-div",
                "local-storage-div",
                "main-memory-div",
                "general-parameters-div",
                "workloads-on-master-div",
                "main-cpu-count-div",
                "worker-memory-div",
                "network-storage-div",
                "headline-main-div",
                "headline-workers-div",
                "headline-storage-div",
                "templates-div",
                "header-system-check-div",
                "system-check-div",
                "review-and-launch-div",
                "profile-launch-div"
            ];
            console.log(configDivs);
            configDivs.forEach(function(item) {
                try {
                    console.log("Hiding div: " + item);
                    document.getElementById(item).style.display = "none";
                } catch(e) {
                    console.log("Error hiding div: " + e);
                }
            })

        }
  
            function change_panel_selection(config_panel) {
                
               if ( document.getElementById('system-prerequisites-check').value === "failed" ) {
                   config_panel = "config-panel-profile-selection";
               }
                   
               console.log("Selected config-panel: " + config_panel);
               
               waitForElement(config_panel,function(){
                    console.log("config-panel content: " + document.getElementById(config_panel));
                });
                              
               waitForElement('config-placeholder',function(){
                    console.log("config-placeholder children: " + document.getElementById('config-placeholder').checked);
                });
               
               let configPanelDivsInPlaceholderDiv = document.getElementById('config-placeholder').children;
                
               for (let i = 0; i < configPanelDivsInPlaceholderDiv.length; i++) {
                   if ( configPanelDivsInPlaceholderDiv[i].style.display !== "none" ) {
                        console.log("Visible Divs in Config Placeholder: " + configPanelDivsInPlaceholderDiv[i].id);
                   }
               }
                              
               const configPanels = [ 
                   "config-panel-profile-selection",
                   "config-panel-general-params",
                   "config-panel-kx-main-config",
                   "config-panel-kx-worker-config",
                   "config-panel-storage-config",
                   "config-panel-template-selection",
                   "config-panel-system-check",
                   "config-panel-kx-summary-start"
               ];
                
                let configPanelIcon
                console.log(configPanels);
                
                configPanels.forEach(function(item) {
                    configPanelIcon = item + "-icon";
                    if ( item === config_panel ) {
                        console.log("Item selected: " + item + ", item icon: " + configPanelIcon);
                        hideParameterDivs();
                        document.getElementById(item).className = "config-tab-selected";
                        document.getElementById(configPanelIcon).className = "config-panel-icon svg-purple";
                        switch (item) {
                            case "config-panel-profile-selection":
                                console.log("Inside switch-case for select-profile-div");
                                moveDivToConfigPanel("select-profile-div");
                                moveDivToConfigPanel("prerequisites-div");
                                moveDivToConfigPanel("profile-builds-div");
                                updateNavigationFooter("", "config-panel-general-params");
                                break;
                            case "config-panel-general-params":
                                moveDivToConfigPanel("general-parameters-div");
                                moveDivToConfigPanel("standalone-toggle-div");
                                moveDivToConfigPanel("workloads-on-master-div");
                                updateNavigationFooter("config-panel-profile-selection", "config-panel-kx-main-config");
                                break;
                            case "config-panel-kx-main-config":
                                moveDivToConfigPanel("headline-main-div");
                                moveDivToConfigPanel("main-node-count-div");
                                moveDivToConfigPanel("main-cpu-count-div");
                                moveDivToConfigPanel("main-memory-div");
                                updateNavigationFooter("config-panel-general-params", "config-panel-kx-worker-config");
                                break;
                            case "config-panel-kx-worker-config":
                                moveDivToConfigPanel("headline-workers-div");
                                moveDivToConfigPanel("worker-node-count-div");
                                moveDivToConfigPanel("worker-cpu-count-div");
                                moveDivToConfigPanel("worker-memory-div");
                                updateNavigationFooter("config-panel-kx-main-config", "config-panel-storage-config");
                                break;
                            case "config-panel-storage-config":
                                moveDivToConfigPanel("headline-storage-div");
                                moveDivToConfigPanel("network-storage-div");
                                moveDivToConfigPanel("local-storage-div");
                                updateNavigationFooter("config-panel-kx-worker-config", "config-panel-template-selection");
                                break;
                            case "config-panel-template-selection":
                                moveDivToConfigPanel("templates-div");
                                updateNavigationFooter("config-panel-storage-config", "config-panel-system-check");
                                break;
                            case "config-panel-system-check":
                                moveDivToConfigPanel("header-system-check-div");
                                moveDivToConfigPanel("system-check-div");
                                updateNavigationFooter("config-panel-template-selection", "config-panel-kx-summary-start");
                                break;
                            case "config-panel-kx-summary-start":
                                moveDivToConfigPanel("review-and-launch-div");
                                moveDivToConfigPanel("profile-launch-div");
                                updateNavigationFooter("config-panel-system-check", "");
                                break;
                        }
                    } else {
                        console.log("Item not selected: " + item + ", item icon: " + configPanelIcon);
                        if ( document.getElementById('system-prerequisites-check').value === "failed" ) {
                            document.getElementById(item).className = "config-tab-disabled";
                        } else {
                            document.getElementById(item).className = "config-tab";
                        }
                        document.getElementById(configPanelIcon).className = "config-panel-icon svg-white";
                    }  
                })
            }
            
            function removeAllChildNodes(parent) {
                while (parent.firstChild) {
                    parent.removeChild(parent.firstChild);
                }
            }

            function moveDivToConfigPanel(configDiv) {
                try {
                    let currentParent = document.getElementById(configDiv).parentNode.id;
                    console.log("(1) Current parent for " + configDiv + " is " + currentParent);
                    let divConfigPanelParent = document.getElementById("config-placeholder");
                    let divConfigPanelChild = document.getElementById(configDiv);
                    console.log("Child div: " + divConfigPanelChild.id);
                    let divChildConfigs = document.querySelectorAll('[id=' + configDiv + ']');
                    console.log("(2) Div " + configDiv + " is present " + divChildConfigs.length + " times");
                    if ( divChildConfigs.length <= 1 && currentParent !== "config-placeholder" ) {
                        console.log("(3) Parent div: " + divConfigPanelParent);
                        divConfigPanelParent.appendChild(divConfigPanelChild);
                    } else if ( divChildConfigs.length > 1) {
                        console.log("Inside divChildConfigs loop");
                        divChildConfigs.forEach(function(item) {
                            console.log("Item parent node: " + item.parentNode.id);
                            if ( item.parentNode.id === 'config-placeholder' ) {
                                divConfigPanelParent.removeChild(item);
                            };
                        });
                        console.log("3.5");
                        console.log("(4) Parent div: " + divConfigPanelParent);
                        currentParent = document.getElementById(configDiv).parentNode.id;
                        console.log("(5) Current parent for " + configDiv + " is " + currentParent);
                        divConfigPanelChild = document.getElementById(configDiv);
                        divConfigPanelParent.appendChild(divConfigPanelChild);
                        console.log(document.querySelectorAll('[id=' + configDiv + ']'));            
                    }
                    
                    let divConfigNumber = document.querySelectorAll('[id=' + configDiv + ']').length;
                    console.log("(6) Div " + configDiv + " is present " + divConfigNumber + " times");
                    
                    let displayType;
                    if ( configDiv === "system-check-div" || configDiv === "review-and-launch-div" ) {
                        displayType = "flex";
                        if ( configDiv === "review-and-launch-div" ) {
                            console.log("ConfigDiv = review-and-launch-div. Populating review table");
                            populateReviewTable();
                        }
                    } else {
                        displayType = "block";
                    }
                    divConfigPanelChild.style.display = displayType;
                } catch(e) {
                   console.log("Error in moveDivToConfigPanel(configDiv) function: " + e);
                }
            }
            
            function updateNavigationFooter(previous, next) {
                
                console.log("Inside updateNavigationFooter(previous, next). Received params: " + previous + ", " + next);
                let chevronsToShow;

                document.getElementById('config-panel-footer-left-nav-div').setAttribute( "onClick", "change_panel_selection('" + previous +"')" );
                document.getElementById('config-panel-footer-right-nav-div').setAttribute( "onClick", "change_panel_selection('" + next + "')" );
                                    
                if ( previous === '') {
                    chevronsToShow = "right-only";
                    console.log("Inside right-only");
                } else if ( next === '') {
                    chevronsToShow = "left-only";
                    console.log("Inside left-only");
                }  else {
                    chevronsToShow = "both";
                    console.log("Inside both");
                }
                          
                if ( chevronsToShow === "both" ) {
                    document.getElementById("config-panel-footer-left-nav-div").style.display = "block";
                    document.getElementById("config-panel-footer-right-nav-div").style.display = "block";
                    document.getElementById("config-navigator-footer").style.justifyContent = "space-between";
                } else if ( chevronsToShow === "left-only" ) {
                    document.getElementById("config-panel-footer-left-nav-div").style.display = "block";
                    document.getElementById("config-panel-footer-right-nav-div").style.display = "none";
                    document.getElementById("config-navigator-footer").style.justifyContent = "flex-start";
                } else { 
                    document.getElementById("config-panel-footer-left-nav-div").style.display = "none";
                    document.getElementById("config-panel-footer-right-nav-div").style.display = "block";
                    document.getElementById("config-navigator-footer").style.justifyContent = "flex-end";
                }
                               

            }
            
            function waitForElement(elementId, callBack){
              window.setTimeout(function(){
                let element = document.getElementById(elementId);
                if(element){
                  callBack(elementId, element);
                }else{
                  waitForElement(elementId, callBack);
                }
              },500)
            }
            
            function loadFirstConfigPanel() {
                waitForElement('select-profile-div',function(){
                    change_panel_selection('config-panel-profile-selection');
                });
            }
</script>
        <div class="config-outer-wrapper">
            <div class="config-inner-panel">
                <div id="config-navigator" class="config-selector-panel">
                    <div class="config-tab-selected" id="config-panel-profile-selection" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/format-list-checks.svg" id="config-panel-profile-selection-icon" class="config-panel-icon svg-purple" alt="Profile Selection"></div>
                    <div class="config-tab" id="config-panel-general-params" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/form-textbox.svg" id="config-panel-general-params-icon" class="config-panel-icon svg-white" alt="General Parameters"></div>
                    <div class="config-tab" id="config-panel-kx-main-config" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/memory.svg" id="config-panel-kx-main-config-icon" class="config-panel-icon svg-white" alt="KX-Main Node Configuration"></div>
                    <div class="config-tab" id="config-panel-kx-worker-config" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/memory.svg" id="config-panel-kx-worker-config-icon" class="config-panel-icon svg-white" alt="KX-Worker Node Configuration"></div>
                    <div class="config-tab" id="config-panel-storage-config" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/harddisk.svg" id="config-panel-storage-config-icon" class="config-panel-icon svg-white" alt="Storage Configuration"></div>
                    <div class="config-tab" id="config-panel-template-selection" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/apps.svg" id="config-panel-template-selection-icon" class="config-panel-icon svg-white" alt="Application Template Group Selection"></div>
                    <div class="config-tab" id="config-panel-system-check" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/chart-areaspline.svg" id="config-panel-system-check-icon" class="config-panel-icon svg-white" alt="System Resources Check"></div>
                    <div class="config-tab" id="config-panel-kx-summary-start" onclick="change_panel_selection(this.id);"><img src="/userContent/icons/play-outline.svg" id="config-panel-kx-summary-start-icon" class="config-panel-icon svg-white" alt="Deployment"></div>
                </div>
                <div id="config-placeholder" class="config-placeholder"></div>
                <div id="config-navigator-footer" class="config-selector-footer">
                    <div class="config-tab-footer-icons" id="config-panel-footer-left-nav-div" onclick="" style="display: block"><img src="/userContent/icons/chevron-left.svg" id="config-panel-left-nav-icon" class="config-tab-footer-icons svg-white" alt="navigate previous"></div>
                    <div class="config-tab-footer-icons" id="config-panel-footer-right-nav-div" onclick="" style="display: block"><img src="/userContent/icons/chevron-right.svg" id="config-panel-right-nav-icon" class="config-tab-footer-icons svg-white" alt="navigate next"></div>
                </div>
            </div>
        </div>
        <style scoped="scoped" onload="loadFirstConfigPanel();">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (config_panel_navigator.groovy): ${e}"
}
