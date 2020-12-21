require 'spec_helper'

describe x509_certificate('/home/ai.hero/Kubernetes/z2h-certs/tls.crt') do
  it { should be_certificate }
end

describe x509_certificate('/home/ai.hero/Kubernetes/z2h-certs/tls.crt') do
   it { should be_valid }
end
