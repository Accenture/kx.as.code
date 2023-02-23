checkRunningKubernetesPods() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local i
  for i in {1..100}; do
    # Excluded evicted pods from the total, assuming that the admin has fixed any resource constraints, since evictions are usually not an issue with the solution itself
    local totalPods=$(kubectl get pods --namespace ${namespace} -o custom-columns="POD:metadata.name,STATUS:status.phase,REASON:status.reason" | grep -i -E -v 'Evicted' | grep -v "STATUS" | wc -l || true)
    local runningPods=$(kubectl get pods --namespace ${namespace} | grep -v "STATUS" | grep -i -E 'Running|Completed|Succeeded' | wc -l || true)
    log_debug "Waiting for all pods in ${namespace} namespace to have Running status - CHECK: ${i}, TOTAl: ${totalPods}, RUNNING:  ${runningPods}"
    if [[ ${totalPods} -eq ${runningPods} ]]; then
      log_info "The number of running pods (${runningPods}) running in namespace ${namespace}, equals the number of total pods (${totalPods}) after ${i} checks, continuing..."
      break
    fi
    sleep 15
  done

  if [[ $totalPods -ne $runningPods ]]; then
    log_warn "After 60 checks, the number of total pods (${totalPods}) in the ${namespace} namespace still does not equal the number of running pods (${runningPods})"
    exit 1
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
