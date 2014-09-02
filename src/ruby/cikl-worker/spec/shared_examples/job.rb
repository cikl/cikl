require 'spec_helper'

shared_examples_for "a job" do
  let(:result) { double("result") }
  let(:on_finish_callback) { 
    ret = double("callback")
    ret.stub(:call) 
    ret
  }
  let(:job) { described_class.new(payload, :on_finish => on_finish_callback) }

  describe "#start!" do
    it "should fire a ':job_start' observation" do
      observer = double("observer")
      observer.should_receive(:update).with(:job_start, job)
      job.add_observer(observer)
      job.start!
    end
  end

  describe "#started?" do
    it "should not be started if it hasn't started" do
      expect(job.started?).to be_false
    end

    it "should be finished after finish! is called" do
      job.start!()
      expect(job.started?).to be_true
    end
  end

  describe "#finish!" do
    it "should fire a ':job_finish' observation" do
      observer = double("observer")
      observer.should_receive(:update).with(:job_finish, job, result)
      job.add_observer(observer)
      job.finish!(result)
    end

    it "should call the proc provided to :on_finish with itself and the result" do
      expect(on_finish_callback).to receive(:call).with(job, result)
      job.finish!(result)
    end

  end

  describe "#finished?" do
    it "should not be finished if it hasn't started" do
      expect(job.finished?).to be_false
    end
    it "should be finished after finish! is called" do
      job.finish!(result)
      expect(job.finished?).to be_true
    end
  end
end

