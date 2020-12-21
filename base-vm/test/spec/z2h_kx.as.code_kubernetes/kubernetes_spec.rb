require 'spec_helper'

describe service('kubelet') do
    it { should be_enabled.with_level(3) }
    it { should be_running }
end

describe command('curl -k -s -o /dev/null -w "%{http_code}" https://k8s-dashboard.z2h-kx-as-code.local') do
  its(:stdout) { should match(%r|200|) }
end

describe command('kubectl get pods --namespace cert-manager --field-selector!=status.phase=Running | tail -n +2 | wc -l') do
  its(:stdout) { should match(%r|0|) }
end

describe command('kubectl get pods --namespace kube-system --field-selector!=status.phase=Running | tail -n +2 | wc -l') do
  its(:stdout) { should match(%r|0|) }
end

describe command('kubectl get pods --namespace metallb-systemd --field-selector!=status.phase=Running | tail -n +2 | wc -l') do
  its(:stdout) { should match(%r|0|) }
end

describe command('kubectl get pods --namespace kubernetes-dashboard --field-selector!=status.phase=Running | tail -n +2 | wc -l') do
  its(:stdout) { should match(%r|0|) }
end
