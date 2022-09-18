import groovy.json.JsonSlurper

def parsedUserJson
def profileParentPath

try {

    File profilePath = new File(PROFILE.split(";")[0])
    profileParentPath = profilePath.getParentFile()

    File usersJsonFile = new File("${profileParentPath}/users.json")

    if ( usersJsonFile.exists() ) {
        parsedUserJson = usersJsonFile.text.replace("\n", "").replace("\r", "").replace(" ", "")
    }
} catch (e) {
    println("Something went wrong in the groovy user provisioning block (user_provisioning.groovy): ${e}")
}


try {

    // language=HTML
    def HTML = """
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
                    <input class="input-box user-input-box user-input-box-email" id="user-details-email" type="text" onkeyup="nospaces(this);" value="">
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
            First Name<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
        <div class="user-cell">
            Surname<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
        <div class="user-cell user-cell-email">
            Email<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
        <div class="user-cell">
            Keyboard<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
        </div>
        <div class="user-cell">
            Role<div class="tooltip-info"><span class="info-span"><img src="/userContent/icons/information-variant.svg" class="info-icon" alt="info"><span class="tooltiptext">Placeholder Infotext</span></span></div>
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
<input type="hidden" id="usersJson" value='${parsedUserJson}' >
<style scoped="scoped" onload="buildInitialUsersTableFromJson(document.getElementById('usersJson').value);">   </style>
"""
    return HTML
} catch (e) {
    println "Something went wrong in the HTML return block (user_provioning.groovy): ${e}"
}