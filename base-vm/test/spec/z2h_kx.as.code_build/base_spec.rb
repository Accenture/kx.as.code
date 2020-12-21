require 'spec_helper'

describe process 'sshd' do
  it { should be_running }
end

describe port(22) do
  it { should be_listening.with 'tcp' }
end
