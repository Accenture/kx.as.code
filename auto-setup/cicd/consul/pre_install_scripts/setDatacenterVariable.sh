#!/bin/bash

export dataCenterName=$(echo "${componentName}.${baseDomain}" | sed 's/\./-/g')
