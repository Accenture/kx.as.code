#!/bin/bash -x

# Check if JQ is installed and download if not
if [[ -f ./jq ]]; then
  jqBinary='./jq'
else
  jqBinary='jq'
fi
jqVersion=$(${jqBinary} --version 2>/dev/null | grep -E "jq-([0-9]+)\.([0-9]+)")
if [[ -z ${jqVersion} ]]; then
  curl -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -L
  chmod 755 ./jq
  jqBinary='./jq'
  ${jqBinary} --version
fi

# Check if Terraform is installed and download if not
if [[ -f ./terraform ]]; then
  terraformBinary="./terraform"
else
  terraformBinary="terraform"
fi
terraformVersion=$(${terraformBinary} -v | head -1 2>/dev/null | grep -E "Terraform v([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${terraformVersion} ]]; then
  curl -o terraform.zip https://releases.hashicorp.com/terraform/0.14.4/terraform_0.14.4_linux_amd64.zip -L
  unzip terraform.zip
  chmod 755 ./terraform
  terraformBinary='./terraform'
  ${terraformBinary} -v
fi

# Check if AWS-CLI is installed and download if not
awsBinary="aws"
if [[ -f ./aws/dist/aws ]]; then
  awsBinary="./aws/dist/aws"
else
  awsBinary="aws"
fi
awsVersion=$(${awsBinary} --version | head -1 2>/dev/null | grep -E "aws-cli\/([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${terraformVersion} ]]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  awsBinary=./aws/dist/aws
  ${awsBinary} --version
fi

. ./tf-init.sh

# Only generate new SSH files if this is a new environment
environmentUp=$(terraform output -json | jq -r '."kx_main_instance_ip_addr".value')
if [[ -z ${environmentUp} ]] || [[ "${environmentUp}" == "null" ]]; then
  # Generate new .ssh key files
  ssh-keygen \
      -m PEM \
      -t rsa \
      -b 2048 \
      -C "kx.hero@kx-as-code.local" \
      -f .ssh/id_rsa \
      -N '' <<<y 2>&1 >/dev/null
fi

  id_rsa=$(<.ssh/id_rsa)
  id_rsa_pub=$(<.ssh/id_rsa.pub)
  autoSetup_json=$(<./autoSetup.json)

  echo "********** DEBUG ************"
  echo $id_rsa
  echo $id_rsa_pub

  # Create Init KX-Main TPL file with new SSH keys
  template=$(<init-main.tpl_template)
  echo "${template//---ID_RSA_PLACEHOLDER---/$id_rsa}" > init-main.tpl
  template=$(<init-main.tpl)
  echo "${template//---ID_RSA_PUB_PLACEHOLDER---/$id_rsa_pub}" > init-main.tpl
  template=$(<init-main.tpl)
  echo "${template//---AUTO_SETUP_JSON_PLACEHOLDER---/$autoSetup_json}" > init-main.tpl

  # Create Init KX-Worker TPL file with new SSH keys
  template=$(<init-worker.tpl_template)
  echo "${template//---ID_RSA_PLACEHOLDER---/$id_rsa}" > init-worker.tpl
  template=$(<init-worker.tpl)
  echo "${template//---ID_RSA_PUB_PLACEHOLDER---/$id_rsa_pub}" > init-worker.tpl
  template=$(<init-worker.tpl)
  echo "${template//---AUTO_SETUP_JSON_PLACEHOLDER---/$autoSetup_json}" > init-worker.tpl

# Deploy KX.AS.CODE to AWS
terraform init
terraform plan
terraform apply -auto-approve
terraform show -json

# Get VPN Endpoint ID
awsVpnEndpoint=$(terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="aws_ec2_client_vpn_endpoint") | .values.id')

# Export VPN client config file
aws ec2 export-client-vpn-client-configuration \
    --client-vpn-endpoint-id ${awsVpnEndpoint} \
    --output text > temp.ovpn

# Add VPN AWS client certs to exported VPN config file
if [[ -f ./temp.ovpn ]] && [[ -f ./.ovpn/cert ]] && [[ -f ./.ovpn/key ]]; then
  cat ./temp.ovpn  | tee ./kx-as-code.ovpn
  echo -e "\n"  | tee -a ./kx-as-code.ovpn
  cat ./.ovpn/cert  | tee -a ./kx-as-code.ovpn
  echo -e "\n"  | tee -a ./kx-as-code.ovpn
  cat ./.ovpn/key | tee -a ./kx-as-code.ovpn
  echo -e "\n"
else
  echo "One of ./temp.ovpn ./.ovpn/cert ./.ovpn/key is missing, so cannot generate OpenVPN client config file. Exiting."
  exit
fi

# Start OpenVPN connection
echo "Important: In order to access KX.AS.CODE, you will need to import the generated ovpn file into your openvpn client, and start the connection"
echo "Once your VPN session has started, you can access the remote desktop via NoMachine, or using the following SSH command:"
echo "sudo ssh -i .ssh/id_rsa kx.hero@kx-main.${TF_VAR_KX_DOMAIN}"