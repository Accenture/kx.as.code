import groovy.json.JsonSlurper

def glusterfs_storage

try {
    def jsonFilePath = PROFILE
    def inputFile = new File(jsonFilePath)
    def parsedJson = new JsonSlurper().parse(inputFile)

    glusterfs_storage = parsedJson.config.glusterFsDiskSize
} catch(e) {
    println "Something went wrong in the GROOVY block (config_network_storage): ${e}"
}

int min = 20
int max = 1000
int step = 1
int startValue = glusterfs_storage.toInteger()
int minWarning = 50
int valueDisplayConversion = 1 // Set to 1 for no conversion. Option for display MB as shorter GB form
def rangeUnit = "GB"
def warningText = "Warning. Allocating less than ${minWarning}GB of network storage may limit your options"
def infoText = "Determines the amount of storage allocated to the GlusterFS storage. The storage will be used gradually, so it is possible to over-allocate"
def paramIcon = "/userContent/icons/server-network.svg"
def paramShortTitle = "GlusterFS Storage"
def variablesSuffix = "glusterfs_storage"
def sliderElementRangeId = "slider_value_${variablesSuffix}"
def sliderElementValueId = "${sliderElementRangeId}_value"
def sliderElementPreviousValueId = "${sliderElementRangeId}_previous_value"
def warningTextElementId = "${sliderElementRangeId}_warning"
def warningIconElementId = "${sliderElementRangeId}_warning_icon"

try {
    // language=HTML
    def HTML = """
    <body>
    <div class="outerWrapper" id="network-storage-div" style="display: block;">
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
    println "Something went wrong in the HTML return block (config_network_storage): ${e}"
}
