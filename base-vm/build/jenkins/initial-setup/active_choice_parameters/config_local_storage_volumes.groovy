import groovy.json.JsonSlurper

def parsedJson

try {
    def jsonFilePath = PROFILE
    def inputFile = new File(jsonFilePath)
    parsedJson = new JsonSlurper().parse(inputFile)
} catch(e) {
    println "Something went wrong in the GROOVY block (config_local_storage_volumes): ${e}"
}
    def localStorageNumOneGb = parsedJson.config.local_volumes.one_gb
    def localStorageNumFiveGb = parsedJson.config.local_volumes.five_gb
    def localStorageNumTenGb = parsedJson.config.local_volumes.ten_gb
    def localStorageNumThirtyGb = parsedJson.config.local_volumes.thirty_gb
    def localStorageNumFiftyGb = parsedJson.config.local_volumes.fifty_gb

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

    int valueDisplayConversion = 1 // Set to 1 for no conversion (eg. from MB to GB)
    def step = 1
    def rangeUnit = " Volumes"
    def iconLocationPath = "/userContent/icons"
    def paramIcon = "${iconLocationPath}/harddisk.svg"
    def bulletIcon = "${iconLocationPath}/chevron-right.svg"
    def paramShortTitle = "# of volumes"

    int startValueOneGb = localStorageNumOneGb.toInteger()
    int startValueFiveGb = localStorageNumFiveGb.toInteger()
    int startValueTenGb = localStorageNumTenGb.toInteger()
    int startValueThirtyGb = localStorageNumThirtyGb.toInteger()
    int startValueFiftyGb = localStorageNumFiftyGb.toInteger()

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

    def variablesSuffixOneGb = "local_volume_count_1_gb"
    def counterHiddenValueIdOneGb = "counter_value_${variablesSuffixOneGb}"
    def counterElementValueIdOneGb = "${counterHiddenValueIdOneGb}_value"
    def counterElementPreviousValueIdOneGb = "${counterHiddenValueIdOneGb}_value_previous"
    def warningTextElementIdOneGb = "${counterHiddenValueIdOneGb}_warning"
    def warningIconElementIdOneGb = "${counterHiddenValueIdOneGb}_warning_icon"

    def variablesSuffixFiveGb = "local_volume_count_5_gb"
    def counterHiddenValueIdFiveGb = "counter_value_${variablesSuffixFiveGb}"
    def counterElementValueIdFiveGb = "${counterHiddenValueIdFiveGb}_value"
    def counterElementPreviousValueIdFiveGb = "${counterHiddenValueIdFiveGb}_value_previous"
    def warningTextElementIdFiveGb = "${counterHiddenValueIdFiveGb}_warning"
    def warningIconElementIdFiveGb = "${counterHiddenValueIdFiveGb}_warning_icon"

    def variablesSuffixTenGb = "local_volume_count_10_gb"
    def counterHiddenValueIdTenGb = "counter_value_${variablesSuffixTenGb}"
    def counterElementValueIdTenGb = "${counterHiddenValueIdTenGb}_value"
    def counterElementPreviousValueIdTenGb = "${counterHiddenValueIdTenGb}_value_previous"
    def warningTextElementIdTenGb = "${counterHiddenValueIdTenGb}_warning"
    def warningIconElementIdTenGb = "${counterHiddenValueIdTenGb}_warning_icon"

    def variablesSuffixThirtyGb = "local_volume_count_30_gb"
    def counterHiddenValueIdThirtyGb = "counter_value_${variablesSuffixThirtyGb}"
    def counterElementValueIdThirtyGb = "${variablesSuffixThirtyGb}_value"
    def counterElementPreviousValueIdThirtyGb = "${variablesSuffixThirtyGb}_value_previous"
    def warningTextElementIdThirtyGb = "${variablesSuffixThirtyGb}_warning"
    def warningIconElementIdThirtyGb = "${variablesSuffixThirtyGb}_warning_icon"

    def variablesSuffixFiftyGb = "local_volume_count_50_gb"
    def counterHiddenValueIdFiftyGb = "counter_value_${variablesSuffixFiftyGb}"
    def counterElementValueIdFiftyGb = "${counterHiddenValueIdFiftyGb}_value"
    def counterElementPreviousValueIdFiftyGb = "${counterHiddenValueIdFiftyGb}_value_previous"
    def warningTextElementIdFiftyGb = "${counterHiddenValueIdFiftyGb}_warning"
    def warningIconElementIdFiftyGb = "${counterHiddenValueIdFiftyGb}_warning_icon"

