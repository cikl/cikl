require 'spec_helper'
require 'cikl/worker/dns/payloads/mx'
require 'shared_examples/payloads'
require 'resolv'

describe Cikl::Worker::DNS::Payloads::MX do
  it_should_behave_like "a dns payload" do
    let(:name) { "google.com" }
    let(:rr_class) { :IN }
    let(:rr_type) { :MX }
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("mail.google.com."))
    }
    let(:payload_clone) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("mail.google.com."))
    }
    let(:payload_diff) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("mail2.google.com."))
    }
  end

  context "#dns_answer" do
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("mail.google.com."))
    }

    subject {payload.dns_answer}
    its([:fqdn]) {should == 'mail.google.com'}

  end
end



