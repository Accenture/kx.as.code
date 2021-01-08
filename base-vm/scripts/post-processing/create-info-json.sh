#!/bin/bash -x

cp ../../../templates/info.template boxes/info.json

# Check is running from Mac (Darwin) or Linux (including WSL and Windows Git Bash)
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' "s/##USERNAME##/Accenture Interactive/" boxes/info.json
else
    sed -i "s/##USERNAME##/Accenture Interactive/" boxes/info.json
fi
