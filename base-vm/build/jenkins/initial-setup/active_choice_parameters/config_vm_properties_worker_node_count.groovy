import groovy.json.JsonSlurper

def worker_node_count

if ( STANDALONE_MODE != "true" ) {

    try {
        def jsonFilePath = PROFILE
        def inputFile = new File(jsonFilePath)
        def parsedJson = new JsonSlurper().parse(inputFile)

        worker_node_count = parsedJson.config.vm_properties.worker_node_count
    } catch(e) {
        println "Something went wrong in the GROOVY block (config_vm_properties_worker_node_count): ${e}"
    }

    int min = 0
    int max = 16
    int step = 1
    int startValue = worker_node_count.toInteger()
    int minWarning = 0 // Set to 0 to disable the minimum warning
    int valueDisplayConversion = 1 // Set to 1 for no conversion (eg. from MB to GB)
    def rangeUnit = "#"
    def warningText = ""
    def infoText = "Determines the number of KX-Worker nodes that will be started"
    def paramIcon = "/userContent/icons/pound.svg"
    def paramShortTitle = "Number KX-Worker Nodes"
    def variablesSuffix = "worker_node_count"
    def counterHiddenValueId = "counter_value_${variablesSuffix}"
    def counterElementValueId = "${counterHiddenValueId}_value"
    def counterElementPreviousValueId = "${counterHiddenValueId}_previous_value"
    def warningTextElementId = "${counterHiddenValueId}_warning"
    def warningIconElementId = "${counterHiddenValueId}_warning_icon"

    try {
        // language=HTML
        def HTML = """
        <body>
        <div class="outerWrapper" id="worker-node-count-div" style="display: block">
            <div class="wrapper"><span><img src="${paramIcon}" class="param-icon svg-purple" alt="#" /></span>
                <span id="${counterElementValueId}" class="counter-element-value">${startValue} ${rangeUnit}</span>
                <span class="button-range-span"><button type="button" class="button-left"
                                onclick="subtract_one(&quot;${counterElementPreviousValueId}&quot;, &quot;${counterHiddenValueId}&quot;, &quot;${counterElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${min}&quot;);"><img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
                <span class="divider-span"></span>
                <span class="button-range-span">
                        <span class="divider-span"></span>
                        <button type="button" class="button-right"
                                onclick="add_one(&quot;${counterElementPreviousValueId}&quot;, &quot;${counterHiddenValueId}&quot;, &quot;${counterElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${max}&quot;);"><img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/></button></span>
                <span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon"></span>
                <span id="${warningIconElementId}" data-text="${warningText}" class="warning-span tooltip"><img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
            </div>
        </div>
        <style scoped="scoped" onload="show_value(&quot;${startValue}&quot;, &quot;${counterElementPreviousValueId}&quot;, &quot;${counterHiddenValueId}&quot;, &quot;${counterElementValueId}&quot;, &quot;${warningIconElementId}&quot;, &quot;${minWarning}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;);">   </style>
        <input type="hidden" id="${counterHiddenValueId}" name="value" value="${startValue}">
        <input type="hidden" id="${counterElementPreviousValueId}" name="${counterElementPreviousValueId}" value="">
        </body>
        """
        return HTML
    } catch (e) {
        println "Something went wrong in the HTML return block (config_vm_properties_worker_node_count): ${e}"
    }
}