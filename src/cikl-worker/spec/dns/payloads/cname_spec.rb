require 'spec_helper'
require 'cikl/worker/dns/payloads/cname'
require 'shared_examples/payloads'
require 'resolv'

describe Cikl::Worker::DNS::Payloads::CNAME do
  it_should_behave_like "a dns payload" do
    let(:name) { "google.com" }
    let(:rr_class) { :IN }
    let(:rr_type) { :CNAME }
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("www.l.google.com."))
    }
    let(:payload_clone) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("www.l.google.com."))
    }
    let(:payload_diff) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("foobar.google.com."))
    }
  end

  context "#dns_answer" do
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::DNS::Name.create("www.l.google.com."))
    }

    subject {payload.dns_answer}
    its([:fqdn]) {should == 'www.l.google.com'}

  end
end




