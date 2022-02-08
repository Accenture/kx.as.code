import groovy.json.JsonSlurper

def extendedDescription
def network_storage
def localStorageNumOneGb
def localStorageNumFiveGb
def localStorageNumTenGb
def localStorageNumThirtyGb
def localStorageNumFiftyGb

try {
    extendedDescription = "There are two types of storage provisioned into KX.AS.CODE. One is a slower network storage based on GlusterFS and the second is local storage. Both are made available internally to the Kubernetes cluster via storage classes. There are advantages and disadvantages of each. Glusterfs is slower, but ensures the workload remains portable. Local storage is faster, but means a workload is tied to a host. The faster local storage is recommended for database servers."

    def jsonFilePath = PROFILE
    def inputFile = new File(jsonFilePath)
    def parsedJson = new JsonSlurper().parse(inputFile)

    network_storage = parsedJson.config.glusterFsDiskSize
    localStorageNumOneGb = parsedJson.config.local_volumes.one_gb
    localStorageNumFiveGb = parsedJson.config.local_volumes.five_gb
    localStorageNumTenGb = parsedJson.config.local_volumes.ten_gb
    localStorageNumThirtyGb = parsedJson.config.local_volumes.thirty_gb
    localStorageNumFiftyGb = parsedJson.config.local_volumes.fifty_gb
} catch(e) {
    println "Something went wrong in the GROOVY block (storage_parameters.groovy): ${e}"
}

int networkStorageMin = 20
int networkStorageMax = 1000
int networkStorageStep = 1
int networkStorageStartValue = network_storage.toInteger()
int networkStorageMinWarning = 50
int networkStorageValueDisplayConversion = 1 // Set to 1 for no conversion. Option for display MB as shorter GB form
def networkStorageRangeUnit = "GB"
def networkStorageWarningText = "Warning. Allocating less than ${networkStorageMinWarning}GB of network storage may limit your options"
def networkStorageInfoText = "Determines the amount of storage allocated to the GlusterFS storage. The storage will be used gradually, so it is possible to over-allocate"
def networkStorageParamShortTitle = "GlusterFS Storage"

int startValueOneGb = localStorageNumOneGb.toInteger()
int startValueFiveGb = localStorageNumFiveGb.toInteger()
int startValueTenGb = localStorageNumTenGb.toInteger()
int startValueThirtyGb = localStorageNumThirtyGb.toInteger()
int startValueFiftyGb = localStorageNumFiftyGb.toInteger()

int minOneGb = 1
int maxOneGb = 20
int minWarningOneGb = 5 // Set to 0 to disable the minimum warning

int minFiveGb = 1
int maxFiveGb = 20
int minWarningFiveGb = 5 // Set to 0 to disable the minimum warning

int minTenGb = 1
int maxTenGb = 20
int minWarningTenGb = 5 // Set to 0 to disable the minimum warning

int minThirtyGb = 0
int maxThirtyGb = 10
int minWarningThirtyGb = 0 // Set to 0 to disable the minimum warning

int minFiftyGb = 0
int maxFiftyGb = 10
int minWarningFiftyGb = 0 // Set to 0 to disable the minimum warning

int localStorageDisplayConversion = 1 // Set to 1 for no conversion (eg. from MB to GB)
def localStorageStep = 1
def localStorageRangeUnit = " Volumes"
def localStorageParamShortTitle = "# of volumes"

def infoTextOneGb = "Determines the number of 1GB volumes that will be available for allocating to workloads"
def infoTextFiveGb = "Determines the number of 5GB volumes that will be available for allocating to workloads"
def infoTextTenGb = "Determines the number of 10GB volumes that will be available for allocating to workloads"
def infoTextThirtyGb = "Determines the number of 30GB volumes that will be available for allocating to workloads"
def infoTextFiftyGb = "Determines the number of 50GB volumes that will be available for allocating to workloads"

def warningTextOneGb = "Determines the number of 1GB volumes that will be available for allocating to workloads"
def warningTextFiveGb = "Determines the number of 5GB volumes that will be available for allocating to workloads"
def warningTextTenGb = "Determines the number of 10GB volumes that will be available for allocating to workloads"
def warningTextThirtyGb = "Determines the number of 30GB volumes that will be available for allocating to workloads"
def warningTextFiftyGb = "Determines the number of 50GB volumes that will be available for allocating to workloads"

