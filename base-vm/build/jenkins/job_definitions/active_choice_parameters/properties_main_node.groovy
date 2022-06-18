import groovy.json.JsonSlurper

def extendedDescription
def parsedJson

def STANDALONE_MODE

int mainNodeCountMinWarning = 0 // Set to 0 to disable the minimum warning
int mainNodeValueDisplayConversion = 1 // Set to 1 for no conversion (eg. from MB to GB)
def mainNodeCountRangeUnit = "#"
def mainNodeCountWarningText = ""
def mainNodeInfoText = "Determines the number of KX-Main nodes that will be started"
def mainNodeParamShortTitle = "Number KX-Main Nodes"

int mainNodeCountMin
int mainNodeCountMax
int mainNodeCountStep
int mainNodeCountStartValue
def main_node_count
def mainNodeCountOpacity
def mainNodeCountCursor

try {
    def jsonFilePath = PROFILE.split(";")[0]
    def inputFile = new File(jsonFilePath)
    parsedJson = new JsonSlurper().parse(inputFile)
} catch(e) {
    println("Something went wrong in the GROOVY block (properties_main_node.groovy): ${e}")
}

try {
    if (GENERAL_PARAMETERS) {
        generalParameterElements = GENERAL_PARAMETERS.split(';')
        STANDALONE_MODE = generalParameterElements[4]
    }
} catch(e) {
    println("Something went wrong in the GROOVY block (properties_main_node.groovy): ${e}")
}

try {
    if (STANDALONE_MODE != true) {

        main_node_count = parsedJson.config.vm_properties.main_node_count

        mainNodeCountMin = 1
        mainNodeCountMax = 16
        mainNodeCountStep = 1
        mainNodeCountStartValue = main_node_count.toInteger()
        mainNodeCountOpacity = "1.0"
        mainNodeCountCursor = "pointer"

    } else {

        mainNodeCountMin = 1
        mainNodeCountMax = 1
        mainNodeCountStep = 1
        mainNodeCountStartValue = 1
        mainNodeCountOpacity = "0.1"
        mainNodeCountCursor = "not-allowed"

    }

} catch(e) {
    println("Something went wrong in the GROOVY block (properties_main_node.groovy): ${e}")
}

def main_admin_node_cpu_cores

try {
    main_admin_node_cpu_cores = parsedJson.config.vm_properties.main_admin_node_cpu_cores
} catch(e) {
    println("Something went wrong in the GROOVY block (properties_main_node.groovy): ${e}")
}

int mainNodeCpuCoresMin = 1
int mainNodeCpuCoresMax = 16
int mainNodeCpuCoresStep = 1
int mainNodeCpuCoresStartValue = main_admin_node_cpu_cores.toInteger()
int mainNodeCpuCoresMinWarning = 2
int cpuCoresValueDisplayConversion = 1
def cpuCoresRangeUnit = "Cores"
def mainNodeCpuCoresWarningText = "Warning. Allocating less than 2 cores of CPU to the admin main node may result in a poor experience"
def mainNodeCpuCoresInfoText = "Determines the amount of CPU cores that will be allocated to the KX-Main Admin VM"
def mainNodeCpuCoresParamShortTitle = "CPU Cores"

try {
    extendedDescription = "KX-Main nodes provide two core functions - Kubernetes master services as well as the desktop environment for easy access to deployed tools and documentation. Only the first KX-Main node hosts both the desktop environment, and the Kubernetes Master services. Subsequent KX-Main nodes host the Kubernetes Master services only."
} catch(e) {
    println("Something went wrong in the GROOVY block (properties_main_node.groovy): ${e}")
}

def main_admin_node_memory

try {
    main_admin_node_memory = parsedJson.config.vm_properties.main_admin_node_memory
} catch(e) {
    println("Something went wrong in the GROOVY block (properties_main_node.groovy): ${e}")
}

