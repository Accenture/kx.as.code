try {
    // language=HTML
    def HTML = """
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/v4-shims.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@6.3.95/css/materialdesignicons.min.css">
    <link href="//cdn.muicss.com/mui-0.10.3/css/mui.min.css" rel="stylesheet" type="text/css"/>
    <head>
        <style>
            .wrapper {
                display: flex;
                align-items: center;
                vertical-align: middle;
                padding-left: 0px;
                margin-left: 0px;
                margin-right: 10px;
                margin-bottom: 10px;
                margin-right: 10px;
            }
            
            .storage-wrapper {
                display: flex;
                align-items: center;
                vertical-align: middle;
                padding-left: 10px;
            }
            
            .outerWrapper {
                height: 40px;
            }


            #container {
                display: flex;
                justify-content: space-between;
                align-items: right;
                width: 300px;
                vertical-align: middle;
            }

            .slider:before {
                position: relative !important;
            }

            .slider {
                -webkit-appearance: none;
                border-radius: 0px;
                width: 150px;
                height: 30px;
                vertical-align: middle;
                position: relative !important;
                background: #d3d3d3;
                outline: none;
                opacity: 1;
                -webkit-transition: .2s;
                transition: opacity .2s;
            }

            .slider:hover {
                opacity: 0.7;
            }

            .slider::-webkit-slider-thumb {
                -webkit-appearance: none;
                appearance: none;
                width: 40px;
                border-radius: 20px;
                border: none;
                height: 40px;
                background: #dcafff;
                cursor: pointer;
                opacity: 1.0;
            }

            .slider::-moz-range-thumb {
                width: 40px;
                border-radius: 20px;
                height: 40px;
                background: #dcafff;
                cursor: pointer;
                opacity: 1.0;
            }

            .button-left {
                background-color: #7500c0;
                cursor: pointer;
                opacity: 0.7;
                height: 30px;
                border-top-right-radius: 0px;
                border-bottom-right-radius: 0px;
                border-top-left-radius: 15px;
                border-bottom-left-radius: 15px;
                line-height: 30px;
                vertical-align: middle;
                padding: 0 0px;
                margin: 0px;
                font-size: 13px;
                width: 50px;
                border: none;
            }

            .button-left:hover {
                opacity: 0.5;
            }

            .button-right {
                background-color: #7500c0;
                cursor: pointer;
                opacity: 0.7;
                height: 30px;
                border-top-right-radius: 15px;
                border-bottom-right-radius: 15px;
                border-top-left-radius: 0px;
                border-bottom-left-radius: 0px;
                line-height: 30px;
                vertical-align: middle;
                padding: 0 0px;
                margin: 0px;
                font-size: 13px;
                width: 50px;
                border: none;
            }

            .button-right:hover {
                opacity: 0.5;
            }

            .svg-white {
                filter: brightness(0) invert(1);
            }

            .svg-purple {
                filter: invert(10%) sepia(88%) saturate(6128%) hue-rotate(277deg) brightness(90%) contrast(106%);
                opacity: 0.7;
            }

            .svg-bright-green {
                filter: invert(63%) sepia(6%) saturate(3019%) hue-rotate(70deg) brightness(82%) contrast(120%);
                width: 20px;
            }

            .svg-orange-red {
                filter: invert(49%) sepia(60%) saturate(1660%) hue-rotate(338deg) brightness(100%) contrast(102%);
                width: 20px;
            }

            .setting-name {
                display: none;
            }

            .yui-button.primary {
                display: none;
            }

            .tooltip {
                position: relative;
            }

            .param-icon {
                width: 40px;
                height: 40px;
            }

            .numeric-icon {
                width: 20px;
                height: 20px;
            }

            .info-icon {
                width: 20px;
                height: 20px;
            }

            .input-range-span {
                vertical-align: middle;
            }

            .image-plus-minus {
                width: 15px;
                height: 15px;
            }

            .warning-span {
                width: 20px;
                padding-right: 10px;
            }

            .warn-image {
                border-bottom: 1px dashed #000;
            }

            .checklist-span {
                width: 20px;
                padding-right: 10px;
                vertical-align: middle;
            }

            .info-span {
                width: 50px;
                margin-right: 15px;
            }

            .button-range-span {
                vertical-align: middle;
            }

            .slider-element-value {
                width: 300px;
                text-align: left;
                margin-right: 0px;
                padding-right: 10px;
                padding-left: 120px;
            }

            .tooltip:before {
                content: attr(data-text);
                position:absolute;
                top:50%;
                transform:translateY(-50%);
                left:100%;
                margin-left:15px;
                width:200px;
                padding:10px;
                border-radius:10px;
                background:#000;
                color: #fff;
                text-align:center;
                opacity:0;
                transition:.3s opacity;
            }

            .tooltip:after {
                content: "";
                position: absolute;
                left: 100%;
                margin-left: -5px;
                top: 50%;
                transform: translateY(-50%);
                border: 10px solid #000;
                border-color: transparent black transparent transparent;
                display: none;
            }

            .tooltip:hover:before, .tooltip:hover:after {
                display: block;
                opacity: 1;
            }

            .input-box {
                width: 150px;
                line-height:15px;
                margin-bottom: 10px;
                padding: 10px 0 10px 15px;
                font-family: arial;
                font-weight: 400;
                color: #7500c0;
                background: #efefef;
                border: 0;
                border-left: 0;
                border-top-right-radius: 5px;
                border-bottom-right-radius: 5px;
                border-top-left-radius: 0px;
                border-bottom-left-radius: 0px;
                outline: 0;
                text-indent: 5px;
            }

            ::-webkit-input-placeholder {
                font-style: italic;
            }
            :-moz-placeholder {
                font-style: italic;
            }
            ::-moz-placeholder {
                font-style: italic;
            }
            :-ms-input-placeholder {
                font-style: italic;
            }

            .input-box-label {
                display: inline-block;
                width: 8em;
                color: white;
                background: #7500c0;
                opacity: 0.7;
                padding: 10px 0 10px 5px;
                margin-bottom: 10px;
                border: 0;
                border-right: 0;
                border-top-right-radius: 0px;
                border-bottom-right-radius: 0px;
                border-top-left-radius: 5px;
                border-bottom-left-radius: 5px;
                outline: 0;
                text-indent: 5px;
            }
            .input-box-div {
                line-height:15px;
                display: table;

            }
            .input-box-span {
                line-height:15px;
                display: table-cell;
            }

            .checkbox-switch {
                position: relative;
                display: inline-block;
                width: 52px;
                height: 30px;
            }

            .checkbox-switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }


            .checkbox-slider-checked-disabled {
                position: absolute;
                cursor: not-allowed;
                pointer-events: none;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #7500c0;
                -webkit-transition: .4s;
                transition: .4s;
                opacity: 0.1;
            }

            .checkbox-slider-checked-disabled:before {
                position: absolute;
                cursor: not-allowed;
                pointer-events: none;
                content: "";
                height: 22px;
                width: 22px;
                left: 26px;
                bottom: 4px;
                background-color: white;
                -webkit-transition: .4s;
                transition: .4s;
            }

            input:checked + .checkbox-slider-checked-disabled {
                background-color: #7500c0 !important;
                opacity: 0.1;
            }

            input:focus + .checkbox-slider-checked-disabled {
                box-shadow: 0 0 1px #7500c0;
            }

            input:checked + .checkbox-slider-checked-disabled:before {
                -webkit-transform: translateX(0px);
                -ms-transform: translateX(0px);
                transform: translateX(0px);
            }

            .checkbox-slider-checked-disabled.round {
                border-radius: 34px;
            }

            .checkbox-slider-checked-disabled.round:before {
                border-radius: 50%;
            }

            .checkbox-slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #ccc;
                -webkit-transition: .4s;
                transition: .4s;
            }

            .checkbox-slider:before {
                position: absolute;
                content: "";
                height: 22px;
                width: 22px;
                left: 4px;
                bottom: 4px;
                background-color: white;
                -webkit-transition: .4s;
                transition: .4s;
            }

            input:checked + .checkbox-slider {
                background-color: #7500c0 !important;
                opacity: 0.7;
            }

            input:focus + .checkbox-slider {
                box-shadow: 0 0 1px #7500c0;
            }

            input:checked + .checkbox-slider:before {
                -webkit-transform: translateX(22px);
                -ms-transform: translateX(22px);
                transform: translateX(22px);
            }

            .checkbox-slider.round {
                border-radius: 34px;
            }

            .checkbox-slider.round:before {
                border-radius: 50%;
            }

            .span-toggle-text {
                width: 340px;
            }

            .counter-element-value {
                width: 300px;
                color: black;
                background: white;
                vertical-align: middle;
                text-align: left;
                padding-left: 120px;
            }

            .counter-element-value:hover {
                opacity: 0.7;
            }

            .spacer-span {
                width: 100px;
            }

            .divider-span {
                width: 1px;
            }

            .divider-parameter-span {
                width: 100%;
                height: 30px;
            }

            .tooltip-info {
                position: relative;
                display: inline-block;
            }

            .tooltip-info .tooltiptext {
                width: 200px;
                background-color: #404c50;
                color: #ffffff;
                text-align: left;
                padding: 5px 5px;
                border-top-right-radius: 10px;
                border-bottom-right-radius: 10px;
                border-bottom-left-radius: 10px;
                visibility: hidden;
                position: absolute;
                top: 25px;
                left: 25px;
                z-index: 10;
            }

            .tooltip-info:hover .tooltiptext {
                visibility: visible;
            }

            .info-text-header {
                color: lightgrey;
                font-style: italic;
            }

            .info-text-body {
                color: white;
            }

            .indented-bullet-span {
                margin-left: 0rem;
            }

            .rounded-number-span {
                border-radius: 5px;
                width: 60px;
                background: #404c50;
                font-size: 14px;
                font-family: Courier;
                font-weight: 400;
                color: white;
                padding: 5px;
                text-align: center;
                display: inline-block;
                margin-left: 25px;
            }

            .counter-local-storage-value {
                width: 220px;
                color: black;
                background: white;
                vertical-align: middle;
                text-align: left;
                padding-left: 50px;
                display: inline-block;
            }

            .description-paragraph-span {
                width: 700px;
                display: inline-block;
            }

            .svg-item {
                width: 100%;
                font-size: 16px;
                margin: 0 auto;
                animation: donutfade 1s;
            }

            @keyframes donutfade {
                0% {
                    opacity: .2;
                }
                100% {
                    opacity: 1;
                }
            }

            @media (min-width: 992px) {
                .svg-item {
                    width: 80%;
                }
            }

            .donut-ring {
                stroke: #EBEBEB;
            }

            .donut-segment {
                transform-origin: center;
                stroke: #FF6200;
            }

            .segment-1{fill:#ccc;}
            .segment-2{fill:#9f4dd3;}
            .segment-3{fill:#d9e021;}
            .segment-4{fill:#ed1e79;}

            .donut-percent {
                animation: donutfadelong 1s;
            }

            @keyframes donutfadelong {
                0% {
                    opacity: 0;
                }
                100% {
                    opacity: 1;
                }
            }

            @keyframes donut1 {
                0% {
                    stroke-dasharray: 0, 100;
                }
                100% {
                    stroke-dasharray: 69, 31;
                }
            }

            @keyframes donut2 {
                0% {
                    stroke-dasharray: 0, 100;
                }
                100% {
                    stroke-dasharray: 69, 31;
                }
            }

            @keyframes donut3 {
                0% {
                    stroke-dasharray: 0, 100;
                }
                100% {
                    stroke-dasharray: 69, 31;
                }
            }
            .donut-text {
                font-family: Arial, Helvetica, sans-serif;
                fill: #FF6200;
            }

            .donut-label {
                font-size: 0.28em;
                font-weight: 700;
                line-height: 1;
                fill: #000;
                transform: translateY(0.25em);
            }

            .donut-percent {
                font-size: 0.5em;
                line-height: 1;
                transform: translateY(0.5em);
                font-weight: bold;
            }

            .donut-data {
                font-size: 0.12em;
                line-height: 1;
                transform: translateY(0.5em);
                text-align: center;
                text-anchor: middle;
                color:#666;
                fill: #666;
                animation: donutfadelong 1s;
            }

            .donut-text {
                font-family: Arial, Helvetica, sans-serif;
                fill: #FF6200;
            }
            .donut-text-cpu {
                fill: #9f4dd3;
            }

            .donut-text-memory {
                fill: #9f4dd3;
            }

            .donut-text-disk {
                fill: #9f4dd3;
            }

            .donut-segment-cpu {
                stroke: #9f4dd3;
                animation: donut1 0.5s;
            }

            .donut-segment-memory {
                stroke: #9f4dd3;
                animation: donut2 0.5s;
            }

            .donut-segment-disk {
                stroke: #9f4dd3;
                animation: donut3 0.5s;
            }
            
            .config-outer-wrapper {
                background-color: rgba(187, 187, 187, 1.0);
                height: 650px;
                width: 1000px;
                padding: 5px;
            }

            .config-inner-panel {
                background-color: #ffffff;
                height: 640px;
                width: 990px;
            }
            
            .config-selector-panel {
                display: flex;
                width: 990px;
                height: 60px;
                vertical-align: middle;
                justify-content: space-between;
            }

            .config-selector-footer {
                display: flex;
                width: 990px;
                height: 40px;
                background-color: rgba(187, 187, 187, 1.0);
                vertical-align: bottom;
                justify-content: space-between;
            }
            
            .config-tab {
                  display: inline-block;
                  height: 100%;
                  width: 100%;
                  background-color: rgba(187, 187, 187, 1.0);
                  vertical-align: middle;
                  text-align: center;
                  opacity: 1.0;
                  cursor: pointer;
            }
            
            .config-tab:hover {
                background-color: rgba(187, 187, 187, 0.5);
            }

            .config-tab-footer-icons {
                cursor: pointer;
                width: 40px;
                height: 100%;
                vertical-align: middle;
            }

            .config-tab-footer-icons:hover {
                background-color: rgba(187, 187, 187, 0.5);
            }

            .config-tab-selected {
                display: inline-block;
                height: 100%;
                width: 100%;
                color: rgba(220, 175, 255, 1);
                background-color: #ffffff;
                border: 1px;
                vertical-align: middle;
                text-align: center;
            }            
            
            .config-tab-disabled {
                display: inline-block;
                height: 100%;
                width: 100%;
                background-color: rgba(187, 187, 187, 0.5);
                vertical-align: middle;
                text-align: center;
                opacity: 0.5;
                cursor: not-allowed;
            }  
            
            .svg-purple {
                filter: invert(10%) sepia(88%) saturate(6128%) hue-rotate(277deg) brightness(90%) contrast(106%);
                opacity: 0.6;
            }

            .config-panel-icon {
                width: 40px;
                height: 100%;
                vertical-align: middle;
                top: 0;
                bottom: 0;
                left: 0;
                right: 0;
                margin: auto;
            }
            
            .config-placeholder {
                padding: 20px;
                height: 545px;
            }

        </style>
        <script>
            function changeBuildButton() {
                const checkElement = async selector => {
                    while ( document.querySelector(selector) === null) {
                        await new Promise( resolve =>  requestAnimationFrame(resolve) );
                    }
                    return document.querySelector(selector);
                };

                checkElement(document.getElementById("yui-gen1-button")).then((selector) => {
                    console.log(selector);
                    document.getElementById("yui-gen1-button").innerText = "Start";
                });
            }

            function updateConcatenatedGeneralParamsReturnVariable() {

                let baseDomain = document.getElementById("general-param-base-domain");
                let baseDomainValue;
                if (baseDomain.value.length === 0) {
                    baseDomainValue = baseDomain.placeholder.trim();
                } else {
                    baseDomainValue = baseDomain.value.trim();
                }

                let username = document.getElementById("general-param-username");
                let usernameValue;
                if (username.value.length === 0) {
                    usernameValue = username.placeholder.trim();
                } else {
                    usernameValue = username.value.trim();
                }

                let teamName = document.getElementById("general-param-team-name");
                let teamNameValue;
                if (teamName.value.length === 0) {
                    teamNameValue = teamName.placeholder.trim();
                } else {
                    teamNameValue = teamName.value.trim();
                }

                let password = document.getElementById("general-param-password");
                let passwordValue;
                if (password.value.length === 0) {
                    passwordValue = password.placeholder.trim();
                } else {
                    passwordValue = password.value.trim();
                }

                let standaloneModeCheckedStatus = document.getElementById("general-param-standalone-mode-toggle").checked              
                let workloadsOnMasterCheckedStatus = document.getElementById("general-param-workloads-on-master-toggle").checked
 
                let parentId = document.getElementById("concatenated-general-params").parentNode.id;
                jQuery('#' + parentId).trigger('change');
                
                document.getElementById("concatenated-general-params").value = baseDomainValue + ";" + teamNameValue + ";" + usernameValue + ";" + passwordValue + ";" + standaloneModeCheckedStatus + ";" + workloadsOnMasterCheckedStatus;
                console.log(document.getElementById("concatenated-general-params").value);
                //#TODO - Placeholder to check if issue after commenting out line below 
                //change_panel_selection("config-panel-general-params");
            }

            function updateCheckbox(checkboxElementId)
            {
                console.log("Processing updateCheckbox(checkboxElementId) for " + checkboxElementId);
                waitForElement(checkboxElementId,function(){
                    console.log("checkboxElementId: " + checkboxElementId + " --> " + document.getElementById(checkboxElementId).checked);
                });
                
                waitForElement('standalone-mode-toggle',function(){
                    console.log("document.getElementById('standalone-mode-toggle').value: *" + document.getElementById("standalone-mode-toggle").value + "*");

                });
                
                waitForElement('system-prerequisites-check',function(){
                    console.log("document.getElementById(system-prerequisites-check).value: *" + document.getElementById("system-prerequisites-check").value + "*");
                });                
               
                if ( document.getElementById(checkboxElementId).checked === true ) {
                    console.log("DEBUG (1) updateCheckbox() - false: " + document.getElementById(checkboxElementId).checked);
                    document.getElementById(checkboxElementId).checked = true;
                    document.getElementById(checkboxElementId).value = true;
                    console.log("Name value hidden field: " + checkboxElementId + "-name-value");
                    document.getElementById(checkboxElementId + '-name-value').value = true;
                } else {
                    console.log("DEBUG (2) updateCheckbox() - true: " + document.getElementById(checkboxElementId).checked);
                    document.getElementById(checkboxElementId).checked = false;
                    document.getElementById(checkboxElementId).value = false;
                    console.log("Name value hidden field: " + checkboxElementId + "-name-value");
                    document.getElementById(checkboxElementId + '-name-value').value = false;
                }
                
                if (document.getElementById("system-prerequisites-check").value === "standalone" || document.getElementById("system-prerequisites-check").value === "failed") {
                    console.log('DEBUG: Inside checkbox set to standalone');
                    document.getElementById('general-param-standalone-mode-toggle').checked = true;
                    document.getElementById('general-param-workloads-on-master-toggle').checked = true;
                    document.getElementById('general-param-standalone-mode-toggle').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('general-param-standalone-mode-toggle-span').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('general-param-workloads-on-master-toggle').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('general-param-workloads-on-master-toggle-span').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('general-param-workloads-on-master-toggle-name-value').value = true;  
                } else if (document.getElementById("system-prerequisites-check").value === "full") {
                    console.log("DEBUG: Inside checkbox set to full");
                    document.getElementById('general-param-standalone-mode-toggle').className = "checkbox-slider round";
                    document.getElementById('general-param-standalone-mode-toggle-span').className = "checkbox-slider round";
                    document.getElementById('general-param-workloads-on-master-toggle').className = "checkbox-slider round";
                    document.getElementById('general-param-workloads-on-master-toggle-span').className = "checkbox-slider round";
                }
                
                let parentId = document.getElementById(checkboxElementId + '-name-value').parentNode.id;
                console.log(parentId);  
                jQuery('#' + parentId).trigger('change');

            }
            
            function show_value(x, previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit) {
                let previous_x = document.getElementById(previousElementId).value;
                if ( x !== previous_x) {
                    let x_float = parseFloat(x).toFixed(2);
                    document.getElementById(valueElementId).innerHTML = (x_float / valueDisplayConversion) + " " + rangeUnit;
                    document.getElementById(elementId).value = x;
                    document.getElementById(elementId).setAttribute(elementId, x);
                    let parentId = document.getElementById(elementId).parentNode.parentNode.parentNode.parentNode.parentNode.id;
                    if ( parentId === '' ) {
                        parentId = document.getElementById(elementId).parentNode.id;
                    }
                    console.log("parentId: " + parentId);
                    jQuery('#' + parentId).trigger('change');
                    if (parseInt(x) < parseInt(minWarning)) {
                        document.getElementById(warningElementId).style.visibility = "visible";
                    } else {
                        document.getElementById(warningElementId).style.visibility = "hidden";
                    }
                    document.getElementById(previousElementId).value = x;
                    if ( elementId.includes("main_admin_node") || elementId.includes("main_node") ) { 
                        updateConcatenatedNodeReturnVariable("concatenated_value_main_node_config");
                    } else if ( elementId.includes("worker_node") ){
                        updateConcatenatedNodeReturnVariable("concatenated_value_worker_node_config");
                    } else if ( elementId.includes("local_volume_count") || elementId.includes("network_storage") ) {
                        updateConcatenatedStorageReturnVariable();
                    } else if ( elementId.includes("general-param") ) {
                        updateConcatenatedGeneralParamsReturnVariable();
                    } else {
                        console.log("Not calling updateConcatenated*ReturnVariable() for " + elementId);
                    }
                }
            }

            function update_display_value(x, valueElementId, valueDisplayConversion, rangeUnit) {
                let x_float = parseFloat(x).toFixed(2);
                document.getElementById(valueElementId).innerHTML = (x_float / valueDisplayConversion) + " " + rangeUnit;
            }

            function add_one(previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit, step, max) {
                let count = parseInt(document.getElementById(elementId).value) + parseInt(step);
                if (count <= max) {
                    show_value(count, previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit);
                }
            }

            function subtract_one(previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit, step, min) {
                let count = parseInt(document.getElementById(elementId).value) - parseInt(step);
                if (count >= min) {
                    show_value(count, previousElementId, elementId, valueElementId, warningElementId, minWarning, valueDisplayConversion, rangeUnit);
                }
            }

            function updateConcatenatedNodeReturnVariable(hiddenValueElementId) {
                let nodeCount
                let cpuCores
                let memory
                console.log("Updating concatenated value for " + hiddenValueElementId);
                if ( hiddenValueElementId === "concatenated_value_main_node_config") {
                    console.log("Getting values for concatenated_value_main_node_config");
                    nodeCount = document.getElementById("counter_value_main_node_count").value;
                    cpuCores = document.getElementById("slider_value_main_admin_node_cpu_cores").value;
                    memory = document.getElementById("slider_value_main_admin_node_memory").value;
                    console.log("Received following values for main node: " + nodeCount + "; " + cpuCores + "; " + memory);
                } else if ( hiddenValueElementId === "concatenated_value_worker_node_config") {
                    console.log("Getting values for concatenated_value_worker_node_config");
                    nodeCount = document.getElementById("counter_value_worker_node_count").value;
                    cpuCores = document.getElementById("slider_value_worker_node_cpu_cores").value;
                    memory = document.getElementById("slider_value_worker_node_memory").value;
                    console.log("Received following values for worker node: " + nodeCount + "; " + cpuCores + "; " + memory);
                } else {
                    console.log(hiddenValueElementId + "not found -> updateConcatenatedNodeReturnVariable()");
                }
                let concatenatedValue = nodeCount + ";" + cpuCores + ";" + memory;
                console.log("Updating hidden value id " + hiddenValueElementId + " with " + concatenatedValue);
                document.getElementById(hiddenValueElementId).value = concatenatedValue;
            }
            
            function updateConcatenatedStorageReturnVariable() {
                let counterHiddenValueIdOneGb = document.getElementById("counter_value_local_volume_count_1_gb").value;
                let counterHiddenValueIdFiveGb = document.getElementById("counter_value_local_volume_count_5_gb").value;
                let counterHiddenValueIdTenGb = document.getElementById("counter_value_local_volume_count_10_gb").value;
                let counterHiddenValueIdThirtyGb = document.getElementById("counter_value_local_volume_count_30_gb").value;
                let counterHiddenValueIdFiftyGb = document.getElementById("counter_value_local_volume_count_50_gb").value;
                let networkStorageValueGb = document.getElementById("slider_value_network_storage").value;
                let concatenatedLocalVolumeParams = counterHiddenValueIdOneGb + ";" + counterHiddenValueIdFiveGb + ";" + counterHiddenValueIdTenGb + ";" + counterHiddenValueIdThirtyGb + ";" + counterHiddenValueIdFiftyGb + ";" + networkStorageValueGb;
                document.getElementById("concatenated-storage-params").value = concatenatedLocalVolumeParams;
                document.getElementById("concatenated-storage-params").setAttribute("concatenated-storage-params", concatenatedLocalVolumeParams);
                let parentId = document.getElementById('concatenated-storage-params').parentNode.id;
                console.log(parentId);
                jQuery('#' + parentId).trigger('change');
            }
            
            function updateAllConcatenatedVariables() {
                updateConcatenatedGeneralParamsReturnVariable();
                updateConcatenatedNodeReturnVariable("concatenated_value_main_node_config");
                updateConcatenatedNodeReturnVariable("concatenated_value_worker_node_config");
                updateConcatenatedStorageReturnVariable();   
            }

            async function getBuildJobListForProfile(job, nodeType) {
                let styleColor;
                getAllJenkinsBuilds(job).then(data => {
                    console.log("nodeType: " + nodeType);
                    console.log(data);
                    const kxBuilds = (() => {
                      const builds = filterBuilds(data);
                      console.log(data);
                      console.log("above: data");
                      console.log(builds);
                      console.log("above: builds");
                      const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
                      console.log(filteredBuilds);
                      console.log("above: filteredBuilds");
                      console.log(filteredBuilds);
                      if ( nodeType === "kx-launch" ) {
                          console.log("Inside const definition kx-launch");  
                          console.log(filteredBuilds);
                          return filteredBuilds;
                      } else {
                          console.log("Inside const definition not equal to kx-launch");
                          return filterDataByNodeType(filteredBuilds, nodeType);
                      }
                    })();
                    console.log(nodeType + ' kxBuilds.length: ' + kxBuilds.length);
                    console.log(kxBuilds);
                    if ( kxBuilds.length > 0 ) {
                        console.log('Found ' + nodeType + ' builds for profile');
                        console.log(kxBuilds[0].estimatedDuration);
                        console.log(kxBuilds[0].id);
                        console.log(kxBuilds[0].node_type);
                        console.log(kxBuilds[0].number);
                        console.log(kxBuilds[0].result);
                        console.log(kxBuilds[0].timestamp);
                        console.log(kxBuilds[0].url);
                        console.log(kxBuilds[0].vm_type);
                        if (kxBuilds[0].timestamp !== null) {
                            document.getElementById(nodeType + "-build-timestamp").innerText = new Date(kxBuilds[0].timestamp).toLocaleDateString() + " " + new Date(kxBuilds[0].timestamp).toLocaleTimeString();
                        }
                        if (kxBuilds[0].result !== null) {
                            if ( kxBuilds[0].result === "ABORTED" ) {
                                styleColor = '#FF6200';
                            } else if ( kxBuilds[0].result === "FAILURE" ) {
                                styleColor = 'red';
                            } else if ( kxBuilds[0].result === "SUCCESS" ) {
                                styleColor = '#34eb89';
                            } else {
                                styleColor = 'black';
                            }
                            document.getElementById(nodeType + "-build-result").innerText = kxBuilds[0].result;
                            document.getElementById(nodeType + "-build-result").style.color = styleColor;
                            document.getElementById(nodeType + "-build-number-link").innerHTML = "<a href='" + kxBuilds[0].url + "' target='_blank' rel='noopener noreferrer' style='font-weight: normal;'># " + kxBuilds[0].number + "</a>";
                        } else {
                            document.getElementById(nodeType + "-build-result").innerText = "in progress";
                            document.getElementById(nodeType + "-build-result").style.color = styleColor;
                            document.getElementById(nodeType + "-build-number-link").innerHTML = "<a href='" + kxBuilds[0].url + "' target='_blank' rel='noopener noreferrer' style='font-weight: normal;'># " + kxBuilds[0].number + "</a>";
                        }
                    } else {
                        console.log('Did not find ' + nodeType + ' builds for profile');
                        document.getElementById(nodeType + "-build-timestamp").innerText = "not run yet";
                        document.getElementById(nodeType + "-build-result").innerText = "n/a";
                        document.getElementById(nodeType + "-build-number-link").innerText = "-";
                        document.getElementById(nodeType + "-build-result").style.color = 'black';
                    }
                })
           }            
            
            function filterBuilds(data) {
                let tmp = [];
                let nodeType;
                console.log("Inside filterBuilds");
                const builds = data.builds; 
                console.log(data);
                console.log(builds);
                builds.map((e) => {
                    let obj = {}
                    obj["estimatedDuration"] = e.estimatedDuration ? e.estimatedDuration : -1
                    obj["id"] = e.id ? e.id : -1
                    obj["number"] = e.number ? e.number : -1
                    obj["result"] = e.result ? e.result : '-'
                    obj["timestamp"] = e.timestamp ? e.timestamp : -1
                    obj["url"] = e.url ? e.url: '-'
                    obj["displayName"] = e.displayName ? e.displayName : '-'
                
                    e.actions[0].parameters.filter((e) => {
                        
                        if (e.value === "kx-main") {
                            nodeType = "kx-main";
                        } else if (e.value === "kx-node") {
                            nodeType = "kx-node";
                        }
                        
                        if (e.value === "virtualbox") {
                            obj["vm_type"] = "virtualbox"
                            if (nodeType === "kx-main") {
                                obj["node_type"] = "kx-main"
                            } else if (nodeType === "kx-node") {
                                obj["node_type"] = "kx-node"
                            }
                            tmp.push(obj)
                            // return obj
                        }
                        else if(e.value === "parallels"){
                            obj["vm_type"] = "parallels"
                            if (nodeType === "kx-main") {
                                obj["node_type"] = "kx-main"
                            } else if (nodeType === "kx-node") {
                                obj["node_type"] = "kx-node"
                            }
                            tmp.push(obj)
                            // return obj
                        }
                        else if(e.value === "vmware-desktop"){
                            obj["vm_type"] = "vmware-desktop"
                            if (nodeType === "kx-main") {
                                obj["node_type"] = "kx-main"
                            } else if (nodeType ==="kx-node") {
                                obj["node_type"] = "kx-node"
                            }
                            tmp.push(obj)
                            // return obj
                        }
                    })
                })
                console.log(tmp);
                console.log("above tmp");
                return tmp
            }

            function filterDataByVmType(jsonData, v) {
                return jsonData.filter((e) => {
                    if(e.vm_type === v){
                        return e
                    }
                })
            }
                    
            function filterDataByNodeType(jsonData, v) {
                return jsonData.filter((e) => {
                    if(e.node_type === v){
                        return e
                    }
                })
            }
            
            function filterDataByResult(jsonData) {
                return jsonData.filter((e) => {
                    if(e.result === null){
                        return e
                    }
                })
            }
            
            async function stopTriggeredBuild(job, nodeType) {
                //let job = 'KX.AS.CODE_Image_Builder';    // For debuging only
                //let nodeType = 'kx-main';    // For debuging only
                let jenkinsCrumb = getCrumb();
                getAllJenkinsBuilds(job).then(data => {
                    const builds = filterBuilds(data);
                    const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
                    
                    const runningBuilds = (() => {
                      if ( nodeType === null ) {
                          console.log('nodeType = null. Filtering running jobs from all builds')
                          return filterDataByResult(filteredBuilds);
                      } else {
                          console.log('nodeType = ' + nodeType + '. Filtering running jobs from ' + job + ' builds')
                         const kxBuilds = filterDataByNodeType(filteredBuilds, nodeType);
                         return filterDataByResult(kxBuilds);

                      }
                    })();
                    
                    console.log('runningBuilds.length: ' + runningBuilds.length);
                    if ( runningBuilds.length > 0 ) {
                        console.log(runningBuilds[0].url);
                        let urlToFetch = runningBuilds[0].url + 'stop';
                        console.log(urlToFetch);
                        let response = fetch(urlToFetch, {method:'POST', 
                        headers: {
                           'Authorization': 'Basic ' + btoa('admin:admin'),
                           'Jenkins-Crumb': jenkinsCrumb.value
                        }}).then(data => { console.log(data) })
                        let responseText = response.text();
                        console.log(responseText);
                    }
                })
           }
           
           async function showConsoleLog(job, nodeType) {
               //let nodeType = 'kx-main';    // For debuging only
               //let job = 'KX.AS.CODE_Image_Builder';     // For debuging only
               let jenkinsCrumb = getCrumb();
               let consoleLogDiv;
               if ( nodeType === 'kx-main' ) {
                    consoleLogDiv = document.getElementById('kxMainBuildConsoleLog');
                } else if (nodeType === 'kx-node') {
                    consoleLogDiv = document.getElementById('kxNodeBuildConsoleLog');
                } else if (nodeType === 'kx-launch') {
                    consoleLogDiv = document.getElementById('kxLaunchBuildConsoleLog');
                }
                consoleLogDiv.innerHTML = "";
                getAllJenkinsBuilds(job).then(data => {
                    console.log("nodeType: " + nodeType);
                    console.log(data);
                    const kxBuilds = (() => {
                      const builds = filterBuilds(data);
                      console.log(data);
                      console.log("above: data");
                      console.log(builds);
                      console.log("above: builds");
                      const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
                      console.log(filteredBuilds);
                      console.log("above: filteredBuilds");
                      console.log(filteredBuilds);
                      if ( nodeType === "kx-launch" ) {
                          console.log("Inside const definition kx-launch");  
                          console.log(filteredBuilds);
                          return filteredBuilds;
                      } else {
                          console.log("Inside const definition not equal to kx-launch");
                          return filterDataByNodeType(filteredBuilds, nodeType);
                      }
                    })();
                    //const kxBuilds = filterDataByNodeType(filteredBuilds, nodeType);
                    console.log('kxBuilds.length: ' + kxBuilds.length);
                    if ( kxBuilds.length > 0 ) {
                        console.log(kxBuilds[0].url);
                        let urlToFetch = kxBuilds[0].url + 'consoleText';
                        console.log(urlToFetch);
                        fetch(urlToFetch, {method:'GET', 
                        headers: {
                           'Authorization': 'Basic ' + btoa('admin:admin'),
                           'Jenkins-Crumb': jenkinsCrumb.value
                        }}).then(data => {
                            data.text().then( consoleLog => { console.log(consoleLog) 
                                console.log('consoleLog: ');
                                console.log(consoleLog);
                                let consoleLine;
                                let lines = consoleLog.split(/[\\r\\n]+/);
                                console.log(lines);
                                let linesToReturn = 18;
                                let n;
                                if (lines.length > linesToReturn) {
                                    n = lines.length - linesToReturn;
                                } else {
                                    n = lines.length;
                                }
                                for (let line = n; line < lines.length; line++) {
                                  consoleLine = lines[line] + '<br>';
                                  consoleLine = consoleLine.replace(/FAILURE/g, '<span style="color: #fc5d4c">FAILURE</span>')
                                  consoleLine = consoleLine.replace(/ERROR/g, '<span style="color: #fc5d4c">ERROR</span>')
                                  consoleLogDiv.innerHTML += consoleLine;
                                  console.log(consoleLine);
                                }
                            });
                        })
                    } else {
                        consoleLogDiv.innerHTML += "<i>No " + nodeType + " build has been run yet for " + document.getElementById("profiles").value + "</i>";
                    }
                })
           }
           
           async function openFullConsoleLog(job, nodeType) {
               getAllJenkinsBuilds(job).then(data => {
                    const builds = filterBuilds(data);
                    const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
                    console.log('filteredBuilds: ');
                    console.log(filteredBuilds);
                    const kxBuilds = (() => {
                      const builds = filterBuilds(data);
                      console.log(data);
                      console.log("above: data");
                      console.log(builds);
                      console.log("above: builds");
                      const filteredBuilds = filterDataByVmType(builds, document.getElementById("profiles").value);
                      console.log(filteredBuilds);
                      console.log("above: filteredBuilds");
                      console.log(filteredBuilds);
                      if ( nodeType === "kx-launch" ) {
                          console.log("Inside const definition kx-launch");  
                          console.log(filteredBuilds);
                          return filteredBuilds;
                      } else {
                          console.log("Inside const definition not equal to kx-launch");
                          return filterDataByNodeType(filteredBuilds, nodeType);
                      }
                    })();
                    console.log('kxBuilds.length: ' + kxBuilds.length);
                    if ( kxBuilds.length > 0 ) {
                        let urlToOpen = kxBuilds[0].url + 'console';
                        console.log(urlToOpen);
                        window.open(urlToOpen, '_blank').focus();
                    }
               })
           }
           
           function formatSeconds(seconds)
           {
                let numDays = Math.floor((seconds % 31536000) / 86400); 
                let numHours = Math.floor(((seconds % 31536000) % 86400) / 3600);
                let numMinutes = Math.floor((((seconds % 31536000) % 86400) % 3600) / 60);
                let numSeconds = Math.floor((((seconds % 31536000) % 86400) % 3600) % 60);
                return numDays + " days " + numHours + " hours " + numMinutes + " minutes " + numSeconds + " seconds";
           }
                      
            function getCrumb() {
                const xhr = new XMLHttpRequest(),
                method = "GET",
                url = "http://localhost:8081/crumbIssuer/api/json";
            
                xhr.open(method, url, true);
                xhr.onreadystatechange = function () {
                  // In local files, status is 0 upon success in Mozilla Firefox
                  if(xhr.readyState === XMLHttpRequest.DONE) {
                    let status = xhr.status;
                    if (status === 0 || (status >= 200 && status < 400)) {
                      // The request has been completed successfully
                      console.log(xhr.responseText);
                      let crumb = JSON.parse(xhr.responseText).crumb;
                      console.log(crumb);
                    } else {
                      // Oh no! There has been an error with the request!
                    }
                  }
                };
                xhr.send();
                return crumb;
            }
            
            async function getAllJenkinsBuilds(job) {
                let jenkinsCrumb = getCrumb();
                console.log("Jenkins Crumb received = " + jenkinsCrumb.value);
                let fetchUrl = 'http://localhost:8081/job/Actions/job/' + job + '/api/json?tree=builds[number,status,timestamp,id,result,url,estimatedDuration,actions[parameters[name,value]]]'
                let response = await fetch(fetchUrl, {method:'GET', 
                headers: {
                   'Authorization': 'Basic ' + btoa('admin:admin'),
                   'Jenkins-Crumb': jenkinsCrumb.value
                }});
                
                if (!response.ok) {
                    const message = 'An error has occurred fetching JSON from Jenkins: ' + response.status;
                    throw new Error(message);
                }

                return response.json();
            }
 
            getAllJenkinsBuilds().catch(error => {
                error.message;
            });
            
            
        </script>
    </head>
    <body>
    <style scoped="scoped" onload="changeBuildButton();">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (header.groovy): ${e}"
}
