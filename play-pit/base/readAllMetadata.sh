#!/bin/bash -x
set -euo pipefail

timestamp=$(date "+%Y%m%d_%H%M")
jsonFiles=$(find . -name "metadata.json")

for jsonFile in $jsonFiles; do
    jq -r '[{"name": .name, "install_folder": .installation_group_folder}]' $jsonFile | tee -a json_${timestamp}.txt
done

cat json_${timestamp}.txt | tr -d '\n' > json2_${timestamp}.txt
sed -i 's/\]\[/,/g' json2_${timestamp}.txt
echo '{"available_applications": '   | tee json_header.txt
echo "}" | tee json_footer.txt

cat json_header.txt json2_${timestamp}.txt json_footer.txt | tee json3_${timestamp}.json

cat json3_${timestamp}.json | jq -S '.available_applications | sort_by(.name)[]'
