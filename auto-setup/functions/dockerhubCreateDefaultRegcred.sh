dockerhubCreateDefaultRegcred() {

  namespace=${1:-default}

  # Login to Dockerhub
  dockerhubLogin

  if [[ $(cat /root/.docker/config.json | jq '.auths | has("https://index.docker.io/v1/") ') == "true" ]]; then
   
    # Create secret
    kubectl get secret regcred -n ${namespace} || \
      kubectl create secret generic regcred \
          --from-file=.dockerconfigjson=/root/.docker/config.json \
          --type=kubernetes.io/dockerconfigjson \
          -n ${namespace}

  else

    # Send warning
    log_warn "Dockerhub credentials not found, so could not create appropriate regcred. This is only an issue if you intent to do a lot of Docker image downloads, as this might cause you to reach your download rate limit"

  fi

}
