def extendedDescription = "Here you can select an application group from a list of available templates. An application group is a set of applications that are commonly deployed together, and in many cases they will also be integrated within KX.AS.CODE."

try {
    println("Entered Review and Launch Parameter")
    //println(templateComponentsArray)
} catch(e) {
    println "Something went wrong in the GROOVY block (review_and_launch): ${e}"
}

try {
    // language=HTML
    def HTML = """
    <head>
        <script> 
        </script>
        <style>
        
            .table {
                display:table;
            }
            .header {
                display:table-header-group;
                font-weight:bold;
            }
            .rowGroup {
                display:table-row-group;
            }
            .row {
                /*display:table-row;*/
                margin: 5px;
            }
            .cell {
                display:table-cell;
            }
            
            .cell-label {
                background-color: #0a53be;
                color: white;
                vertical-align: middle;
                border-bottom-left-radius: 5px;
                border-top-left-radius: 5px;
                width: 270px;
                height: 40px;
                padding-left: 15px;
                padding-top: 5px;
                padding-bottom: 5px;
            }
            
            .cell-value {
                background-color: white;
                width: 140px;
                height: 40px;
                padding-right: 15px;
                padding-top: 5px;
                padding-bottom: 5px;
                text-align: right;
                vertical-align: middle;
                border: 1px solid  #0a53be;
                border-spacing: 15px;/*cellspacing:poor IE support for  this*/
                border-bottom-right-radius: 5px;
                border-top-right-radius: 5px;
            }
        
            .flex-wrapper {
                flex-flow: row wrap;
                justify-content: space-between;
                flex-wrap: wrap;
                /*background-color: green;*/
            }
            
            .flex-item {
                display: block;
                width: 46%;
                /*background-color: orange;*/
                height: 160px;
            }
            
        </style>
    </head>
    <body>
    <div id="review-and-launch-div" class="flex-wrapper" style="display: none;">
        <div class="flex-item">
            <div class="table">
                <div class="row">
                    <div class="cell cell-label">Profile</div>
                    <div class="cell cell-value">Vmware Desktop</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Standalone Mode</div>
                    <div class="cell cell-value">False</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Allow Workloads on K8s Master</div>
                    <div class="cell cell-value">True</div>
                </div>
            </div>
        </div>
        <div class="flex-item">
            <div class="table">
                <div class="row">
                    <div class="cell cell-label">Network Storage</div>
                    <div class="cell cell-value">200GB</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Local Storage</div>
                    <div class="cell cell-value">100GB</div>
                </div>
            </div>
        </div>
        <div class="flex-item">
            <div class="table">
                <div class="row">
                    <div class="cell cell-label">Number of KX-Main Nodes</div>
                    <div class="cell cell-value">3</div>
                </div>
                <div class="row">   
                    <div class="cell cell-label">Total KX-Main CPU Cores Required</div>
                    <div class="cell cell-value">8</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Total KX-Main Memory Required</div>
                    <div class="cell cell-value">16GB</div>
                </div>
            </div>    
        </div>  
        <div class="flex-item">
            <div class="table">      
                <div class="row">
                    <div class="cell cell-label">Number of KX-Worker Nodes</div>
                    <div class="cell cell-value">4</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Total KX-Worker CPU Cores Required</div>
                    <div class="cell cell-value">4</div>
                </div>
                <div class="row">
                    <div class="cell cell-label">Total KX-Worker Memory Required</div>
                    <div class="cell cell-value">8GB</div>
                </div>
            </div>
        </div>
    </div>
    </body>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (review_and_launch): ${e}"
}
