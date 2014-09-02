require 'spec_helper'

shared_examples_for "a job builder" do
  describe "#build" do
    let(:metadata) { double('metadata') }
    it "should be build using a payload object" do
      expect{ described_class.new.build(payload) }.not_to raise_error
    end
    it "should return an object based on Cikl::Worker::Base::Job" do
      expect(described_class.new.build(payload)).to be_a(Cikl::Worker::Base::Job)
    end
    it "should pass the :on_finish callback to the job" do
      builder = described_class.new
      result = double("result")
      cb = double("callback")
      job = builder.build(payload, :on_finish => cb)
      expect(cb).to receive(:call).with(job, result)
      job.finish!(result)
    end
  end
end

shared_examples_for "a job builder encountering a bad payload" do
  describe "#build" do
    let(:metadata) { double('metadata') }
    it "raise an exception" do
      expect{ 
        described_class.new.build(payload) 
      }.to raise_error(Cikl::Worker::Exceptions::JobBuildError)
    end
  end
end