try {
    // language=HTML
    def HTML = """
    <body>
    <div id="local-storage-div" style="display: none;">

    <div class="wrapper"><span><img src="${paramIcon}" class="param-icon svg-purple" alt="#" /></span><h4>Local Storage Profile Parameters</h4></div>
    <p></p>

    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">1 GB</span>
            <span class="indented-bullet-span"><img src="${bulletIcon}" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="${counterElementValueIdOneGb}" class="counter-local-storage-value">${startValueOneGb} ${rangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
            onclick="subtract_one(&quot;${counterElementPreviousValueIdOneGb}&quot;, &quot;${counterHiddenValueIdOneGb}&quot;, &quot;${counterElementValueIdOneGb}&quot;, &quot;${warningIconElementIdOneGb}&quot;, &quot;${minWarningOneGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${minOneGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                    onclick="add_one(&quot;${counterElementPreviousValueIdOneGb}&quot;, &quot;${counterHiddenValueIdOneGb}&quot;, &quot;${counterElementValueIdOneGb}&quot;, &quot;${warningIconElementIdOneGb}&quot;, &quot;${minWarningOneGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${maxOneGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextOneGb}</span>
            </span>
            </div>
            <span id="${warningIconElementIdOneGb}" data-text="${warningTextOneGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="${counterHiddenValueIdOneGb}" name="${counterHiddenValueIdOneGb}" value="${startValueOneGb}">
    <input type="hidden" id="${counterElementPreviousValueIdOneGb}" name="${counterElementPreviousValueIdOneGb}" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueOneGb}&quot;, &quot;${counterElementPreviousValueIdOneGb}&quot;, &quot;${counterHiddenValueIdOneGb}&quot;, &quot;${counterElementValueIdOneGb}&quot;, &quot;${warningIconElementIdOneGb}&quot;, &quot;${minWarningOneGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;); updateConcatenatedLocalStorageReturnVariable();">   </style>
    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">5 GB</span>
            <span class="indented-bullet-span"><img src="${bulletIcon}" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="${counterElementValueIdFiveGb}" class="counter-local-storage-value">${startValueFiveGb} ${rangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;${counterElementPreviousValueIdFiveGb}&quot;, &quot;${counterHiddenValueIdFiveGb}&quot;, &quot;${counterElementValueIdFiveGb}&quot;, &quot;${warningIconElementIdFiveGb}&quot;, &quot;${minWarningFiveGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${minFiveGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;${counterElementPreviousValueIdFiveGb}&quot;, &quot;${counterHiddenValueIdFiveGb}&quot;, &quot;${counterElementValueIdFiveGb}&quot;, &quot;${warningIconElementIdFiveGb}&quot;, &quot;${minWarningFiveGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${maxFiveGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextFiveGb}</span>
            </span>
            </div>
            <span id="${warningIconElementIdFiveGb}" data-text="${warningTextFiveGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="${counterHiddenValueIdFiveGb}" name="${counterHiddenValueIdFiveGb}" value="${startValueFiveGb}">
    <input type="hidden" id="${counterElementPreviousValueIdFiveGb}" name="${counterElementPreviousValueIdFiveGb}" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueFiveGb}&quot;, &quot;${counterElementPreviousValueIdFiveGb}&quot;, &quot;${counterHiddenValueIdFiveGb}&quot;, &quot;${counterElementValueIdFiveGb}&quot;, &quot;${warningIconElementIdFiveGb}&quot;, &quot;${minWarningFiveGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;); updateConcatenatedLocalStorageReturnVariable();">   </style>
    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">10 GB</span>
            <span class="indented-bullet-span"><img src="${bulletIcon}" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="${counterElementValueIdTenGb}" class="counter-local-storage-value">${startValueTenGb} ${rangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;${counterElementPreviousValueIdTenGb}&quot;, &quot;${counterHiddenValueIdTenGb}&quot;, &quot;${counterElementValueIdTenGb}&quot;, &quot;${warningIconElementIdTenGb}&quot;, &quot;${minWarningTenGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${minTenGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;${counterElementPreviousValueIdTenGb}&quot;, &quot;${counterHiddenValueIdTenGb}&quot;, &quot;${counterElementValueIdTenGb}&quot;, &quot;${warningIconElementIdTenGb}&quot;, &quot;${minWarningTenGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${maxTenGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextTenGb}</span>
            </span>
            </div>
            <span id="${warningIconElementIdTenGb}" data-text="${warningTextTenGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="${counterHiddenValueIdTenGb}" name="${counterHiddenValueIdTenGb}" value="${startValueTenGb}">
    <input type="hidden" id="${counterElementPreviousValueIdTenGb}" name="${counterElementPreviousValueIdTenGb}" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueTenGb}&quot;, &quot;${counterElementPreviousValueIdTenGb}&quot;, &quot;${counterHiddenValueIdTenGb}&quot;, &quot;${counterElementValueIdTenGb}&quot;, &quot;${warningIconElementIdTenGb}&quot;, &quot;${minWarningTenGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;); updateConcatenatedLocalStorageReturnVariable();">   </style>

    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">30 GB</span>
            <span class="indented-bullet-span"><img src="${bulletIcon}" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="${counterElementValueIdThirtyGb}" class="counter-local-storage-value">${startValueThirtyGb} ${rangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;${counterElementPreviousValueIdThirtyGb}&quot;, &quot;${counterHiddenValueIdThirtyGb}&quot;, &quot;${counterElementValueIdThirtyGb}&quot;, &quot;${warningIconElementIdThirtyGb}&quot;, &quot;${minWarningThirtyGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${minThirtyGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;${counterElementPreviousValueIdThirtyGb}&quot;, &quot;${counterHiddenValueIdThirtyGb}&quot;, &quot;${counterElementValueIdThirtyGb}&quot;, &quot;${warningIconElementIdThirtyGb}&quot;, &quot;${minWarningThirtyGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${maxThirtyGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextThirtyGb}</span>
            </span>
            </div>
            <span id="${warningIconElementIdThirtyGb}" data-text="${warningTextThirtyGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="${counterHiddenValueIdThirtyGb}" name="${counterHiddenValueIdThirtyGb}" value="${startValueThirtyGb}">
    <input type="hidden" id="${counterElementPreviousValueIdThirtyGb}" name="${counterElementPreviousValueIdThirtyGb}" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueThirtyGb}&quot;, &quot;${counterElementPreviousValueIdThirtyGb}&quot;, &quot;${counterHiddenValueIdThirtyGb}&quot;, &quot;${counterElementValueIdThirtyGb}&quot;, &quot;${warningIconElementIdThirtyGb}&quot;, &quot;${minWarningThirtyGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;); updateConcatenatedLocalStorageReturnVariable();">   </style>
    <!-- --->


    <!-- --->
    <div class="outerWrapper">
        <div class="storage-wrapper">
            <span class="rounded-number-span">50 GB</span>
            <span class="indented-bullet-span"><img src="${bulletIcon}" class="param-icon svg-purple" alt="bullet" /></span>
            <span id="${counterElementValueIdFiftyGb}" class="counter-local-storage-value">${startValueFiftyGb} ${rangeUnit}</span>
            <span class="button-range-span"><button type="button" class="button-left"
                                                    onclick="subtract_one(&quot;${counterElementPreviousValueIdFiftyGb}&quot;, &quot;${counterHiddenValueIdFiftyGb}&quot;, &quot;${counterElementValueIdFiftyGb}&quot;, &quot;${warningIconElementIdFiftyGb}&quot;, &quot;${minWarningFiftyGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${minFiftyGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                <img src="/userContent/icons/chevron-down.svg" alt="minus" class="image-plus-minus svg-white"/></button></span>
            <span class="divider-span"></span>
            <span class="button-range-span">
                <span class="divider-span"></span>
                <button type="button" class="button-right"
                        onclick="add_one(&quot;${counterElementPreviousValueIdFiftyGb}&quot;, &quot;${counterHiddenValueIdFiftyGb}&quot;, &quot;${counterElementValueIdFiftyGb}&quot;, &quot;${warningIconElementIdFiftyGb}&quot;, &quot;${minWarningFiftyGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;, &quot;${step}&quot;, &quot;${maxFiftyGb}&quot;); updateConcatenatedLocalStorageReturnVariable();">
                    <img src="/userContent/icons/chevron-up.svg" alt="plus" class="image-plus-minus svg-white"/>
                </button>
            </span>
            <div class="tooltip-info"><span class="info-span">
                <img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info">
                <span class="tooltiptext">${infoTextFiftyGb}</span>
            </span>
            </div>
            <span id="${warningIconElementIdFiftyGb}" data-text="${warningTextFiftyGb}" class="warning-span tooltip">
                <img src="/userContent/icons/triangle-exclamation-solid.svg" class="warn-image svg-orange-red" alt="#" /></span>
        </div>
    </div>
    <input type="hidden" id="${counterHiddenValueIdFiftyGb}" name="${counterHiddenValueIdFiftyGb}" value="${startValueFiftyGb}">
    <input type="hidden" id="${counterElementPreviousValueIdFiftyGb}" name="${counterElementPreviousValueIdFiftyGb}" value="">
    <style scoped="scoped" onload="show_value(&quot;${startValueFiftyGb}&quot;, &quot;${counterElementPreviousValueIdFiftyGb}&quot;, &quot;${counterHiddenValueIdFiftyGb}&quot;, &quot;${counterElementValueIdFiftyGb}&quot;, &quot;${warningIconElementIdFiftyGb}&quot;, &quot;${minWarningFiftyGb}&quot;, &quot;${valueDisplayConversion}&quot;, &quot;${rangeUnit}&quot;); updateConcatenatedLocalStorageReturnVariable();">   </style>
    <!-- --->

    <input type="hidden" id="concatenated-local-volume-params" name="value" value="" >

    </div>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (config_local_storage_volumes): ${e}"
}
