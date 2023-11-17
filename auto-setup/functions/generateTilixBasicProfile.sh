generateTilixBasicProfile() {

    local taskScript=${1:-}
    local shortcutDestinationFolder=${2:-"${taskShortcutsDirectory}/${componentName}"}


    # Create Directory
    mkdir -p ${shortcutDestinationFolder}

    local jsonProfile=$(basename "${taskScript}" ".sh")
    local windowTitle=$(echo ${jsonProfile}  | sed 's/^\.//' | sed 's/_/ /g')
    export jsonProfilePath="${shortcutDestinationFolder}/${jsonProfile}-tilix-profile.json"

    echo '''{
        "child": {
            "directory": "",
            "height": 540,
            "overrideCommand": "bash -c '${shortcutDestinationFolder}'/'${taskScript}'",
            "profile": "2b7c4080-0ddd-46c5-8f23-563fd3ba789d",
            "readOnly": false,
            "synchronizedInput": true,
            "title": "'${windowTitle}'",
            "type": "Terminal",
            "uuid": "2b6257e7-4ccc-4ef7-9592-3ffad98ab77c",
            "width": 802
        },
        "height": 540,
        "name": "'${windowTitle}'",
        "synchronizedInput": false,
        "type": "Session",
        "uuid": "cc506bef-f9b0-4e1e-8e44-5cef0473616b",
        "version": "1.0",
        "width": 802
    }
    ''' | jq | /usr/bin/sudo tee ${jsonProfilePath}

}