#!/bin/bash -x
set -euo pipefail

# Get needed capacity for GlusterFS volumes disk size
export TF_VAR_GLUSTERFS_KUBE_VOLUMES_DISK_SIZE=$(cat ./profile-config.json | jq -r '.config.glusterFsDiskSize')

# Calculate needed local disk capacity
export number1gbVolumes=$(cat ./profile-config.json | jq -r '.config.local_volumes.one_gb')
export number5gbVolumes=$(cat ./profile-config.json | jq -r '.config.local_volumes.five_gb')
export number10gbVolumes=$(cat ./profile-config.json | jq -r '.config.local_volumes.ten_gb')
export number30gbVolumes=$(cat ./profile-config.json | jq -r '.config.local_volumes.thirty_gb')
export number50gbVolumes=$(cat ./profile-config.json | jq -r '.config.local_volumes.fifty_gb')
export TF_VAR_LOCAL_KUBE_VOLUMES_DISK_SIZE=$(((number1gbVolumes * 1) + (number5gbVolumes * 5) + (number10gbVolumes * 10) + (number30gbVolumes * 30) + (number50gbVolumes * 50) + 1))

# Get instance types
export TF_VAR_MAIN_INSTANCE_TYPE=$(cat ./config.json | jq -r '.config.instance_types.main')
if [[ -z ${TF_VAR_MAIN_INSTANCE_TYPE}   ]]; then
    echo "- [ERROR] MAIN_INSTANCE_TYPE not defined in ./config.json"
    error="true"
fi
export TF_VAR_WORKER_INSTANCE_TYPE=$(cat ./config.json | jq -r '.config.instance_types.worker')
if [[ -z ${TF_VAR_WORKER_INSTANCE_TYPE}   ]]; then
    echo "- [ERROR] WORKER_INSTANCE_TYPE not defined in ./config.json"
    error="true"
fi

if [[ ! -f ./config.json ]] || [[ ! -f ./profile-config.json ]]; then
    echo "One of the config files needed to start KX.AS.CODE on AWS is missing. Please ensure that both config.json and profile-config.json are present in this AWS profile directory and try again"
    exit 1
fi

export TF_VAR_ACCESS_KEY=$(cat ./config.json | jq -r '.config.ACCESS_KEY')
if [[ -z ${TF_VAR_ACCESS_KEY}   ]]; then
    echo "- [ERROR] ACCESS_KEY not defined in ./config.json"
    error="true"
fi

export TF_VAR_SECRET_KEY=$(cat ./config.json | jq -r '.config.SECRET_KEY')
if [[ -z ${TF_VAR_SECRET_KEY}   ]]; then
    echo "- [ERROR] SECRET_KEY not defined in ./config.json"
    error="true"
fi

export TF_VAR_KX_MAIN_AMI_ID=$(cat ./config.json | jq -r '.config.KX_MAIN_AMI_ID')
if [[ -z ${TF_VAR_KX_MAIN_AMI_ID}   ]]; then
    echo "- [ERROR] KX_MAIN_AMI_ID not defined in ./config.json"
    error="true"
fi

export TF_VAR_KX_WORKER_AMI_ID=$(cat ./config.json | jq -r '.config.KX_WORKER_AMI_ID')
if [[ -z ${TF_VAR_KX_WORKER_AMI_ID}   ]]; then
    echo "- [ERROR] KX_WORKER_AMI_ID not defined in ./config.json"
    error="true"
fi

export TF_VAR_REGION=$(cat ./config.json | jq -r '.config.REGION')
if [[ -z ${TF_VAR_REGION}   ]]; then
    echo "- [ERROR] REGION not defined in ./config.json"
    error="true"
fi

export TF_VAR_AVAILABILITY_ZONE=$(cat ./config.json | jq -r '.config.AVAILABILITY_ZONE')
if [[ -z ${TF_VAR_AVAILABILITY_ZONE}   ]]; then
    echo "- [ERROR] AVAILABILITY_ZONE not defined in ./config.json"
    error="true"
fi

export TF_VAR_VPC_CIDR_BLOCK=$(cat ./config.json | jq -r '.config.VPC_CIDR_BLOCK')
if [[ -z ${TF_VAR_VPC_CIDR_BLOCK}   ]]; then
    echo "- [ERROR] VPC_CIDR_BLOCK not defined in ./config.json"
    error="true"
fi

