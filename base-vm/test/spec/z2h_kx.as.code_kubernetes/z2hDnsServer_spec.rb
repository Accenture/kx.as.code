require 'spec_helper'

describe host('k8s-dashboard.z2h-kx-as-code.local') do
  it { should be_resolvable.by('dns') }
end

describe port(53) do
  it { should be_listening.with('udp') }
end

describe service('dnsmasq') do
  it { should be_enabled }
  it { should be_running }
end
