#!/bin/bash -eux

easyRsaVersion=v3.0.6

cd ~/EasyRSA-${easyRsaVersion}/

./easyrsa init-pki

./easyrsa build-ca nopass

