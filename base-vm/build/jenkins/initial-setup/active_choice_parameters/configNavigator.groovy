def extendedDescription

try {
    extendedDescription = "KX-Main nodes provide two core functions - Kubernetes master services as well as the desktop environment for easy access to deployed tools and documentation. Only the first KX-Main node hosts both the desktop environment, and the Kubernetes Master services. Subsequent KX-Main nodes host the Kubernetes Master services only. In a physical environment with 16GB ram or less, it is recommended to leave at least 4-6GB ram to the host operating system, leaving 10-12GB that can be allocated to KX-Main. In this scenario, it is recommended to set KX-Worker nodes to zero, and run the whole KX.AS.CODE setup in standalone mode."
} catch(e) {
    println "Something went wrong in the GROOVY block (headlineKxMain): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <head>
        <script>

        </script>
        <style>
        
            .config-selector-panel {
                display: flex;
                width: 600px;
                height: 100px;
            }
            
            .config-tab {
                  height: 50px;
                  width: 75px;
                  background-color: #bbb;
                  display: inline-block;
                  border: 1px;
            }
            
        </style>
    </head>
    <div id="config-navigator" class="config-selector-panel">
        <div class="config-tab"><img src="/userContent/icons/format-list-checks.svg" class="param-icon svg-white" alt="Profile Selection"></div>
        <div class="config-tab"><img src="/userContent/icons/form-textbox.svg" class="param-icon svg-white" alt="General Parameters"></div>
        <div class="config-tab"><img src="/userContent/icons/memory.svg" class="param-icon svg-white" alt="KX-Main Node Configuration"></div>
        <div class="config-tab"><img src="/userContent/icons/memory.svg" class="param-icon svg-white" alt="KX-Worker Node Configuration"></div>
        <div class="config-tab"><img src="/userContent/icons/harddisk.svg" class="param-icon svg-white" alt="Storage Configuration"></div>
        <div class="config-tab"><img src="/userContent/icons/apps.svg" class="param-icon svg-white" alt="Application Template Group Selection"></div>
        <div class="config-tab"><img src="/userContent/icons/chart-areaspline.svg" class="param-icon svg-white" alt="System Resources Check"></div>
        <div class="config-tab"><img src="/userContent/icons/play-outline.svg" class="param-icon svg-white" alt="Deployment"></div>
    </div>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (headlineKxMain): ${e}"
}

