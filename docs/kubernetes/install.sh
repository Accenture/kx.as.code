#!/bin/bash -eux

. /etc/environment
export VM_USER=$vmUser

# Apply the KX.AS.CODE Docs configuration files
yamlFiles=$(find . -name "*.yaml")
for yamlFile in $yamlFiles
do
  cat $yamlFile | envhandlebars | kubectl apply -n devops -f -
done

