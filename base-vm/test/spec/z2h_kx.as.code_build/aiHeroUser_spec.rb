require 'spec_helper'

describe user('ai.hero') do
  it { should exist }
  it { should belong_to_primary_group 'ai.hero' }
  it { should belong_to_group 'docker' }
  it { should have_uid 1000 }
  it { should have_home_directory '/home/ai.hero' }
  it { should have_login_shell '/bin/zsh' }
end

describe file('/home/ai.hero/Z2H_Data') do
  it { should be_directory }
  it { should be_owned_by 'ai.hero' }
  it { should be_grouped_into 'ai.hero' }
end