try {
    // language=HTML
    def HTML = """
        <div id="headline-storage-div" style="display: none;">
        <h2>Storage Parameters</h2>
        <span class="description-paragraph-span"><p>${extendedDescription}</p></span>
        </div>
    
        <div class="outerWrapper" id="network-storage-div" style="display: none;">
        <div class="wrapper"><span><img src="/userContent/icons/server-network.svg" class="param-icon svg-purple" alt="cpu" /></span>

            <span id="slider_value_network_storage_value" class="slider-element-value">${networkStorageStartValue} ${networkStorageRangeUnit}</span>
            <div id="container"><span class="button-range-span"><button type="button" class="button-left"
                                                                        onclick="subtract_one(&quot;slider_value_network_storage_previous_value&quot;, &quot;slider_value_network_storage&quot;, &quot;slider_value_network_storage_value&quot;, &quot;slider_value_network_storage_warning_icon&quot;, &quot;${networkStorageMinWarning}&quot;, &quot;${networkStorageValueDisplayConversion}&quot;, &quot;${networkStorageRangeUnit}&quot;, &quot;${networkStorageStep}&quot;, &quot;${networkStorageMin}&quot;);"><img src="/userContent/icons/minus.svg" alt="minus" class="image-plus-minus svg-white"/></button></span> <span class="input-range-span">
            <input type="range" min="${networkStorageMin}"
                   max="${networkStorageMax}"
                   step="${networkStorageStep}"
                   value="${networkStorageStartValue}"
                   name="network_storage_slider"
                   class="slider"
                   id="slider_value_network_storage"  onchange="show_value(this.value, &quot;slider_value_network_storage_previous_value&quot;, &quot;slider_value_network_storage&quot;, &quot;slider_value_network_storage_value&quot;, &quot;slider_value_network_storage_warning_icon&quot;, &quot;${networkStorageMinWarning}&quot;, &quot;${networkStorageValueDisplayConversion}&quot;, &quot;${networkStorageRangeUnit}&quot;);"
                   onmouseleave="show_value(this.value, &quot;slider_value_network_storage_previous_value&quot;, &quot;slider_value_network_storage&quot;, &quot;slider_value_network_storage_value&quot;, &quot;slider_value_network_storage_warning_icon&quot;, &quot;${networkStorageMinWarning}&quot;, &quot;${networkStorageValueDisplayConversion}&quot;, &quot;${networkStorageRangeUnit}&quot;);" onmousemove="update_display_value(this.value, &quot;slider_value_network_storage_value&quot;, &quot;${networkStorageValueDisplayConversion}&quot;, &quot;${networkStorageRangeUnit}&quot;);">
              </span>
                <span class="button-range-span"><button type="button" class="button-right"
                                                        onclick="add_one(&quot;slider_value_network_storage_previous_value&quot;, &quot;slider_value_network_storage&quot;, &quot;slider_value_network_storage_value&quot;, &quot;slider_value_network_storage_warning_icon&quot;, &quot;${networkStorageMinWarning}&quot;, &quot;${networkStorageValueDisplayConversion}&quot;, &quot;${networkStorageRangeUnit}&quot;, &quot;${networkStorageStep}&quot;, &quot;${networkStorageMax}&quot;);"><img src="/userContent/icons/plus.svg" alt="plus" class="image-plus-minus svg-white"/></button></span>
                <span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="${networkStorageInfoText}"></span><span id="slider_value_network_storage_warning_icon" data-text="${networkStorageWarningText}" class="warning-span tooltip"><img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="cpu" /></span>

            </div>
        </div>
    </div>
    <style scoped="scoped" onload="show_value(&quot;${networkStorageStartValue}&quot;, &quot;slider_value_network_storage_previous_value&quot;, &quot;slider_value_network_storage&quot;, &quot;slider_value_network_storage_value&quot;, &quot;slider_value_network_storage_warning_icon&quot;, &quot;${networkStorageMinWarning}&quot;, &quot;${networkStorageValueDisplayConversion}&quot;, &quot;${networkStorageRangeUnit}&quot;);">   </style>
    <input type="hidden" id="slider_value_network_storage_previous_value" name="slider_value_network_storage_previous_value" value="" >
    
        <div id="local-storage-div" style="display: none;">

    <div class="wrapper"><span><img src="/userContent/icons/harddisk.svg" class="param-icon svg-purple" alt="#" /></span><h4>Local Storage Profile Parameters</h4></div>
    <p></p>

    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">1 GB</span>
            <span class="indented-bullet-span"><img src="/userContent/icons/chevron-right.svg" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="counter_value_local_volume_count_1_gb" class="counter-local-storage-value">${startValueOneGb} ${localStorageRangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
            onclick="subtract_one(&quot;counter_value_local_volume_count_1_gb_value_previous&quot;, &quot;counter_value_local_volume_count_1_gb&quot;, &quot;counter_value_local_volume_count_1_gb&quot;, &quot;counter_value_local_volume_count_1_gb_warning_icon&quot;, &quot;${minWarningOneGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${minOneGb}&quot;);">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                    onclick="add_one(&quot;counter_value_local_volume_count_1_gb_value_previous&quot;, &quot;counter_value_local_volume_count_1_gb&quot;, &quot;counter_value_local_volume_count_1_gb&quot;, &quot;counter_value_local_volume_count_1_gb_warning_icon&quot;, &quot;${minWarningOneGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${maxOneGb}&quot;);">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextOneGb}</span>
            </span>
            </div>
            <span id="counter_value_local_volume_count_1_gb_warning_icon" data-text="${warningTextOneGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="counter_value_local_volume_count_1_gb" name="counter_value_local_volume_count_1_gb" value="${startValueOneGb}">
    <input type="hidden" id="counter_value_local_volume_count_1_gb_value_previous" name="counter_value_local_volume_count_1_gb_value_previous" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueOneGb}&quot;, &quot;counter_value_local_volume_count_1_gb_value_previous&quot;, &quot;counter_value_local_volume_count_1_gb&quot;, &quot;counter_value_local_volume_count_1_gb&quot;, &quot;counter_value_local_volume_count_1_gb_warning_icon&quot;, &quot;${minWarningOneGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;);">   </style>
    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">5 GB</span>
            <span class="indented-bullet-span"><img src="/userContent/icons/chevron-right.svg" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="counter_value_local_volume_count_5_gb" class="counter-local-storage-value">${startValueFiveGb} ${localStorageRangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;counter_value_local_volume_count_5_gb_value_previous&quot;, &quot;counter_value_local_volume_count_5_gb&quot;, &quot;counter_value_local_volume_count_5_gb&quot;, &quot;counter_value_local_volume_count_5_gb_warning_icon&quot;, &quot;${minWarningFiveGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${minFiveGb}&quot;);">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;counter_value_local_volume_count_5_gb_value_previous&quot;, &quot;counter_value_local_volume_count_5_gb&quot;, &quot;counter_value_local_volume_count_5_gb&quot;, &quot;counter_value_local_volume_count_5_gb_warning_icon&quot;, &quot;${minWarningFiveGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${maxFiveGb}&quot;);">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextFiveGb}</span>
            </span>
            </div>
            <span id="counter_value_local_volume_count_5_gb_warning_icon" data-text="${warningTextFiveGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="counter_value_local_volume_count_5_gb" name="counter_value_local_volume_count_5_gb" value="${startValueFiveGb}">
    <input type="hidden" id="counter_value_local_volume_count_5_gb_value_previous" name="counter_value_local_volume_count_5_gb_value_previous" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueFiveGb}&quot;, &quot;counter_value_local_volume_count_5_gb_value_previous&quot;, &quot;counter_value_local_volume_count_5_gb&quot;, &quot;counter_value_local_volume_count_5_gb&quot;, &quot;counter_value_local_volume_count_5_gb_warning_icon&quot;, &quot;${minWarningFiveGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;);">   </style>
    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">10 GB</span>
            <span class="indented-bullet-span"><img src="/userContent/icons/chevron-right.svg" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="counter_value_local_volume_count_10_gb" class="counter-local-storage-value">${startValueTenGb} ${localStorageRangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;counter_value_local_volume_count_10_gb_value_previous&quot;, &quot;counter_value_local_volume_count_10_gb&quot;, &quot;counter_value_local_volume_count_10_gb&quot;, &quot;counter_value_local_volume_count_10_gb_warning_icon&quot;, &quot;${minWarningTenGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${minTenGb}&quot;);">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;counter_value_local_volume_count_10_gb_value_previous&quot;, &quot;counter_value_local_volume_count_10_gb&quot;, &quot;counter_value_local_volume_count_10_gb&quot;, &quot;counter_value_local_volume_count_10_gb_warning_icon&quot;, &quot;${minWarningTenGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${maxTenGb}&quot;);">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextTenGb}</span>
            </span>
            </div>
            <span id="counter_value_local_volume_count_10_gb_warning_icon" data-text="${warningTextTenGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="counter_value_local_volume_count_10_gb" name="counter_value_local_volume_count_10_gb" value="${startValueTenGb}">
    <input type="hidden" id="counter_value_local_volume_count_10_gb_value_previous" name="counter_value_local_volume_count_10_gb_value_previous" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueTenGb}&quot;, &quot;counter_value_local_volume_count_10_gb_value_previous&quot;, &quot;counter_value_local_volume_count_10_gb&quot;, &quot;counter_value_local_volume_count_10_gb&quot;, &quot;counter_value_local_volume_count_10_gb_warning_icon&quot;, &quot;${minWarningTenGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;);">   </style>

    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">30 GB</span>
            <span class="indented-bullet-span"><img src="/userContent/icons/chevron-right.svg" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="counter_value_local_volume_count_30_gb" class="counter-local-storage-value">${startValueThirtyGb} ${localStorageRangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;counter_value_local_volume_count_30_gb_value_previous&quot;, &quot;counter_value_local_volume_count_30_gb&quot;, &quot;counter_value_local_volume_count_30_gb&quot;, &quot;counter_value_local_volume_count_30_gb_warning_icon&quot;, &quot;${minWarningThirtyGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${minThirtyGb}&quot;);">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;counter_value_local_volume_count_30_gb_value_previous&quot;, &quot;counter_value_local_volume_count_30_gb&quot;, &quot;counter_value_local_volume_count_30_gb&quot;, &quot;counter_value_local_volume_count_30_gb_warning_icon&quot;, &quot;${minWarningThirtyGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${maxThirtyGb}&quot;);">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextThirtyGb}</span>
            </span>
            </div>
            <span id="counter_value_local_volume_count_30_gb_warning_icon" data-text="${warningTextThirtyGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="counter_value_local_volume_count_30_gb" name="counter_value_local_volume_count_30_gb" value="${startValueThirtyGb}">
    <input type="hidden" id="counter_value_local_volume_count_30_gb_value_previous" name="counter_value_local_volume_count_30_gb_value_previous" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueThirtyGb}&quot;, &quot;counter_value_local_volume_count_30_gb_value_previous&quot;, &quot;counter_value_local_volume_count_30_gb&quot;, &quot;counter_value_local_volume_count_30_gb&quot;, &quot;counter_value_local_volume_count_30_gb_warning_icon&quot;, &quot;${minWarningThirtyGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;);">   </style>
    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">50 GB</span>
            <span class="indented-bullet-span"><img src="/userContent/icons/chevron-right.svg" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="counter_value_local_volume_count_50_gb" class="counter-local-storage-value">${startValueFiftyGb} ${localStorageRangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;counter_value_local_volume_count_50_gb_value_previous&quot;, &quot;counter_value_local_volume_count_50_gb&quot;, &quot;counter_value_local_volume_count_50_gb&quot;, &quot;counter_value_local_volume_count_50_gb_warning_icon&quot;, &quot;${minWarningFiftyGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${minFiftyGb}&quot;);">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;counter_value_local_volume_count_50_gb_value_previous&quot;, &quot;counter_value_local_volume_count_50_gb&quot;, &quot;counter_value_local_volume_count_50_gb&quot;, &quot;counter_value_local_volume_count_50_gb_warning_icon&quot;, &quot;${minWarningFiftyGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;, &quot;${localStorageStep}&quot;, &quot;${maxFiftyGb}&quot;);">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextFiftyGb}</span>
            </span>
            </div>
            <span id="counter_value_local_volume_count_50_gb_warning_icon" data-text="${warningTextFiftyGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="counter_value_local_volume_count_50_gb" name="counter_value_local_volume_count_50_gb" value="${startValueFiftyGb}">
    <input type="hidden" id="counter_value_local_volume_count_50_gb_value_previous" name="counter_value_local_volume_count_50_gb_value_previous" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueFiftyGb}&quot;, &quot;counter_value_local_volume_count_50_gb_value_previous&quot;, &quot;counter_value_local_volume_count_50_gb&quot;, &quot;counter_value_local_volume_count_50_gb&quot;, &quot;counter_value_local_volume_count_50_gb_warning_icon&quot;, &quot;${minWarningFiftyGb}&quot;, &quot;${localStorageDisplayConversion}&quot;, &quot;${localStorageRangeUnit}&quot;);">   </style>
    <!-- --->

    <input type="hidden" id="concatenated-storage-params" name="value" value="" >

    </div>

    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (storage_parameters.groovy): ${e}"
}
