#!/usr/bin/env bash

# helm sets up the Confluent Kafka by helm charts
helm () {
  if ! [ -x "$(command -v helm)" ]; then
    echo 'Error: helm is not installed.'
    exit 1
  fi

  helm init
  helm repo update
  helm list
  helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
  helm repo update
  helm install -f ./helm/values.yml my-confluent-oss confluentinc/cp-helm-charts
  helm list
  helm test my-confluent-oss

}

# helmDistroy removes the Confluent Kafka installed by helm charts
helmDistroy () {
  if ! [ -x "$(command -v helm)" ]; then
    echo 'Error: helm is not installed.'
    exit 1
  fi

  helm list
  helm uninstall my-confluent-oss

}

# help provides possible cli installation arguments
help () {
  echo "Accepted cli arguments are:"
  echo -e "\t[--help|-h ]\t->> prints this help"
  echo -e "\t[--setup-by|-s]\t->> sets up Kafka"
  echo -e "\t[--destroy|-d]\t->> remove Kafka"
}

if [[ $# -eq 0 ]]; then
    help
    exit 1
fi

set -u
while [[ $# -gt 0 ]]; do
  case $1 in
    '--setup-by'|-s)
      shift
      if [[ $# -ne 0 ]]; then
          case ${1} in
            'helm')
              helm
              exit 0
              ;;
          esac
      else
          echo -e "Please choose the desired way of setting up Kafka. e.g. --setup-by helm or -s helm"
          exit 0
      fi
      ;;
      '--destroy'|-d)
        shift
        if [[ $# -ne 0 ]]; then
            case ${1} in
              'helm')
                helmDistroy
                exit 0
                ;;
            esac
        else
            echo -e "Please choose the desired way of removing Kafka. e.g. --destroy helm or -d helm"
            exit 0
        fi
        ;;
    '--help'|-h)
       help
       exit 0
       ;;
    *)
       help
       exit 1
       ;;
  esac
  shift
done
set +u
