#!/bin/bash
set -euox pipefail

echo '''
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: influxdata:cluster:viewer
  labels:
    rbac.authorization.k8s.io/aggregate-view-telegraf: "true"
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes", "nodes"]
    verbs: ["get", "list"]

---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: influxdata:telegraf
aggregationRule:
  clusterRoleSelectors:
    - matchLabels:
        rbac.authorization.k8s.io/aggregate-view-telegraf: "true"
    - matchLabels:
        rbac.authorization.k8s.io/aggregate-to-view: "true"
rules: []

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: influxdata:telegraf:viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: influxdata:telegraf
subjects:
  - kind: ServiceAccount
    name: telegraf
    namespace: default
''' | kubectl apply -f -

