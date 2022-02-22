import groovy.json.JsonSlurper

def extendedDescription
def parsedJson

def STANDALONE_MODE

int workerNodeCountMinWarning = 0 // Set to 0 to disable the minimum warning
int workerNodeValueDisplayConversion = 1 // Set to 1 for no conversion (eg. from MB to GB)
def workerNodeCountRangeUnit = "#"
def workerNodeCountWarningText = ""
def workerNodeInfoText = "Determines the number of KX-Worker nodes that will be started"
def workerNodeParamShortTitle = "Number KX-Worker Nodes"

int workerNodeCountMin
int workerNodeCountMax
int workerNodeCountStep
int workerNodeCountStartValue
def worker_node_count
def workerNodeCountOpacity
def workerNodeCountCursor

try {
    def jsonFilePath = PROFILE
    def inputFile = new File(jsonFilePath)
    parsedJson = new JsonSlurper().parse(inputFile)
} catch(e) {
    println "Something went wrong in the GROOVY block (properties_worker_node.groovy): ${e}"
}

try {
    if (GENERAL_PARAMETERS) {
        generalParameterElements = GENERAL_PARAMETERS.split(';')
        STANDALONE_MODE = generalParameterElements[4]
    }
} catch(e) {
    println("Something went wrong in the GROOVY block (properties_worker_node.groovy): ${e}")
}

try {
    if (STANDALONE_MODE != true) {

        worker_node_count = parsedJson.config.vm_properties.worker_node_count

        workerNodeCountMin = 0
        workerNodeCountMax = 16
        workerNodeCountStep = 1
        workerNodeCountStartValue = worker_node_count.toInteger()
        println("properties_worker_node.groovy -> workerNodeCountStartValue: ${workerNodeCountStartValue} (Standalone Mode: FALSE)")

        workerNodeCountOpacity = "0.7"
        workerNodeCountCursor = "pointer"

    } else {

        workerNodeCountMin = 0
        workerNodeCountMax = 0
        workerNodeCountStep = 1
        workerNodeCountStartValue = 1
        println("properties_worker_node.groovy -> workerNodeCountStartValue: ${workerNodeCountStartValue} (Standalone Mode: TRUE)")
        workerNodeCountOpacity = "0.1"
        workerNodeCountCursor = "not-allowed"

    }

} catch(e) {
    println "Something went wrong in the GROOVY block (properties_worker_node.groovy): ${e}"
}

def worker_node_cpu_cores

try {
    worker_node_cpu_cores = parsedJson.config.vm_properties.worker_node_cpu_cores
    println("Profile: " + PROFILE)
    println("CPU Cores read: " + worker_node_cpu_cores)
} catch(e) {
    println "Something went wrong in the GROOVY block (properties_worker_node.groovy): ${e}"
}

int workerNodeCpuCoresMin = 1
int workerNodeCpuCoresMax = 16
int workerNodeCpuCoresStep = 1
int workerNodeCpuCoresStartValue = worker_node_cpu_cores.toInteger()
int workerNodeCpuCoresMinWarning = 2
int cpuCoresValueDisplayConversion = 1
def cpuCoresRangeUnit = "Cores"
def workerNodeCpuCoresWarningText = "Warning. Allocating less than 2 cores of CPU to the worker may result in a poor experience"
def workerNodeCpuCoresInfoText = "Determines the amount of CPU cores that will be allocated to the KX-Worker VM"
def workerNodeCpuCoresParamShortTitle = "CPU Cores"

try {
    extendedDescription = "KX-Worker nodes are optional. On a local machine with lower amount of resources (equal to or below 16GB ram), a singe node standalone KX.AS.CODE deployment is advisable. In this case, just set the number of KX-Workers to 0. The 'allow workloads on master' toggle must be set to on in this case, else it will not be possible to deploy any workloads beyond the core tools and services."
} catch(e) {
    println "Something went wrong in the GROOVY block (properties_worker_node.groovy): ${e}"
}

def worker_node_memory

try {
    worker_node_memory = parsedJson.config.vm_properties.worker_node_memory
} catch(e) {
    println "Something went wrong in the GROOVY block (properties_worker_node.groovy): ${e}"
}

int workerNodeMemoryMin = 4096
int workerNodeMemoryMax = 32384
int workerNodeMemoryStep = 1024
int workerNodeMemoryStartValue = worker_node_memory.toInteger()
int workerNodeMemoryMinWarning = 8192
int memoryValueDisplayConversion = 1024 // Set to 1 for no conversion. Option for display MB as shorter GB form
def memoryRangeUnit = "GB"
def workerNodeMemoryWarningText = "Warning. Allocating less than 8GB of ram to the admin main node may result in a poor experience"
def workerNodeMemoryInfoText = "Determines the amount of memory that will be allocated to the KX-Main Admin VM"
def workerNodeMemoryParamShortTitle = "Memory"


