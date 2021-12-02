import groovy.json.JsonSlurper

def main_admin_node_cpu_cores

try {
    def jsonFilePath = PROFILE
    def inputFile = new File(jsonFilePath)
    def parsedJson = new JsonSlurper().parse(inputFile)

    main_admin_node_cpu_cores = parsedJson.config.vm_properties.main_admin_node_cpu_cores

    println("Profile: " + PROFILE)
    println("CPU Cores read: " + main_admin_node_cpu_cores)
} catch(e) {
    println "Something went wrong in the GROOVY block (config_vm_properties_main_admin_node_cpu_cores): ${e}"
}

int min = 1
int max = 16
int step = 1
int startValue = main_admin_node_cpu_cores.toInteger()
int minWarning = 2
int valueDisplayConversion = 1
def rangeUnit = "Cores"
def warningText = "Warning. Allocating less than 2 cores of CPU to the admin main node may result in a poor experience"
def infoText = "Determines the amount of CPU cores that will be allocated to the KX-Main Admin VM"
def paramIcon = "/userContent/icons/memory.svg"
def paramShortTitle = "CPU Cores"
def variablesSuffix = "main_admin_node_cpu_cores"
def sliderElementRangeId = "slider_value_${variablesSuffix}"
def sliderElementValueId = "${sliderElementRangeId}_value"
def sliderElementPreviousValueId = "${sliderElementRangeId}_previous_value"
def warningTextElementId = "${sliderElementRangeId}_warning"
def warningIconElementId = "${sliderElementRangeId}_warning_icon"


try {
    // language=HTML
    def HTML = """
    <body>
    <div class="outerWrapper" id="main-cpu-count-div" style="display: none">
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
    println "Something went wrong in the HTML return block (config_vm_properties_main_admin_node_cpu_cores): ${e}"
}
