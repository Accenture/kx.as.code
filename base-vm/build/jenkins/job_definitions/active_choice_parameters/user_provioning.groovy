import groovy.json.JsonSlurper


try {
    // language=HTML
    def HTML = """
    <head>
        <style>

        .user-table {
            display:table;
            width: 1100px;
        }

        .user-header {
            display:table-header-group;
            font-weight:bold;
            line-height: 40px;
        }

        .user-rowGroup {
            display:table-row-group;
        }

        .user-row {
            display:table-row;
            line-height: 40px;
        }

        .user-row-added {
            display:table-row;
            line-height: 40px;
        }

        .user-cell {
            display:table-cell;
            width:180px;
        }

        .user-cell-email {
            width:250px;
        }

        .user-image-cell {
            display:table-cell;
            width:60px;
            cursor: pointer;
        }

        .user-input-box {
            width: 170px;
            padding: 10px 0 10px 5px;
        }

        .user-input-box-email {
            width: 245px;
        }

        .user-table-container {
            max-width: 1250px;
            display: -webkit-box;
            display: -moz-box;
            display: -ms-flexbox;
            display: -webkit-flex;
            max-height: 290px;
            overflow-y: auto;
            scrollbar-gutter: both-edges;
            scrollbar-width: thin;
        }

        .user-table-container::-webkit-scrollbar {
            width: 16px;
        }

        .user-table-container::-webkit-scrollbar-track {
            background-color: #efefef;
            border-radius: 0px;
        }

        .user-table-container::-webkit-scrollbar-thumb {
            border: 5px solid transparent;
            border-radius: 100px;
            background-color: #e5c4ff;
            background-clip: content-box;
        }

        </style>
        <script>

        function addUserToTable() {

            console.log("Entered addUserToTable()");
            let userFirstName = document.getElementById("user-details-firstname").value;
            let userSurname = document.getElementById("user-details-surname").value;
            let userEmail = document.getElementById("user-details-email").value;
            userEmail = userEmail.replaceAll(/\\s/g, "");
            let userKeyboard = document.getElementById("user-details-keyboard").value;
            let userRole = document.getElementById("user-details-role").value;

            let tableRowHtml = '<div class="user-cell" id="firstname_' + userEmail + '">' + userFirstName + '</div>' +
                '<div class="user-cell" id="surname_' + userEmail + '">' + userSurname + '</div>' +
                '<div class="user-cell user-cell-email" id="email_' + userEmail + '">' + userEmail + '</div>' +
                '<div class="user-cell" id="keyboard_' + userEmail + '">' + userKeyboard + '</div>' +
                '<div class="user-cell" id="role_' + userEmail + '">' + userRole.charAt(0).toUpperCase() + userRole.slice(1) + '</div>' +
                '<div class="user-image-cell"><img src="/userContent/icons/delete.svg" title="remove user" alt="remove user" onclick="removeUserFromTable(&quot;' + userEmail + '&quot;);"></div>';
             console.log(tableRowHtml);
             let userTableDiv = document.createElement('div');
             userTableDiv.className = 'user-row-added';
             userTableDiv.id = userEmail;
             userTableDiv.innerHTML = tableRowHtml;
             document.getElementById('user-row-group').appendChild(userTableDiv);
             buildUserJsonFromDivTable()

        }

        function removeUserFromTable(userTableRowDivToRemove) {
            let userRowToDeleteElement = document.getElementById(userTableRowDivToRemove);
            userRowToDeleteElement.remove();
            buildUserJsonFromDivTable()
        }

        function getTableRows() {
            let divRowList = [];
            let everyChild = document.querySelectorAll(".user-row-added");
            for (let i = 0; i<everyChild.length; i++) {
                console.log(everyChild[i].id);
                if ( everyChild[i].id !== null && everyChild[i].id !== "") {
                    divRowList.push(everyChild[i].id);
                }
            }
            console.log(divRowList);
            return divRowList;
        }

        function buildUserJsonFromDivTable() {
            let userTableRows = getTableRows();
            let userJsonNodes = [];
            let userJsonNode;
            let userRowElement;
            let userFirstName;
            let userSurname;
            let userEmail;
            let userKeyboard;
            let userRole;
            for (let i = 0; i<userTableRows.length; i++) {
                userRowElement = document.getElementById(userTableRows[i]).id;
                console.log(userRowElement);
                userFirstName = document.getElementById("firstname_" + userRowElement).innerText;
                userSurname = document.getElementById("surname_" + userRowElement).innerText;
                userEmail = document.getElementById("email_" + userRowElement).innerText;
                userKeyboard = document.getElementById("keyboard_" + userRowElement).innerText;
                userRole = document.getElementById("role_" + userRowElement).innerText;
                userJsonNode = '{ "userFirstName": "' + userFirstName + '", "userSurname": "' + userSurname + '", "userEmail": "' + userEmail + '", "userKeyboard": "' + userKeyboard + '", "userRole": "' + userRole + '"}';
                userJsonNodes.push(userJsonNode);
                console.log("*****************************");
            }
            console.log("getTableRowsElementList() --> to JSON")
            let allUsersJson = '{ "config": { "additionalUsers": [' + userJsonNodes.toString() + '] } }';
            console.log(JSON.parse(allUsersJson))
            document.getElementById('concatenated-user-provisioning-list').value = allUsersJson;
            let parentId = document.getElementById("concatenated-user-provisioning-list").parentNode.id;
            jQuery('#' + parentId).trigger('change');

        }

        </script>
    </head>
    <body>
        <div id="user-provisioning-div" style="display: none;">

        <h1>User Provisioning</h1>
        <div><span class="description-paragraph-span"><p>Here you can determine additional users to provision in the KX.AS.CODE environment. This is optional. If you do not specify additional users, then only the base user will be available for logging into the desktop and all provisioned tools. This is most likely sufficient if you are planning to run a local setup only.</p></span></div>
        <br><br>
        <div class="user-table">
          <div class="user-header">
            <div class="user-cell">
                First Name<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell">
                Surname<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell user-cell-email">
                Email<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell">
                Keyboard<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell">
                Role<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-image-cell">
            </div>
          </div>
          <div class="user-rowGroup">
            <div class="user-row">
                <div class="user-cell">
                    <span class="input-box-span">
                        <input class="input-box user-input-box" id="user-details-firstname" type="text"  value="">
                    </span>
                </div>
                <div class="user-cell">
                    <span class="input-box-span">
                        <input class="input-box user-input-box" id="user-details-surname" type="text"  value="">
                    </span>
                </div>
                <div class="user-cell user-cell-email">
                    <span class="input-box-span">
                        <input class="input-box user-input-box user-input-box-email" id="user-details-email" type="text"  value="">
                    </span>
                </div>
                <div class="user-cell">
                    <span class="input-box-span">
                        <select id="user-details-keyboard" class="templates-select user-input-box">
                            <option value="en_US">English (US)</option>
                            <option value="en_GB">English (GB)</option>
                            <option value="de_DE">German</option>
                            <option value="fr_FR">French</option>
                            <option value="es_ES">Spanish</option>
                        </select>
                    </span>
                </div>
                <div class="user-cell">
                    <span class="input-box-span">
                        <select id="user-details-role" class="templates-select user-input-box">
                            <option value="admin">Admin</option>
                            <option value="user">User</option>
                        </select>
                    </span>
                </div>
                <div class="user-image-cell">
                   <img src="/userContent/icons/account-plus.svg" title='add user' alt="add user" onclick='addUserToTable();'>
                </div>
                </div>
            </div>
        </div>

        <br><br>
        <div class="user-table-container" id="div-user-table-container">
        <div class="user-table">
          <div class="user-header">
            <div class="user-cell">
                First Name<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell">
                Surname<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell user-cell-email">
                Email<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell">
                Keyboard<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-cell">
                Role<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Imfotext</span></span></div>
            </div>
            <div class="user-image-cell">
            </div>
          </div>
          <div class="user-rowGroup" id='user-row-group'>
            <div class="user-row">
              <div class="user-cell" id='base-user-firstname'>KX</div>
              <div class="user-cell" id='base-user-surname'>Hero</div>
              <div class="user-cell user-cell-email" id='base-user-email'>kx.hero@kx-as-code.local</div>
              <div class="user-cell" id='base-user-keyboard'>en_US</div>
              <div class="user-cell" id=''>Admin</div>
              <div class="user-image-cell"><img src="/userContent/icons/delete.svg" title="remove user" alt="remove user" style="opacity: 0.2; cursor: not-allowed;"></div>
            </div>
          </div>
        </div>
        </div>
    </div>
    </body>

    <input type="hidden" id="concatenated-user-provisioning-list" name="value" value="" >
    <style scoped="scoped" onload="">   </style>
    """
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (user_provioning.groovy): ${e}"
}
