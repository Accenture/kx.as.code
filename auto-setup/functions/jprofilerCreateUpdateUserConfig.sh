jprofilerCreateUpdateUserConfig() {

    local kubePodLabels=${1:-}
    local kubeNamespace=${2:-}
    local username=${3:-$baseUser}
    local jprofilePort=${4:-31757}
    local jprofilerDirectory=$(find /opt -maxdepth 1 -type d -name "jprofiler*" | tail -1)
    local jProfilerVersion=$(cat ${jprofilerDirectory}/release | cut -d'=' -f2)
    local jProfilerUserConfigDirectoryPath="/home/${username}/.$(basename ${jprofilerDirectory})"
    local jprofilerJreVersion=$(${jprofilerDirectory}/jre/bin/java --version | head -1 | cut -d' ' -f2)
    local systemJavaVrsion=$(java --version | head -1 | cut -d' ' -f2)

    if [[ ! -d "${jProfilerUserConfigDirectoryPath}" ]]; then
        mkdir -p ${jProfilerUserConfigDirectoryPath}
        chown ${username}:${username} ${jProfilerUserConfigDirectoryPath}
    fi

    if [[ -z ${kubeNamespace} ]]; then
        local kubeNameSpaceOption="--all-namespaces"
    else
        local kubeNameSpaceOption="-n ${kubeNamespace}"
    fi

    # Create XML for JProfiler General Config
    local jProfilerXmlConfigHeader='<?xml version="1.0" encoding="UTF-8"?>
    <config version="'${jProfilerVersion}'">
    <licenseKey name="Evaluation" company="" authenticationFilePath="" key="" />
    <generalSettings setupHasRun="true">
        <jvmConfigurations defaultId="100">
        <jvmConfiguration name="Debian JRE '${systemJavaVrsion}'" id="100" javaHome="/usr/lib/jvm/default-java" version="'${systemJavaVrsion}'" vendor="Debian" arch="amd64" isJRE="true" />
        <jvmConfiguration name="Debian JRE '${systemJavaVrsion}'" id="101" javaHome="/usr/lib/jvm/java-11-openjdk-amd64" version="'${systemJavaVrsion}'" vendor="Debian" arch="amd64" isJRE="true" />
        <jvmConfiguration name="JetBrains s.r.o. JRE '${jprofilerJreVersion}'" id="102" javaHome="'${jprofilerDirectory}'/jre" version="'${jprofilerJreVersion}'" vendor="JetBrains s.r.o." arch="amd64" isJRE="true" />
        </jvmConfigurations>
        <directoryPresets settingsExport="/home" />
        <recordingProfiles>
        <recordingProfile name="CPU recording" id="10">
            <actionKey id="cpu" />
        </recordingProfile>
        </recordingProfiles>
    </generalSettings>
    <sessions>'

    # Create sessions
    local numberOfConfiguredSessions=0
    local jProfilerXmlConfigSession=""
    local jProfilerXmlConfigSessions=""
    for kubePodLabel in ${kubePodLabels}
    do
        kubePodsIpList="$(kubectl get pods ${kubeNameSpaceOption} -o json | jq -r ' .items[] | select(.status.containerStatuses[].name=="'${kubePodLabel}'" and .metadata.deletionTimestamp==null and .status.reason!="Evicted") | .status.podIPs[].ip')"
        for kubePodsIp in ${kubePodsIpList}
        do
            ((numberOfConfiguredSessions++))
            sessionId=$((numberOfConfiguredSessions+100))
            jProfilerXmlConfigSession='<session id="'${sessionId}'" name="'${kubePodLabel}' on '${kubePodsIp}'" type="remote" host="'${kubePodsIp}'" port="'${jprofilePort}'" jvmConfigurationId="100" recordArrayAlloc="false" compilationMode="manual" compilationTarget="1.8">
            <filters>
                <group type="exclusive" name="Default excludes" template="defaultExcludes" />
            </filters>
            </session>'
            jProfilerXmlConfigSessions="${jProfilerXmlConfigSessions}${jProfilerXmlConfigSession}"
        done
    done

    # Create XML for JProfiler Footer Config
    ((sessionId++))
    local jProfilerXmlConfigFooter='  </sessions>
      <nextId id="'${sessionId}'" />
    </config>'

    # Back up old config if it exists
    if [[ -f ${jProfilerUserConfigDirectoryPath}/jprofiler_config.xml ]]; then
        cp ${jProfilerUserConfigDirectoryPath}/jprofiler_config.xml ${jProfilerUserConfigDirectoryPath}/jprofiler_config.xml_backup
    fi

    # Put XML together and create file
    log_debug "Generated JProfile config: ${jProfilerXmlConfigHeader}${jProfilerXmlConfigSessions}${jProfilerXmlConfigFooter}"
    echo "${jProfilerXmlConfigHeader}${jProfilerXmlConfigSessions}${jProfilerXmlConfigFooter}" | xmllint --format - | tee /home/${username}/.jprofiler13/jprofiler_config.xml
    chown -R ${username}:${username} ${jProfilerUserConfigDirectoryPath}

}