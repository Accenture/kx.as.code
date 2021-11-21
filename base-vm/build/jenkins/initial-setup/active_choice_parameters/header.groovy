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
                if (baseDomain.value.length === 0) {
                    baseDomainValue = baseDomain.placeholder.trim();
                } else {
                    baseDomainValue = baseDomain.value.trim();
                }
    
                let username = document.getElementById("username");
                if (username.value.length === 0) {
                    usernameValue = username.placeholder.trim();
                } else {
                    usernameValue = username.value.trim();
                }
    
                let teamName = document.getElementById("team-name");
                if (teamName.value.length === 0) {
                    teamNameValue = teamName.placeholder.trim();
                } else {
                    teamNameValue = teamName.value.trim();
                }
    
                let password = document.getElementById("password");
                if (password.value.length === 0) {
                    passwordValue = password.placeholder.trim();
                } else {
                    passwordValue = password.value.trim();
                }
    
                document.getElementById("concatenated-general-params").value = baseDomainValue + ";" + usernameValue + ";" + teamNameValue + ";" + passwordValue;
                console.log(document.getElementById("concatenated-general-params").value);
            }
    
            function updateCheckbox(checkbox, checkboxElementId, standaloneMode)
            {
                console.log("checkbox: " + checkbox, ", checkboxElementId: " + checkboxElementId, ", standaloneMode: " + standaloneMode);
                console.log("document.getElementById(system-prerequisites-check).value: *" + document.getElementById("system-prerequisites-check").value + "*");
    
                if (document.getElementById("system-prerequisites-check").value === "standalone") {
                    console.log("DEBUG: Inside checkbox set to standalone");
                    document.getElementById('standalone_mode_checkbox').className="checkbox-slider-checked-disabled round";
                    document.getElementById('standalone_mode_span').className="checkbox-slider-checked-disabled round";
                } else if (document.getElementById("system-prerequisites-check").value === "full") {
                    console.log("DEBUG: Inside checkbox set to full");
                    document.getElementById('standalone_mode_checkbox').className="checkbox-slider round";
                    document.getElementById('standalone_mode_span').className="checkbox-slider round";
                }
    
                console.log("before checkbox.checked if statement: " + checkbox);
    
                if (checkbox === true)
                {
                    document.getElementById(checkboxElementId).value = true;
                    document.getElementById(checkboxElementId).checked = true;
                    let checkbox = document.getElementById(checkboxElementId).value;
                } else {
                    document.getElementById(checkboxElementId).value = false;
                    document.getElementById(checkboxElementId).checked = false;
                    let checkbox = document.getElementById(checkboxElementId).value;
                }
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
                parentId = document.getElementById('concatenated-local-volume-params').parentNode.id;
                console.log(parentId);
                jQuery('#' + parentId).trigger('change');
            }
    
            function hideParameterDivs() {
                document.getElementById("standalone-toggle-div").style.display = "none";
                document.getElementById("worker-cpu-count-div").style.display = "none";
                document.getElementById("worker-node-count-div").style.display = "none";
                document.getElementById("main-node-count-div").style.display = "none";
                document.getElementById("local-storage-div").style.display = "none";
                document.getElementById("main-memory-div").style.display = "none";
                document.getElementById("general-parameters-div").style.display = "none";
                document.getElementById("workloads-on-master-div").style.display = "none";
                document.getElementById("main-cpu-count-div").style.display = "none";
                document.getElementById("worker-memory-div").style.display = "none";
                document.getElementById("network-storage-div").style.display = "none";
                document.getElementById("headline-main-div").style.display = "none";
                document.getElementById("headline-workers-div").style.display = "none";
                document.getElementById("headline-storage-div").style.display = "none";
                document.getElementById("templates-div").style.display = "none";
                document.getElementById("system-check-div").style.display = "none";
            }
    
            function showParameterDivs() {
                document.getElementById("standalone-toggle-div").style.display = "block";
                document.getElementById("worker-cpu-count-div").style.display = "block";
                document.getElementById("worker-node-count-div").style.display = "block";
                document.getElementById("main-node-count-div").style.display = "block";
                document.getElementById("local-storage-div").style.display = "block";
                document.getElementById("main-memory-div").style.display = "block";
                document.getElementById("general-parameters-div").style.display = "block";
                document.getElementById("workloads-on-master-div").style.display = "block";
                document.getElementById("main-cpu-count-div").style.display = "block";
                document.getElementById("worker-memory-div").style.display = "block";
                document.getElementById("network-storage-div").style.display = "block";
                document.getElementById("headline-main-div").style.display = "block";
                document.getElementById("headline-workers-div").style.display = "block";
                document.getElementById("headline-storage-div").style.display = "block";
                document.getElementById("templates-div").style.display = "inline-block";
                document.getElementById("system-check-div").style.display = "flex";
            }

            function switchParameterDiv(parameterGroup) {
                console.log("parameterGroup: " + parameterGroup);
                hideParameterDivs()
                switch (parameterGroup) {
                    case "prerequisites":
                        document.getElementById("prerequisites-div").style.display = "block";
                        break;
                    case "general-parameters":
                        document.getElementById("general-parameters-div").style.display = "block";
                        document.getElementById("standalone-toggle-div").style.display = "block";
                        document.getElementById("workloads-on-master-div").style.display = "block";
                        break;
                    case "kx-main":
                        document.getElementById("headline-main-div").style.display = "block";
                        document.getElementById("main-node-count-div").style.display = "block";
                        document.getElementById("main-cpu-count-div").style.display = "block";
                        document.getElementById("main-memory-div").style.display = "block";
                        break;
                    case "kx-worker":
                        document.getElementById("headline-workers-div").style.display = "block";
                        document.getElementById("worker-node-count-div").style.display = "block";
                        document.getElementById("worker-cpu-count-div").style.display = "block";
                        document.getElementById("worker-memory-div").style.display = "block";
                        break;
                    case "storage":
                        document.getElementById("local-storage-div").style.display = "block";
                        document.getElementById("network-storage-div").style.display = "block";
                        break;
                    case "templates":
                        document.getElementById("templates-div").style.display = "inline-block";
                        break;            
                    case "host-check":
                        document.getElementById("system-check-div").style.display = "flex";
                        break;
                }
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
