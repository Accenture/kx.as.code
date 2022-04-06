#!/bin/bash
set -euox pipefail

export influxdb2AdminToken=''$(getPassword "influxdb2-admin-token")''