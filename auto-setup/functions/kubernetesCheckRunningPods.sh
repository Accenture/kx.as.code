checkRunningKubernetesPods() {

  for i in {1..60}; do
    # Added workaround for Gitlab-Runner, which is not expected to work until later
    # This is because at this stage the docker registry is not yet up to push the custom image
    totalPods=$(kubectl get pods --namespace ${namespace} | grep -v "STATUS" | grep -v "gitlab-runner" | wc -l || true)
    runningPods=$(kubectl get pods --namespace ${namespace} | grep -v "STATUS" | grep -v "gitlab-runner" | grep -i -E 'Running|Completed' | wc -l || true)
    log_info "Waiting for all pods in ${namespace} namespace to have Running status - CHECK: ${i}, TOTAl: ${totalPods}, RUNNING:  ${runningPods}"
    if [[ ${totalPods} -eq ${runningPods} ]]; then
      log_info "The number of running pods (${runningPods}) running in namespace ${namespace}, equals the number of total pods (${totalPods}) after ${i} checks, continuing..."
      break
    fi
    sleep 15
  done

  if [[ $totalPods -ne $runningPods ]]; then
    log_warn "After 60 checks, the number of total pods (${totalPods}) in the ${namespace} namespace still does not equal the number of running pods (${runningPods})"
    rc=1
    return ${rc}
  fi
}
