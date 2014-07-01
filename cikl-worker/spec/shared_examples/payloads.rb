require 'spec_helper'

shared_examples_for "a dns payload" do
  # Expacts :payload
  let(:worker_name) { "myname" }
  let(:timestamp) { DateTime.now }
  before :each do
    payload.stamp(worker_name, timestamp)
  end
  subject { payload }
  its(:name) { should be_a(Resolv::DNS::Name) }
  its(:rr_class) { should eq(rr_class) }
  its(:rr_type) { should eq(rr_type) }

  context "#dns_answer" do
    subject {payload.dns_answer}
    its([:name]) {should == name }
    its([:rr_class]) {should == rr_class}
    its([:rr_type]) {should == rr_type}
    its([:resolver]) { should eq(worker_name) }
  end

  context "#to_hash" do
    subject {payload.to_hash}
    its([:observables]) {should ==  {:dns_answer => [ payload.dns_answer ] } }
  end

  it_should_behave_like "a payload"
end

shared_examples_for "a payload" do
  # Expacts :payload
  # Expacts :payload_clone
  # Expacts :payload_diff
  # Expacts :timestamp

  describe "#==" do
    it "should == itself" do
      expect(subject).to eq(subject)
    end
    it "should == an identical object" do
      expect(subject).to eq(payload_clone)
    end
    it "should not == an different object" do
      expect(subject).not_to eq(payload_diff)
    end
  end
  context "#to_hash" do
    subject {payload.to_hash}
    its([:source]) { should == "cikl-worker" }
    its([:@timestamp]) { should == timestamp.iso8601 }
  end
end
