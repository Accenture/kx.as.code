#!/bin/bash -eux

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Login to AWS ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 710110386009.dkr.ecr.eu-central-1.amazonaws.com

# Pull DevOps Images. TechRadar and KX.AS.CODE Docs
docker pull 710110386009.dkr.ecr.eu-central-1.amazonaws.com/z2h-devops-techradar:latest
docker pull 710110386009.dkr.ecr.eu-central-1.amazonaws.com/z2h-kxascode-docs:latest