int mainNodeMemoryMin = 4096
int mainNodeMemoryMax = 32768
int mainNodeMemoryStep = 1024
int mainNodeMemoryStartValue = main_admin_node_memory.toInteger()
int mainNodeMemoryMinWarning = 8192
int memoryValueDisplayConversion = 1024 // Set to 1 for no conversion. Option for display MB as shorter GB form
def memoryRangeUnit = "GB"
def mainNodeMemoryWarningText = "Warning. Allocating less than 8GB of ram to the admin main node may result in a poor experience"
def mainNodeMemoryInfoText = "Determines the amount of memory that will be allocated to the KX-Main Admin VM"
def mainNodeMemoryParamShortTitle = "Memory"


try {
    // language=HTML
    def HTML = """
    <div id="headline-main-div" style="display: none;">
        <h1>Resource Configuration</h1>
        <p>Here you can define how many physical resources you wish to allocate to the KX.AS.CODE virtual machines. The "experience meter" is a rough indication only. 16GB and 4 CPU cores gives you a comfortable performance. After that, the more resources you allocate, the more applications you can install</p>
        <div class="experience-heat-bar-div">
            <span class="experience-heat-bar-title">Experience Meter</span>
            <span id="experience-heat-bar" class="experience-heat-bar">
                <span class="calculated-experience-marker" id="experience-marker"></span>
                <span>
                    <div class="experience-meter-tooltip-info" style="left: -4px;">
                        <span class="info-span">
                            <img src="/userContent/icons/triangle-small-down.svg" class="experience-meter-marker-icon svg-blue" alt="" />
                            <span class="experience-meter-tooltip-text">
                                <div><span class="experience-meter-title">Poor Performance</span><span class="experience-meter-label">CPU</span><span class="experience-meter-value">2 vCores</span class="experience-meter-label"><span class="experience-meter-label">Memory</span><span class="experience-meter-value">8GB</span></div>
                            </span>
                        </span>
                    </div>
                </span>
                <span>
                    <div class="experience-meter-tooltip-info" style="left: 172.5px;">
                        <span class="info-span">
                            <img src="/userContent/icons/triangle-small-down.svg" class="experience-meter-marker-icon svg-blue" alt="" />
                            <span class="experience-meter-tooltip-text">
                                <div><span class="experience-meter-title">Install Multiple Application</span><span class="experience-meter-label">CPU</span><span class="experience-meter-value">4 vCores</span class="experience-meter-label"><span class="experience-meter-label">Memory</span><span class="experience-meter-value">16GB</span></div>
                            </span>
                        </span>
                    </div>
                </span>
                <span>
                    <div class="experience-meter-tooltip-info" style="left: 345px;">
                        <span class="info-span">
                            <img src="/userContent/icons/triangle-small-down.svg" class="experience-meter-marker-icon svg-blue" alt="" />
                            <span class="experience-meter-tooltip-text">
                                <div><span class="experience-meter-title">Install One Application Group</span><span class="experience-meter-label">CPU</span><span class="experience-meter-value">8 vCores</span class="experience-meter-label"><span class="experience-meter-label">Memory</span><span class="experience-meter-value">32GB</span></div>
                            </span>
                        </span>
                    </div>
                </span>
                <span>
                    <div class="experience-meter-tooltip-info" style="left: 517.5px;">
                        <span class="info-span">
                            <img src="/userContent/icons/triangle-small-down.svg" class="experience-meter-marker-icon svg-blue" alt="" />
                            <span class="experience-meter-tooltip-text">
                                <div><span class="experience-meter-title">Install One of Each Group Type</span><span class="experience-meter-label">CPU</span><span class="experience-meter-value">16 vCores</span class="experience-meter-label"><span class="experience-meter-label">Memory</span><span class="experience-meter-value">48GB</span></div>
                            </span>
                        </span>
                    </div>
                </span>
                <span>
                    <div class="experience-meter-tooltip-info" style="left: 680px;">
                        <span class="info-span">
                            <img src="/userContent/icons/triangle-small-down.svg" class="experience-meter-marker-icon svg-blue" alt="" />
                            <span class="experience-meter-tooltip-text">
                                <div><span class="experience-meter-title">Install ALL Application Groups</span><span class="experience-meter-label">CPU</span><span class="experience-meter-value">20 vCores</span class="experience-meter-label"><span class="experience-meter-label">Memory</span><span class="experience-meter-value">64GB</span></div>
                            </span>
                        </span>
                    </div>
                    <div class="experience-meter-tooltip-info">
                        <span class="info-span" id="current-resource-settings-span" style="position: relative;">
                            <img src="/userContent/icons/triangle.svg" class="experience-meter-marker-icon svg-blue" style="width: 20px; height: 20px; top: 1px" alt="current-resource-settings" />
                            <img src="/userContent/icons/triangle.svg" id="triangle-heat-highlight" class="experience-meter-marker-icon" style="width: 13px; height: 13px; top: 2.5px; left: 3.5px; position: relative" />
                            <span class="experience-meter-tooltip-text">
                                <div id="current-resource-settings-div"></div>
                            </span>
                        </span>
                    </div>
                </span>
            </span>    
            <span class="experience-meter-emoji-icon-span"><img src="/userContent/icons/emoji_robot1.png" id="experience-meter-emoji-icon" class="experience-meter-emoji-icon" alt="" /></span>       
        </div>
        <h2 style="margin-top: 20px;">KX-Main Parameters</h2>
        <span class="description-paragraph-span"><p>${extendedDescription }</p></span>
    </div>
    <div class="outerWrapper" id="main-node-count-div" style="display: none;">
        <div class="wrapper">
            <span>
                <img src="/userContent/icons/pound.svg" class="param-icon svg-blue" alt="#" />
            </span>
            <span id="counter_value_main_node_count_value" class="counter-element-value">${mainNodeCountStartValue} ${mainNodeCountRangeUnit}</span>
            <span class="button-range-span">
                <button type="button" class="button-left" style="opacity: ${mainNodeCountOpacity}; cursor: ${mainNodeCountCursor}"
                                                    onclick="subtract_one(&quot;counter_value_main_node_count_previous_value&quot;, &quot;counter_value_main_node_count&quot;, &quot;counter_value_main_node_count_value&quot;, &quot;counter_value_main_node_count_warning_icon&quot;, &quot;${mainNodeCountMinWarning}&quot;, &quot;${mainNodeValueDisplayConversion}&quot;, &quot;${mainNodeCountRangeUnit}&quot;, &quot;${mainNodeCountStep}&quot;, &quot;${mainNodeCountMin}&quot;);"><img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right" style="opacity: ${mainNodeCountOpacity}; cursor: ${mainNodeCountCursor}"
                            onclick="add_one(&quot;counter_value_main_node_count_previous_value&quot;, &quot;counter_value_main_node_count&quot;, &quot;counter_value_main_node_count_value&quot;, &quot;counter_value_main_node_count_warning_icon&quot;, &quot;${mainNodeCountMinWarning}&quot;, &quot;${mainNodeValueDisplayConversion}&quot;, &quot;${mainNodeCountRangeUnit}&quot;, &quot;${mainNodeCountStep}&quot;, &quot;${mainNodeCountMax}&quot;);"><img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info">
                <span class="info-span">
                    <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                    <span class="tooltiptext">${mainNodeInfoText}</span>
                </span>
            </div>
            <span id="counter_value_main_node_count_warning_icon" data-text="${mainNodeCountWarningText}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="warning" />
            </span>                    
        </div>
    </div>
    <style scoped="scoped" onload="show_value(&quot;${mainNodeCountStartValue}&quot;, &quot;counter_value_main_node_count_previous_value&quot;, &quot;counter_value_main_node_count&quot;, &quot;counter_value_main_node_count_value&quot;, &quot;counter_value_main_node_count_warning_icon&quot;, &quot;${mainNodeCountMinWarning}&quot;, &quot;${mainNodeValueDisplayConversion}&quot;, &quot;${mainNodeCountRangeUnit}&quot;);">   </style>
    <input type="hidden" id="counter_value_main_node_count" name="counter_value_main_node_count" value="${mainNodeCountStartValue}">
    <input type="hidden" id="counter_value_main_node_count_previous_value" name="counter_value_main_node_count_previous_value" value="">


    <div class="outerWrapper" id="main-cpu-count-div" style="display: none">
        <div class="wrapper"><span><img src="/userContent/icons/memory.svg" class="param-icon svg-blue" alt="cpu" /></span>
            <span id="slider_value_main_admin_node_cpu_cores_value" class="slider-element-value">${mainNodeCpuCoresStartValue} ${cpuCoresRangeUnit}</span>
            <div id="container">
                <span class="button-range-span">
                    <button type="button" class="button-left"
                        onclick="subtract_one(&quot;slider_value_main_admin_node_cpu_cores_previous_value&quot;, &quot;slider_value_main_admin_node_cpu_cores&quot;, &quot;slider_value_main_admin_node_cpu_cores_value&quot;, &quot;slider_value_main_admin_node_cpu_cores_warning_icon&quot;, &quot;${mainNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;, &quot;${mainNodeCpuCoresStep}&quot;, &quot;${mainNodeCpuCoresMin}&quot;);">
                        <img src="/userContent/icons/minus.svg" alt="minus" class="image-plus-minus svg-white"/>
                    </button>
                </span>
                <span class="input-range-span">
                    <input type="range" min="${mainNodeCpuCoresMin}"
                           max="${mainNodeCpuCoresMax}"
                           step="${mainNodeCpuCoresStep}"
                           value="${mainNodeCpuCoresStartValue}"
                           name="slider_value_main_admin_node_cpu_cores"
                           class="slider"
                           id="slider_value_main_admin_node_cpu_cores"  onchange="show_value(this.value, &quot;slider_value_main_admin_node_cpu_cores_previous_value&quot;, &quot;slider_value_main_admin_node_cpu_cores&quot;, &quot;slider_value_main_admin_node_cpu_cores_value&quot;, &quot;slider_value_main_admin_node_cpu_cores_warning_icon&quot;, &quot;${mainNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);"
                           onmouseleave="show_value(this.value, &quot;slider_value_main_admin_node_cpu_cores_previous_value&quot;, &quot;slider_value_main_admin_node_cpu_cores&quot;, &quot;slider_value_main_admin_node_cpu_cores_value&quot;, &quot;slider_value_main_admin_node_cpu_cores_warning_icon&quot;, &quot;${mainNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);" onmousemove="update_display_value(this.value, &quot;slider_value_main_admin_node_cpu_cores_value&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);">
                </span>
                <span class="button-range-span">
                    <button type="button" class="button-right"
                        onclick="add_one(&quot;slider_value_main_admin_node_cpu_cores_previous_value&quot;, &quot;slider_value_main_admin_node_cpu_cores&quot;, &quot;slider_value_main_admin_node_cpu_cores_value&quot;, &quot;slider_value_main_admin_node_cpu_cores_warning_icon&quot;, &quot;${mainNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;, &quot;${mainNodeCpuCoresStep}&quot;, &quot;${mainNodeCpuCoresMax}&quot;);">
                        <img src="/userContent/icons/plus.svg" alt="plus" class="image-plus-minus svg-white"/>
                    </button>
                </span>
                <div class="tooltip-info">
                    <span class="info-span">
                        <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                    </span>
                    <span class="tooltiptext">${mainNodeCpuCoresInfoText}</span>
                </div>  
                <span id="slider_value_main_admin_node_cpu_cores_warning_icon" data-text="${mainNodeCpuCoresWarningText}" class="warning-span tooltip">
                    <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="warning" />
                </span>
            </div>
        </div>
    </div>
    <style scoped="scoped" onload="show_value(&quot;${mainNodeCpuCoresStartValue}&quot;, &quot;slider_value_main_admin_node_cpu_cores_previous_value&quot;, &quot;slider_value_main_admin_node_cpu_cores&quot;, &quot;slider_value_main_admin_node_cpu_cores_value&quot;, &quot;slider_value_main_admin_node_cpu_cores_warning_icon&quot;, &quot;${mainNodeCpuCoresMinWarning}&quot;, &quot;${cpuCoresValueDisplayConversion}&quot;, &quot;${cpuCoresRangeUnit}&quot;);">   </style>
    <input type="hidden" id="slider_value_main_admin_node_cpu_cores_previous_value" name="slider_value_main_admin_node_cpu_cores_previous_value" value="" >


    <div class="outerWrapper" id="main-memory-div" style="display: none">
        <div class="wrapper"><span><img src="/userContent/icons/memory-solid.svg" class="param-icon svg-blue" alt="cpu" /></span>

            <span id="slider_value_main_admin_node_memory_value" class="slider-element-value">${mainNodeMemoryStartValue} ${memoryRangeUnit}</span>
            <div id="container"><span class="button-range-span"><button type="button" class="button-left"
            onclick="subtract_one(&quot;slider_value_main_admin_node_memory_previous_value&quot;, &quot;slider_value_main_admin_node_memory&quot;, &quot;slider_value_main_admin_node_memory_value&quot;, &quot;slider_value_main_admin_node_memory_warning_icon&quot;, &quot;${mainNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;, &quot;${mainNodeMemoryStep}&quot;, &quot;${mainNodeMemoryMin}&quot;);"><img src="/userContent/icons/minus.svg" alt="minus" class="image-plus-minus svg-white"/></button></span> <span class="input-range-span">
            <input type="range" min="${mainNodeMemoryMin}"
                   max="${mainNodeMemoryMax}"
                   step="${mainNodeMemoryStep}"
                   value="${mainNodeMemoryStartValue}"
                   name="slider_value_main_admin_node_memory"
                   class="slider"
                   id="slider_value_main_admin_node_memory" onchange="show_value(this.value, &quot;slider_value_main_admin_node_memory_previous_value&quot;, &quot;slider_value_main_admin_node_memory&quot;, &quot;slider_value_main_admin_node_memory_value&quot;, &quot;slider_value_main_admin_node_memory_warning_icon&quot;, &quot;${mainNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);"
                   onmouseleave="show_value(this.value, &quot;slider_value_main_admin_node_memory_previous_value&quot;, &quot;slider_value_main_admin_node_memory&quot;, &quot;slider_value_main_admin_node_memory_value&quot;, &quot;slider_value_main_admin_node_memory_warning_icon&quot;, &quot;${mainNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);" onmousemove="update_display_value(this.value, &quot;slider_value_main_admin_node_memory_value&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);">
              </span>
                <span class="button-range-span"><button type="button" class="button-right"
                    onclick="add_one(&quot;slider_value_main_admin_node_memory_previous_value&quot;, &quot;slider_value_main_admin_node_memory&quot;, &quot;slider_value_main_admin_node_memory_value&quot;, &quot;slider_value_main_admin_node_memory_warning_icon&quot;, &quot;${mainNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;, &quot;${mainNodeMemoryStep}&quot;, &quot;${mainNodeMemoryMax}&quot;);"><img src="/userContent/icons/plus.svg" alt="plus" class="image-plus-minus svg-white"/></button></span>
                <div class="tooltip-info">
                    <span class="info-span">
                        <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                    </span>
                    <span class="tooltiptext">${mainNodeMemoryInfoText}</span>
                </div>  
                <span id="slider_value_main_admin_node_memory_warning_icon" data-text="${mainNodeMemoryWarningText}" class="warning-span tooltip">
                    <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="warning" />
                </span>
            </div>
        </div>
    </div>
    <style scoped="scoped" onload="show_value(&quot;${mainNodeMemoryStartValue}&quot;, &quot;slider_value_main_admin_node_memory_previous_value&quot;, &quot;slider_value_main_admin_node_memory&quot;, &quot;slider_value_main_admin_node_memory_value&quot;, &quot;slider_value_main_admin_node_memory_warning_icon&quot;, &quot;${mainNodeMemoryMinWarning}&quot;, &quot;${memoryValueDisplayConversion}&quot;, &quot;${memoryRangeUnit}&quot;);">   </style>
    <style scoped="scoped" onload="calculateHeatmapScalePosition()">   </style>
    <input type="hidden" id="slider_value_main_admin_node_memory_previous_value" name="slider_value_main_admin_node_memory_previous_value" value="" >
    <input type="hidden" id="concatenated_value_main_node_config" name="value" value="" >

    """
    return HTML
} catch (e) {
    println("Something went wrong in the HTML return block (properties_main_node.groovy): ${e}")
}
