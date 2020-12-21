require 'spec_helper'

describe bridge('docker0') do
  it { should exist }
end

