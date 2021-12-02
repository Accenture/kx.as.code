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
                padding-left: 10px;
                margin: 10px;
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

            function updateConcatenatedReturnVariable() {

                let baseDomain = document.getElementById("base-domain");
                let baseDomainValue;
                if (baseDomain.value.length === 0) {
                    baseDomainValue = baseDomain.placeholder.trim();
                } else {
                    baseDomainValue = baseDomain.value.trim();
                }

                let username = document.getElementById("username");
                let usernameValue;
                if (username.value.length === 0) {
                    usernameValue = username.placeholder.trim();
                } else {
                    usernameValue = username.value.trim();
                }

                let teamName = document.getElementById("team-name");
                let teamNameValue;
                if (teamName.value.length === 0) {
                    teamNameValue = teamName.placeholder.trim();
                } else {
                    teamNameValue = teamName.value.trim();
                }

                let password = document.getElementById("password");
                let passwordValue;
                if (password.value.length === 0) {
                    passwordValue = password.placeholder.trim();
                } else {
                    passwordValue = password.value.trim();
                }

                let parentId = document.getElementById("concatenated-general-params").parentNode.id;
                jQuery('#' + parentId).trigger('change');
                
                document.getElementById("concatenated-general-params").value = baseDomainValue + ";" + teamNameValue + ";" + usernameValue + ";" + passwordValue;
                console.log(document.getElementById("concatenated-general-params").value);
                change_panel_selection("config-panel-general-params");
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
                    document.getElementById('standalone-mode-toggle').checked = true;
                    document.getElementById('workloads-on-master-toggle').checked = true;
                    document.getElementById('standalone-mode-toggle').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('standalone-mode-toggle-span').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('workloads-on-master-toggle').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('workloads-on-master-toggle-span').className = "checkbox-slider-checked-disabled round";
                    document.getElementById('workloads-on-master-toggle-name-value').value = true;  
                } else if (document.getElementById("system-prerequisites-check").value === "full") {
                    console.log("DEBUG: Inside checkbox set to full");
                    document.getElementById('standalone-mode-toggle').className = "checkbox-slider round";
                    document.getElementById('standalone-mode-toggle-span').className = "checkbox-slider round";
                    document.getElementById('workloads-on-master-toggle').className = "checkbox-slider round";
                    document.getElementById('workloads-on-master-toggle-span').className = "checkbox-slider round";
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

            function updateConcatenatedLocalStorageReturnVariable() {
                let counterHiddenValueIdOneGb = document.getElementById("counter_value_local_volume_count_1_gb").value;
                let counterHiddenValueIdFiveGb = document.getElementById("counter_value_local_volume_count_5_gb").value;
                let counterHiddenValueIdTenGb = document.getElementById("counter_value_local_volume_count_10_gb").value;
                let counterHiddenValueIdThirtyGb = document.getElementById("counter_value_local_volume_count_30_gb").value;
                let counterHiddenValueIdFiftyGb = document.getElementById("counter_value_local_volume_count_50_gb").value;
                let concatenatedLocalVolumeParams = counterHiddenValueIdOneGb + ";" + counterHiddenValueIdFiveGb + ";" + counterHiddenValueIdTenGb + ";" + counterHiddenValueIdThirtyGb + ";" + counterHiddenValueIdFiftyGb;
                document.getElementById("concatenated-local-volume-params").value = concatenatedLocalVolumeParams;
                document.getElementById("concatenated-local-volume-params").setAttribute("concatenated-local-volume-params", concatenatedLocalVolumeParams);
                let parentId = document.getElementById('concatenated-local-volume-params').parentNode.id;
                console.log(parentId);
                jQuery('#' + parentId).trigger('change');
            }

            function hideParameterDivs() {
                    let configDivs = [
                        "select-profile-div",
                        "prerequisites-div",
                        "standalone-toggle-div",
                        "worker-cpu-count-div",
                        "worker-node-count-div",
                        "main-node-count-div",
                        "local-storage-div",
                        "main-memory-div",
                        "general-parameters-div",
                        "workloads-on-master-div",
                        "main-cpu-count-div",
                        "worker-memory-div",
                        "network-storage-div",
                        "headline-main-div",
                        "headline-workers-div",
                        "headline-storage-div",
                        "templates-div",
                        "header-system-check-div",
                        "system-check-div"
                    ];
                    console.log(configDivs);
                    configDivs.forEach(function(item) {
                        try {
                            console.log("Hiding div: " + item);
                            document.getElementById(item).style.display = "none";
                        } catch(e) {
                            console.log("Error hiding div: " + e);
                        }
                    })

            }
  
            function change_panel_selection(config_panel) {
                
               console.log("Selected config-panel: " + config_panel);
               
               waitForElement(config_panel,function(){
                    console.log("config-panel content: " + document.getElementById(config_panel));
                });
                              
               waitForElement('config-placeholder',function(){
                    console.log("config-placeholder children: " + document.getElementById('config-placeholder').checked);
                });
               
               let configPanelDivsInPlaceholderDiv = document.getElementById('config-placeholder').children;
                
               for (let i = 0; i < configPanelDivsInPlaceholderDiv.length; i++) {
                   if ( configPanelDivsInPlaceholderDiv[i].style.display !== "none" ) {
                        console.log("Visible Divs in Config Placeholder: " + configPanelDivsInPlaceholderDiv[i].id);
                   }
               }
                              
               const configPanels = [ 
                   "config-panel-profile-selection",
                   "config-panel-general-params",
                   "config-panel-kx-main-config",
                   "config-panel-kx-worker-config",
                   "config-panel-storage-config",
                   "config-panel-template-selection",
                   "config-panel-system-check",
                   "config-panel-kx-summary-start"
               ];
                
                let configPanelIcon
                console.log(configPanels);
                
                configPanels.forEach(function(item) {
                    configPanelIcon = item + "-icon";
                    if ( item === config_panel ) {
                        console.log("Item selected: " + item + ", item icon: " + configPanelIcon);
                        hideParameterDivs();
                        document.getElementById(item).className = "config-tab-selected";
                        document.getElementById(configPanelIcon).className = "config-panel-icon svg-purple";
                        switch (item) {
                            case "config-panel-profile-selection":
                                console.log("Inside switch-case for select-profile-div");
                                moveDivToConfigPanel("select-profile-div");
                                moveDivToConfigPanel("prerequisites-div");
                                updateNavigationFooter("", "config-panel-general-params");
                                break;
                            case "config-panel-general-params":
                                moveDivToConfigPanel("general-parameters-div");
                                moveDivToConfigPanel("standalone-toggle-div");
                                moveDivToConfigPanel("workloads-on-master-div");
                                updateNavigationFooter("config-panel-profile-selection", "config-panel-kx-main-config");
                                break;
                            case "config-panel-kx-main-config":
                                moveDivToConfigPanel("headline-main-div");
                                moveDivToConfigPanel("main-node-count-div");
                                moveDivToConfigPanel("main-cpu-count-div");
                                moveDivToConfigPanel("main-memory-div");
                                updateNavigationFooter("config-panel-general-params", "config-panel-kx-worker-config");
                                break;
                            case "config-panel-kx-worker-config":
                                moveDivToConfigPanel("headline-workers-div");
                                moveDivToConfigPanel("worker-node-count-div");
                                moveDivToConfigPanel("worker-cpu-count-div");
                                moveDivToConfigPanel("worker-memory-div");
                                updateNavigationFooter("config-panel-kx-main-config", "config-panel-storage-config");
                                break;
                            case "config-panel-storage-config":
                                moveDivToConfigPanel("headline-storage-div");
                                moveDivToConfigPanel("network-storage-div");
                                moveDivToConfigPanel("local-storage-div");
                                updateNavigationFooter("config-panel-kx-worker-config", "config-panel-template-selection");
                                break;
                            case "config-panel-template-selection":
                                moveDivToConfigPanel("templates-div");
                                updateNavigationFooter("config-panel-storage-config", "config-panel-system-check");
                                break;
                            case "config-panel-system-check":
                                moveDivToConfigPanel("header-system-check-div");
                                moveDivToConfigPanel("system-check-div");
                                updateNavigationFooter("config-panel-template-selection", "config-panel-kx-summary-start");
                                break;
                            case "config-panel-kx-summary-start":
                                moveDivToConfigPanel("kx-summary-start");
                                updateNavigationFooter("config-panel-system-check", "");
                                break;
                        }
                        
                    } else {
                        console.log("Item not selected: " + item + ", item icon: " + configPanelIcon);
                        document.getElementById(item).className = "config-tab";
                        document.getElementById(configPanelIcon).className = "config-panel-icon svg-white";
                    }  
                })
            }
            
            function removeAllChildNodes(parent) {
                while (parent.firstChild) {
                    parent.removeChild(parent.firstChild);
                }
            }

            function moveDivToConfigPanel(configDiv) {
                try {
                    let currentParent = document.getElementById(configDiv).parentNode.id;
                    console.log("(1) Current parent for " + configDiv + " is " + currentParent);
                    let divConfigPanelParent = document.getElementById("config-placeholder");
                    let divConfigPanelChild = document.getElementById(configDiv);
                    console.log("Child div: " + divConfigPanelChild.id);
                    let divChildConfigs = document.querySelectorAll('[id=' + configDiv + ']');
                    console.log("(2) Div " + configDiv + " is present " + divChildConfigs.length + " times");
                    if ( divChildConfigs.length <= 1 && currentParent !== "config-placeholder" ) {
                        console.log("(3) Parent div: " + divConfigPanelParent);
                        divConfigPanelParent.appendChild(divConfigPanelChild);
                    } else if ( divChildConfigs.length > 1) {
                        console.log("Inside divChildConfigs loop");
                        divChildConfigs.forEach(function(item) {
                            console.log("Item parent node: " + item.parentNode.id);
                            if ( item.parentNode.id === 'config-placeholder' ) {
                                divConfigPanelParent.removeChild(item);
                            };
                        });
                        console.log("3.5");
                        console.log("(4) Parent div: " + divConfigPanelParent);
                        currentParent = document.getElementById(configDiv).parentNode.id;
                        console.log("(5) Current parent for " + configDiv + " is " + currentParent);
                        divConfigPanelChild = document.getElementById(configDiv);
                        divConfigPanelParent.appendChild(divConfigPanelChild);
                        console.log(document.querySelectorAll('[id=' + configDiv + ']'));            
                    }
                    
                    let divConfigNumber = document.querySelectorAll('[id=' + configDiv + ']').length;
                    console.log("(6) Div " + configDiv + " is present " + divConfigNumber + " times");
                    
                    let displayType;
                    if ( configDiv === "system-check-div" ) {
                        displayType = "flex";
                    } else {
                        displayType = "block";
                    }
                    divConfigPanelChild.style.display = displayType;
                } catch(e) {
                   console.log("Error in moveDivToConfigPanel(configDiv) function: " + e);
                }
            }
            
            function updateNavigationFooter(previous, next) {
                
                console.log("Inside updateNavigationFooter(previous, next). Received params: " + previous + ", " + next);
                let chevronsToShow;

                document.getElementById('config-panel-footer-left-nav-div').setAttribute( "onClick", "change_panel_selection('" + previous +"')" );
                document.getElementById('config-panel-footer-right-nav-div').setAttribute( "onClick", "change_panel_selection('" + next + "')" );
                                    
                if ( previous === '') {
                    chevronsToShow = "right-only";
                    console.log("Inside right-only");
                } else if ( next === '') {
                    chevronsToShow = "left-only";
                    console.log("Inside left-only");
                }  else {
                    chevronsToShow = "both";
                    console.log("Inside both");
                }
                          
                if ( chevronsToShow === "both" ) {
                    document.getElementById("config-panel-footer-left-nav-div").style.display = "block";
                    document.getElementById("config-panel-footer-right-nav-div").style.display = "block";
                    document.getElementById("config-navigator-footer").style.justifyContent = "space-between";
                } else if ( chevronsToShow === "left-only" ) {
                    document.getElementById("config-panel-footer-left-nav-div").style.display = "block";
                    document.getElementById("config-panel-footer-right-nav-div").style.display = "none";
                    document.getElementById("config-navigator-footer").style.justifyContent = "flex-start";
                } else { 
                    document.getElementById("config-panel-footer-left-nav-div").style.display = "none";
                    document.getElementById("config-panel-footer-right-nav-div").style.display = "block";
                    document.getElementById("config-navigator-footer").style.justifyContent = "flex-end";
                }
                               

            }
            
            function waitForElement(elementId, callBack){
              window.setTimeout(function(){
                let element = document.getElementById(elementId);
                if(element){
                  callBack(elementId, element);
                }else{
                  waitForElement(elementId, callBack);
                }
              },500)
            }
            
            function loadFirstConfigPanel() {
                waitForElement('select-profile-div',function(){
                    change_panel_selection('config-panel-profile-selection');
                });
            }
            
        </script>
    </head>
    <body>
    <style scoped="scoped" onload="changeBuildButton();">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (header): ${e}"
}
