gitlabCreateGroup() {

    gitlabGroupName=${1}
    visibility=${2-internal}
    lfsEnabled=${3-true}
    subgroupCreationLevel=${4-maintainer}
    projectCreationLevel=${5-developer}

    # Get Gitlab personal access token
    export personalAccessToken=$(getPassword "gitlab-personal-access-token")

    # Create kx.as.code group in Gitlab
    export gitlabGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="'${gitlabGroupName}'") | .id')
    if [[ -z ${gitlabGroupId} ]]; then
        for i in {1..5}; do
            curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
                --data 'name='${gitlabGroupName}'' \
                --data 'path='${gitlabGroupName}'' \
                --data 'full_name='${gitlabGroupName}'' \
                --data 'full_path='${gitlabGroupName}'' \
                --data 'visibility='${visibility}'' \
                --data 'lfs_enabled='${lfsEnabled}'' \
                --data 'subgroup_creation_level='${subgroupCreationLevel}'' \
                --data 'project_creation_level='${projectCreationLevel}'' \
                https://gitlab.${baseDomain}/api/v4/groups
            export gitlabGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="'${gitlabGroupName}'") | .id')
            if [[ -n ${gitlabGroupId} ]]; then break; else
                echo "KX.AS.CODE Group not created. Trying again"
                sleep 5
            fi
        done
    else
        log_info "\"${gitlabGroupName}\" group already exists in Gitlab. Skipping creation"
    fi



}