export TF_VAR_PRIVATE_ONE_SUBNET_CIDR=$(cat ./config.json | jq -r '.config.PRIVATE_ONE_SUBNET_CIDR')
if [[ -z ${TF_VAR_PRIVATE_ONE_SUBNET_CIDR}   ]]; then
    echo "- [ERROR] PRIVATE_ONE_SUBNET_CIDR not defined in ./config.json"
    error="true"
fi

export TF_VAR_PRIVATE_TWO_SUBNET_CIDR=$(cat ./config.json | jq -r '.config.PRIVATE_TWO_SUBNET_CIDR')
if [[ -z ${TF_VAR_PRIVATE_TWO_SUBNET_CIDR}   ]]; then
    echo "- [ERROR] PRIVATE_TWO_SUBNET_CIDR not defined in ./config.json"
    error="true"
fi

export TF_VAR_PUBLIC_SUBNET_CIDR=$(cat ./config.json | jq -r '.config.PUBLIC_SUBNET_CIDR')
if [[ -z ${TF_VAR_PUBLIC_SUBNET_CIDR}   ]]; then
    echo "- [ERROR] PUBLIC_SUBNET_CIDR not defined in ./config.json"
    error="true"
fi

export TF_VAR_VPN_SUBNET_CIDR=$(cat ./config.json | jq -r '.config.VPN_SUBNET_CIDR')
if [[ -z ${TF_VAR_VPN_SUBNET_CIDR}   ]]; then
    echo "- [ERROR] VPN_SUBNET_CIDR not defined in ./config.json"
    error="true"
fi

export TF_VAR_METALLB_FIRST_IP=$(cat ./config.json | jq -r '.config.METALLB_FIRST_IP')
if [[ -z ${TF_VAR_METALLB_FIRST_IP}   ]]; then
    echo "- [ERROR] METALLB_FIRST_IP not defined in ./config.json"
    error="true"
fi

export TF_VAR_PUBLIC_KEY=$(cat ./config.json | jq -r '.config.PUBLIC_KEY')
if [[ -z ${TF_VAR_PUBLIC_KEY}   ]]; then
    echo "- [ERROR] PUBLIC_KEY not defined in ./config.json"
    error="true"
fi

export TF_VAR_VPN_SERVER_CERT_ARN=$(cat ./config.json | jq -r '.config.VPN_SERVER_CERT_ARN')
if [[ -z ${TF_VAR_VPN_SERVER_CERT_ARN}   ]]; then
    echo "- [ERROR] ACCESVPN_SERVER_CERT_ARNS_KEY not defined in ./config.json"
    error="true"
fi

export TF_VAR_VPN_CLIENT_CERT_ARN=$(cat ./config.json | jq -r '.config.VPN_CLIENT_CERT_ARN')
if [[ -z ${TF_VAR_VPN_CLIENT_CERT_ARN}   ]]; then
    echo "- [ERROR] VPN_CLIENT_CERT_ARN not defined in ./config.json"
    error="true"
fi

export TF_VAR_KX_ENV_PREFIX=$(cat ./profile-config.json | jq -r '.config.environmentPrefix')
if [[ -z ${TF_VAR_KX_ENV_PREFIX}   ]]; then
    echo "- [WARNING] Optional parameter KX_ENV_PREFIX not defined as '.config.environmentPrefix' in ./profile-config.json"
fi

export TF_VAR_KX_DOMAIN=$(cat ./profile-config.json | jq -r '.config.baseDomain')
if [[ -z ${TF_VAR_KX_DOMAIN}   ]]; then
    echo "- [ERROR] KX_DOMAIN not defined as '.config.baseDomain' in ./profile-config.json"
    error="true"
fi

if [[ -n ${TF_VAR_KX_ENV_PREFIX}   ]] && [[ -n ${TF_VAR_KX_DOMAIN}   ]]; then
    export TF_VAR_KX_DOMAIN="${TF_VAR_KX_ENV_PREFIX}.${TF_VAR_KX_DOMAIN}"
fi

export TF_VAR_NUM_KX_WORKER_NODES=$(cat ./config.json | jq -r '.config.NUM_KX_WORKER_NODES')
if [[ -z ${TF_VAR_VPN_CLIENT_CERT_ARN}   ]]; then
    echo "- [ERROR] NUM_KX_WORKER_NODES not defined in ./config.json"
    error="true"
fi

if [[ ${error} == "true"   ]]; then
    echo "Above is a list of properties missing from ./config.json. Please complete missing values and try again."
    exit 1
fi
