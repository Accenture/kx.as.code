def extendedDescription
def profile_paths = []

try {

    extendedDescription = "Welcome to KX.AS.CODE. In this panel you can select the profile. A check is made on the system to see if the necessary virtualization software and associated Vagrant plugins are installed, s well as availability of built Vagrant boxes. An attempt is made to automatically select the profile based on discovered pre-requisites."

    new File('jenkins_shared_workspace/kx.as.code/profiles/').eachDirMatch(~/.*vagrant.*/) { profile_paths << it.path }

    String underlyingOS
    println profile_paths

    def OS = System.getProperty("os.name", "generic").toLowerCase(Locale.ENGLISH);
    if ((OS.indexOf("mac") >= 0) || (OS.indexOf("darwin") >= 0)) {
        underlyingOS = "darwin"
    } else if (OS.indexOf("win") >= 0) {
        underlyingOS = "windows"
        profile_paths.removeAll { it.toLowerCase().endsWith('parallels') }
    } else if (OS.indexOf("nux") >= 0) {
        underlyingOS = "linux"
    } else {
        underlyingOS = "other"
    }
    println("After OS and before sort()")

    profile_paths.sort()
    profile_paths = profile_paths.join(",")
    profile_paths = profile_paths.replaceAll("\\\\", "/")
    println(profile_paths)
    println("End of get_profiles.groovy GROOVY code")
} catch(e) {
    println("Something went wrong in the GROOVY block (get_profiles): ${e}")
}

try {
    // language=HTML
    def HTML = """
        <script>

            function populate_profile_option_list() {
                let profiles = "${profile_paths}".split(',');
                console.log("js profiles array: " + profiles)
                for ( let i = 0; i < profiles.length; i++ ) {
                    let profileName = profiles[i].split("/").pop();
                    profileName = profileName.replace("vagrant-", "");
                    console.log("Adding profile to options: " + profileName + i);
                    document.getElementById("profiles").options[i] = new Option(profileName, profileName);
                    update_selected_value();
                }
            }

            function update_selected_value() {
                let selectedOptionNumber = document.getElementById("profiles").selectedIndex;
                let profilePaths = "${profile_paths}".split(',');
                let profilePath = profilePaths[selectedOptionNumber] + '/profile-config.json'
                console.log("profileName: " + profilePath)
                document.getElementById("selected-profile-path").value = profilePath;
                document.getElementById("selected-profile-path").setAttribute("selected-profile-path", profilePath) ;
                let parentId = document.getElementById("selected-profile-path").parentNode.id;
                console.log(parentId);
                jQuery('#' + parentId).trigger('change');
            }

        </script>
        <style>

            .capitalize {
                text-transform: capitalize;
            }

            .profiles-select {
                -moz-appearance: none;
                -webkit-appearance: none;
                appearance: none;
                padding-left: 10px;
                cursor: pointer;
                border: none;
                width: 200px;
                height: 40px;
                border-top-right-radius: 5px;
                border-bottom-right-radius: 5px;
                background-image: url("/userContent/icons/chevron-down.svg");
                background-repeat: no-repeat;
                background-position: right;
                background-color: #efefef;
                outline: none;
                border: none;
                box-shadow: none;
            }

            select {
                height: 20px;
                -webkit-border-radius: 0;
                border: 0;
                outline: 1px solid #ccc;
                outline-offset: -1px;
            }

            .profiles-select select {
                 outline: none;
                 border: none;
                 box-shadow: none;
             }

            .profiles-select:focus {
                outline: none;
                border: none;
                box-shadow: none;
            }

        </style>
    <body>
        <div id="select-profile-div" style="display: none;">
            <h2>Profiles</h2>
            <label for="profiles" class="input-box-label" style="margin: 0px;">Profiles</label>
                <select id="profiles" class="profiles-select capitalize" style="margin: 0px;" value="Virtualbox" onchange="update_selected_value();">
                </select>
            </label>
        </div>
        <input type="hidden" id="selected-profile-path" name="value" value="">
        <style scoped="scoped" onload="populate_profile_option_list();">   </style>
    </body>
    """
    return HTML
} catch (e) {
    println("Something went wrong in the HTML return block (get_profiles): ${e}")
}