try {
    // language=HTML
    def HTML = """
    <div id="headline-workers-div" style="display: none;">
    <h2>KX-Worker Parameters</h2>
    <span class="description-paragraph-span"><p>${extendedDescription }</p></span>
    </div>
    
    <div class="outerWrapper" id="worker-node-count-div" style="display: none;">
        <div class="wrapper"><span><img src="/userContent/icons/pound.svg" class="param-icon svg-purple" alt="#" /></span>
            <span id="counter_value_worker_node_count_value" class="counter-element-value">${workerNodeCountStartValue} ${workerNodeCountRangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left" style="opacity: ${workerNodeCountOpacity}; cursor: ${workerNodeCountCursor}"
                                                    onclick="subtract_one(&quot;counter_value_worker_node_count_previous_value&quot;, &quot;counter_value_worker_node_count&quot;, &quot;counter_value_worker_node_count_value&quot;, &quot;counter_value_worker_node_count_warning_icon&quot;, &quot;${workerNodeCountMinWarning}&quot;, &quot;${workerNodeValueDisplayConversion}&quot;, &quot;${workerNodeCountRangeUnit}&quot;, &quot;${workerNodeCountStep}&quot;, &quot;${workerNodeCountMin}&quot;);"><img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                    <span class="divider-span"></span>
                    <button type="button" class="button-right" style="opacity: ${workerNodeCountOpacity}; cursor: ${workerNodeCountCursor}"
                            onclick="add_one(&quot;counter_value_worker_node_count_previous_value&quot;, &quot;counter_value_worker_node_count&quot;, &quot;counter_value_worker_node_count_value&quot;, &quot;counter_value_worker_node_count_warning_icon&quot;, &quot;${workerNodeCountMinWarning}&quot;, &quot;${workerNodeValueDisplayConversion}&quot;, &quot;${workerNodeCountRangeUnit}&quot;, &quot;${workerNodeCountStep}&quot;, &quot;${workerNodeCountMax}&quot;);"><img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/></button></span>
            <span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon"></span>
            <span id="counter_value_worker_node_count_warning_icon" data-text="${workerNodeCountWarningText}" class="warning-span tooltip"><img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <style scoped="scoped" onload="show_value(&quot;${workerNodeCountStartValue}&quot;, &quot;counter_value_worker_node_count_previous_value&quot;, &quot;counter_value_worker_node_count&quot;, &quot;counter_value_worker_node_count_value&quot;, &quot;counter_value_worker_node_count_warning_icon&quot;, &quot;${workerNodeCountMinWarning}&quot;, &quot;${workerNodeValueDisplayConversion}&quot;, &quot;${workerNodeCountRangeUnit}&quot;);">   </style>
    <input type="hidden" id="counter_value_worker_node_count" name="counter_value_worker_node_count" value="${workerNodeCountStartValue}">
    <input type="hidden" id="counter_value_worker_node_count_previous_value" name="counter_value_worker_node_count_previous_value" value="">


    <div class="outerWrapper" id="worker-cpu-count-div" style="display: none">
        <div class="wrapper"><span><img src="/userContent/icons/memory.svg" class="param-icon svg-purple" alt="cpu" /></span>

            <span id="slider_value_worker_node_cpu_cores_value" class="slider-element-value">${workerNodeCpuCoresStartValue} ${cpuCoresRangeUnit}</span>
            <div id="container"><span class="button-range-span"><button type="button" class="button-left"
            onclick="subtract_one(&quot;slider_value_worker_node_cpu_cores_previous_value&quot;, &quot;slider_value_worker_node_cpu_cores&quot;, &quot;slider_value_worker_node_cpu_cores_value&quot;, &quot;slider_value_worker_node_cpu_cores_warning_icon&quot;, &quot;${workerNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;, &quot;${workerNodeCpuCoresStep}&quot;, &quot;${workerNodeCpuCoresMin}&quot;);"><img src="/userContent/icons/minus.svg" alt="minus" class="image-plus-minus svg-white"/></button></span> <span class="input-range-span">
            <input type="range" min="${workerNodeCpuCoresMin}"
                   max="${workerNodeCpuCoresMax}"
                   step="${workerNodeCpuCoresStep}"
                   value="${workerNodeCpuCoresStartValue}"
                   name="slider_value_worker_node_cpu_cores"
                   class="slider"
                   id="slider_value_worker_node_cpu_cores"  onchange="show_value(this.value, &quot;slider_value_worker_node_cpu_cores_previous_value&quot;, &quot;slider_value_worker_node_cpu_cores&quot;, &quot;slider_value_worker_node_cpu_cores_value&quot;, &quot;slider_value_worker_node_cpu_cores_warning_icon&quot;, &quot;${workerNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);"
                   onmouseleave="show_value(this.value, &quot;slider_value_worker_node_cpu_cores_previous_value&quot;, &quot;slider_value_worker_node_cpu_cores&quot;, &quot;slider_value_worker_node_cpu_cores_value&quot;, &quot;slider_value_worker_node_cpu_cores_warning_icon&quot;, &quot;${workerNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);" onmousemove="update_display_value(this.value, &quot;slider_value_worker_node_cpu_cores_value&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);">
              </span>
                <span class="button-range-span"><button type="button" class="button-right"
                onclick="add_one(&quot;slider_value_worker_node_cpu_cores_previous_value&quot;, &quot;slider_value_worker_node_cpu_cores&quot;, &quot;slider_value_worker_node_cpu_cores_value&quot;, &quot;slider_value_worker_node_cpu_cores_warning_icon&quot;, &quot;${workerNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;, &quot;${workerNodeCpuCoresStep}&quot;, &quot;${workerNodeCpuCoresMax}&quot;);"><img src="/userContent/icons/plus.svg" alt="plus" class="image-plus-minus svg-white"/></button></span>
                <span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${workerNodeCpuCoresInfoText}"></span><span id="slider_value_worker_node_cpu_cores_warning_icon" data-text="${workerNodeCpuCoresWarningText}" class="warning-span tooltip"><img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="cpu" /></span>

            </div>
        </div>
    </div>
    <style scoped="scoped" onload="show_value(&quot;${workerNodeCpuCoresStartValue}&quot;, &quot;slider_value_worker_node_cpu_cores_previous_value&quot;, &quot;slider_value_worker_node_cpu_cores&quot;, &quot;slider_value_worker_node_cpu_cores_value&quot;, &quot;slider_value_worker_node_cpu_cores_warning_icon&quot;, &quot;${workerNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);">   </style>
    <input type="hidden" id="slider_value_worker_node_cpu_cores_previous_value" name="slider_value_worker_node_cpu_cores_previous_value" value="" >
    
    
    <div class="outerWrapper" id="worker-memory-div" style="display: none">
        <div class="wrapper"><span><img src="/userContent/icons/memory-solid.svg" class="param-icon svg-purple" alt="cpu" /></span>

            <span id="slider_value_worker_node_memory_value" class="slider-element-value">${workerNodeMemoryStartValue} ${memoryRangeUnit}</span>
            <div id="container"><span class="button-range-span"><button type="button" class="button-left"
            onclick="subtract_one(&quot;slider_value_worker_node_memory_previous_value&quot;, &quot;slider_value_worker_node_memory&quot;, &quot;slider_value_worker_node_memory_value&quot;, &quot;slider_value_worker_node_memory_warning_icon&quot;, &quot;${workerNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;, &quot;${workerNodeMemoryStep}&quot;, &quot;${workerNodeMemoryMin}&quot;);"><img src="/userContent/icons/minus.svg" alt="minus" class="image-plus-minus svg-white"/></button></span> <span class="input-range-span">
            <input type="range" min="${workerNodeMemoryMin}"
                   max="${workerNodeMemoryMax}"
                   step="${workerNodeMemoryStep}"
                   value="${workerNodeMemoryStartValue}"
                   name="slider_value_worker_node_memory"
                   class="slider"
                   id="slider_value_worker_node_memory"  onchange="show_value(this.value, &quot;slider_value_worker_node_memory_previous_value&quot;, &quot;slider_value_worker_node_memory&quot;, &quot;slider_value_worker_node_memory_value&quot;, &quot;slider_value_worker_node_memory_warning_icon&quot;, &quot;${workerNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);"
                   onmouseleave="show_value(this.value, &quot;slider_value_worker_node_memory_previous_value&quot;, &quot;slider_value_worker_node_memory&quot;, &quot;slider_value_worker_node_memory_value&quot;, &quot;slider_value_worker_node_memory_warning_icon&quot;, &quot;${workerNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);" onmousemove="update_display_value(this.value, &quot;slider_value_worker_node_memory_value&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);">
              </span>
                <span class="button-range-span"><button type="button" class="button-right"
                onclick="add_one(&quot;slider_value_worker_node_memory_previous_value&quot;, &quot;slider_value_worker_node_memory&quot;, &quot;slider_value_worker_node_memory_value&quot;, &quot;slider_value_worker_node_memory_warning_icon&quot;, &quot;${workerNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;, &quot;${workerNodeMemoryStep}&quot;, &quot;${workerNodeMemoryMax}&quot;);"><img src="/userContent/icons/plus.svg" alt="plus" class="image-plus-minus svg-white"/></button></span>
                <span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${workerNodeMemoryInfoText}"></span><span id="slider_value_worker_node_memory_warning_icon" data-text="${workerNodeMemoryWarningText}" class="warning-span tooltip"><img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="cpu" /></span>

            </div>
        </div>
    </div>
    <style scoped="scoped" onload="show_value(&quot;${workerNodeMemoryStartValue}&quot;, &quot;slider_value_worker_node_memory_previous_value&quot;, &quot;slider_value_worker_node_memory&quot;, &quot;slider_value_worker_node_memory_value&quot;, &quot;slider_value_worker_node_memory_warning_icon&quot;, &quot;${workerNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);">   </style>
    <input type="hidden" id="slider_value_worker_node_memory_previous_value" name="slider_value_worker_node_memory_previous_value" value="" >
    <input type="hidden" id="concatenated_value_worker_node_config" name="value" value="" >
    
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (properties_worker_node.groovy): ${e}"
}
