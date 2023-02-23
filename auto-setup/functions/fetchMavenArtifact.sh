fetchMavenArtifact() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local artifactGroup=${1}
  local artifactId=${2}
  local artifactVersion=${3}
  local artifactExtension=${4}
  local targetDirectory=${5}

  mkdir -p ${targetDirectory}

  docker run --rm -v ${targetDirectory}:/root/.m2 maven \
    mvn org.apache.maven.plugins:maven-dependency-plugin:2.1:get \
      -DrepoUrl=repo1.maven.org \
      -Dartifact=${artifactGroup}:${artifactId}:${artifactVersion}:${artifactExtension}

  # Verify artifact downloaded OK
  export mavenDownloadedFilePath=$(find ${targetDirectory} -name ${artifactId}-${artifactVersion}.${artifactExtension})
  if [[ -f ${mavenDownloadedFilePath} ]]; then
    log_info "Maven artifact file ${artifactId}-${artifactVersion}.${artifactExtension} - downloaded successfully"
  else
    log_error "Maven artifact file - ${artifactId}-${artifactVersion}.${artifactExtension} - was not downloaded successfully. Please check you have entered everything correctly"
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}