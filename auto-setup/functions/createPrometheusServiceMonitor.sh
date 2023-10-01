createPrometheusServiceMonitor() {

componentMonitorName=${1:-"${componentName}"}
componentMonitorNamespace=${2:-"${namespace}"}

if checkApplicationInstalled "prometheus-stack" "core"; then

echo """
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${componentMonitorName}-metrics-servicemonitor
  namespace: monitoring
  labels:
    app: ${componentMonitorName}-metrics
    app.kubernetes.io/name: ${componentMonitorName}-metrics
    release: prometheus-stack
spec:
  selector:
    matchLabels:
      app: ${componentMonitorName}-metrics
  namespaceSelector:
    matchNames:
    - ${componentMonitorNamespace}
  endpoints:
  - port: metrics
    interval: 15s
""" | /usr/bin/sudo tee "${installationWorkspace}/${componentMonitorName}-PrometheusServiceMonitor.yaml"
kubernetesApplyYamlFile "${installationWorkspace}/${componentMonitorName}-PrometheusServiceMonitor.yaml" "${componentMonitorNamespace}"

fi

}
