waitForKubernetesResource() {

  export resourceName=${1}
  export resourceType=${2}
  export resourceNamespace=${3-default}

  # Waiting for Kubernetes resource to be available
  timeout -s TERM 600 bash -c \
  'while [[ -z "$(/usr/bin/sudo kubectl get '${resourceType}' '${resourceName}' -n "'${resourceNamespace}'" --ignore-not-found)" ]]; \
    do \
      echo "Waiting for Kubernetes \"'${resourceType}'\" resource with name \"'${resourceName}'\" to be available in \"'${resourceNamespace}'\" namespace" && sleep 3; \
  done' ${1} ${2}

}
