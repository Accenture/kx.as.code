dockerhubCreateDefaultRegcred() {

# Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  namespace=${1:-default}

  if [[ -f /var/tmp/.tmp.json ]]; then

    # Login to Dockerhub
    dockerhubLogin
    
    # Create secret
    kubectl get secret regcred -n ${namespace} | \
      kubectl create secret generic regcred \
          --from-file=.dockerconfigjson=/root/.docker/config.json \
          --type=kubernetes.io/dockerconfigjson \
          -n ${namespace}

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
