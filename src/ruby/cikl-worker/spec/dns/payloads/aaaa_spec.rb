require 'spec_helper'
require 'cikl/worker/dns/payloads/aaaa'
require 'shared_examples/payloads'
require 'resolv'

describe Cikl::Worker::DNS::Payloads::AAAA do
  it_should_behave_like "a dns payload" do
    let(:name) { "google.com" }
    let(:rr_class) { :IN }
    let(:rr_type) { :AAAA }
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::IPv6.create("2607:f8b0:4009:803::1004"))
    }
    let(:payload_clone) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::IPv6.create("2607:f8b0:4009:803::1004"))
    }
    let(:payload_diff) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::IPv6.create("2607:f8b0:4009:803::1006"))
    }
  end

  context "#dns_answer" do
    let(:payload) { 
      described_class.new(Resolv::DNS::Name.create("google.com."), 1234, Resolv::IPv6.create("2607:f8b0:4009:803::1004"))
    }

    subject {payload.dns_answer}
    its([:ipv6]) {should == '2607:f8b0:4009:803::1004'}

  end
end

