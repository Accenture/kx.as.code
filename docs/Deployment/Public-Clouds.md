# Public Cloud

## AWS

The solution works in the same way as for the local virtualization solutions, except that here there are additional things to take care of, such as the creation of networks and security_groups and so on.

The best way to see how it works is to view the AWS profile terraform scripts [here](https://github.com/Accenture/kx.as.code/tree/main/profiles/terraform-aws){:target="\_blank"}.

Before KX.AS.CODE can be started on AWS, it is necessary to build the AMI images. See [here](../../Build/Public-Clouds/) fore more details.

### Deployment Profile

Once the images are built, you need to adjust the [AWS deployment profile](https://github.com/Accenture/kx.as.code/blob/main/profiles/terraform-aws/profile-config.json){:target="\_blank"}.. Below an example. All the items specific to the deployment to AWS are highlighted.

The `sslProvider` is optional, but recommended for a public cloud setup. If setting  this to "self-signed", the users will need to import the hosts file and certificates located in `/kx-external-access` to their local machine.

```json linenums="1" hl_lines="2-4 6-8 10-11 13 34-35 46-51"
{
    "aws_region": "us-east-2",
    "aws_availability_zone_one": "us-east-2a",
    "aws_availability_zone_two": "us-east-2b",
    "vm_properties": {
        "kx_main_ami_id": "<the AMI ID of the image you built previously>",
        "admin_main_node_instance_type": "t3.xlarge",
        "replica_main_node_instance_type": "t3.large",
        "main_node_count": 3,
        "kx_node_ami_id": "<the AMI ID of the image you built previously>",
        "worker_node_instance_type": "t3.large",
        "worker_node_count": 4,
        "bastion_node_instance_type": "t3.nano"
    },
    "config": {
        "allowWorkloadsOnMaster": true,
        "disableSessionTimeout": true,
        "certificationMode": false,
        "disableLinuxDesktop": false,
        "defaultKeyboardLanguage": "de",
        "local_volumes": {
            "one_gb": 20,
            "five_gb": 15,
            "ten_gb": 10,
            "thirty_gb": 2,
            "fifty_gb": 1
        },
        "startupMode": "normal",
        "virtualizationType": "public-cloud",
        "updateSourceOnStart": "true",
        "environmentPrefix": "demo1",
        "glusterFsDiskSize": "200",
        "kubeOrchestrator": "k8s",
        "sslProvider": "letsencrypt",
        "letsEncryptEnvironment": "prod",
        "sslDomainAdminEmail": "admin@demo1.kx-as-code.io",
        "mxDnsRecord": "mail.kx-as-code.io",
        "baseDomain": "kx-as-code.io",
        "baseUser": "kx.hero",
        "basePassword": "L3arnandshare",
        "baseIpType": "dynamic",
        "metalLbIpRange": {
            "ipRangeStart": "10.0.76.200",
            "ipRangeEnd": "10.0.76.250"
        },
        "vpc_cidr_block": "10.0.0.0/16",
        "private_subnet_cidr_one": "10.0.76.0/24",
        "private_subnet_cidr_two": "10.0.5.0/24",
        "public_subnet_cidr_one": "10.0.3.0/24",
        "public_subnet_cidr_two": "10.0.4.0/24",
        "remote_access_cidrs": ["84.178.213.25/32"]
    },
    "docker": {
        "dockerhub_username": "",
        "dockerhub_email": "",
        "dockerhub_password": ""
    }
}
```

Once `profile-config.json` is configured, use `terraform init` and `terraform apply` to launch KX.AS.CODE into your AWS cloud account!