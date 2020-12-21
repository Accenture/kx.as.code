require 'spec_helper'

describe file('/etc/cron.hourly/changeBackground') do
  it { should exist }
  it { should be_mode 755 }
  it { should be_executable }
end
