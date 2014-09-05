require 'spec_helper'
require 'cikl/worker/dns/payloads/a'
require 'shared_examples/payloads'
require 'resolv'

describe Cikl::Worker::DNS::Payloads::A do
  it_should_behave_like "a dns payload" do
    let(:name) { "google.com" }
    let(:rr_class) { :IN }
    let(:rr_type) { :A }
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::IPv4.create("1.2.3.4"))
    }
    let(:payload_clone) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::IPv4.create("1.2.3.4"))
    }
    let(:payload_diff) { 
      described_class.new(Resolv::DNS::Name.create("googles.com."), 1234, Resolv::IPv4.create("1.2.3.4"))
    }
  end

  context "#dns_answer" do
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::IPv4.create("1.2.3.4"))
    }

    subject {payload.dns_answer}
    its([:ipv4]) {should == '1.2.3.4'}

  end
end
