import groovy.json.JsonSlurper

def worker_node_memory

if ( STANDALONE_MODE != "true" ) {

    try {
        def jsonFilePath = PROFILE
        def inputFile = new File(jsonFilePath)
        def parsedJson = new JsonSlurper().parse(inputFile)

        worker_node_memory = parsedJson.config.vm_properties.worker_node_memory
    } catch(e) {
        println "Something went wrong in the GROOVY block (config_vm_properties_worker_node_memory): ${e}"
    }

    int min = 2048
    int max = 32384
    int step = 1024
    int startValue = worker_node_memory.toInteger()
    int minWarning = 4096
    int valueDisplayConversion = 1024 // Set to 1 for no conversion. Option for display MB as shorter GB form
    def rangeUnit = "GB"
    def warningText = "Warning. Allocating less than 8GB of ram to the worker nodes may not give you much room for deploying workloads"
    def infoText = "Determines the amount of memory that will be allocated to the KX-Worker VM(s)"
    def paramIcon = "/userContent/icons/memory-solid.svg"
    def paramShortTitle = "Memory"
    def variablesSuffix = "worker_node_memory"
    def sliderElementRangeId = "slider_value_${variablesSuffix}"
    def sliderElementValueId = "${sliderElementRangeId}_value"
    def sliderElementPreviousValueId = "${sliderElementRangeId}_previous_value"
    def warningTextElementId = "${sliderElementRangeId}_warning"
    def warningIconElementId = "${sliderElementRangeId}_warning_icon"

    try {

        // language=HTML
        def HTML = """
        <body>
        <div class="outerWrapper" id="worker-memory-div" style="display: block">
            <div class="wrapper"><span><img src="${paramIcon}" class="param-icon svg-purple" alt="cpu" /></span>
        
                <span id="${sliderElementValueId}" class="slider-element-value">${startValue} ${rangeUnit}</span>
                <div id="container"><span class="button-range-span"><button type="button" class="button-left"
                                                                            onclick="subtract_one(&quot;${sliderElementPreviousValueId}&quot;, &quot;${sliderElementRangeId}&quot;, &quot;${sliderElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${min}&quot;);"><img src="/userContent/icons/minus.svg" alt="minus" class="image-plus-minus svg-white"/></button></span> <span class="input-range-span">
                <input type="range" min="${min}"
                       max="${max}"
                       step="${step}"
                       value="${startValue}"
                       name="value"
                       class="slider"
                       id="${sliderElementRangeId}"  onchange="show_value(this.value, &quot;${sliderElementPreviousValueId}&quot;, &quot;${sliderElementRangeId}&quot;, &quot;${sliderElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;);"
                       onmouseleave="show_value(this.value, &quot;${sliderElementPreviousValueId}&quot;, &quot;${sliderElementRangeId}&quot;, &quot;${sliderElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;);" onmousemove="update_display_value(this.value, &quot;${sliderElementValueId}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;);">
                  </span>
                    <span class="button-range-span"><button type="button" class="button-right"
                                                            onclick="add_one(&quot;${sliderElementPreviousValueId}&quot;, &quot;${sliderElementRangeId}&quot;, &quot;${sliderElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${max}&quot;);"><img src="/userContent/icons/plus.svg" alt="plus" class="image-plus-minus svg-white"/></button></span>
                    <span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${infoText}"></span><span id="${warningIconElementId}" data-text="${warningText}" class="warning-span tooltip"><img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="cpu" /></span>
        
                </div>
            </div>
        </div>
        <style scoped="scoped" onload="show_value(&quot;${startValue}&quot;, &quot;${sliderElementPreviousValueId}&quot;, &quot;${sliderElementRangeId}&quot;, &quot;${sliderElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;);">   </style>
        <input type="hidden" id="${sliderElementPreviousValueId}" name="${sliderElementPreviousValueId}" value="" >
        </body>
        """
        return HTML

    } catch (e) {
        println "Something went wrong in the HTML return block (config_vm_properties_worker_node_memory): ${e}"
    }

}
