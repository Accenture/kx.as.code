#!/bin/bash -x
set -euo pipefail

# Generate Key
export encryptionKey=$(docker run --rm busybox /bin/sh -c "< /dev/urandom tr -cd '[:alnum:]' | head -c32")

# Create credentials secret
kubectl get secret kibana-encryption-key --namespace ${namespace} ||
    kubectl create secret generic kibana-encryption-key \
        --from-literal=encryptionkey=${encryptionKey} \
        --namespace ${namespace}
