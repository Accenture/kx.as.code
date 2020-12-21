require 'spec_helper'

describe file('/home/ai.hero/Desktop/README.desktop') do
  it { should exist }
end

describe file('/home/ai.hero/Desktop/CONTRIBUTE.desktop') do
  it { should exist }
end

describe file('/home/ai.hero/Desktop/kx.as.code') do
  it { should be_symlink }
end

describe file('/home/ai.hero/Desktop/test_automation') do
  it { should be_symlink }
end
