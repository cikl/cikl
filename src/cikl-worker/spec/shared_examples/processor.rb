require 'spec_helper'

shared_examples_for "a job processor" do
  before :each do
    config[:job_timeout] = 0.1
  end
  let(:job_result_handler) { double("job_result_handler") }
  let(:result) { double("result") }

  describe "processing jobs" do
    context "if the timeout expires" do
      it "should call handle_pruned_job for the job" do
        expect(processor).to receive(:handle_pruned_job).with(job)
        processor.process_job(job)
        sleep (config[:job_timeout] + 1)
      end
    end
  end

  describe "#process_job" do
    it "should raise ArgumentError if the job is already being tracked" do
      processor.process_job(job)
      expect {
        processor.process_job(job)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#num_jobs_processing" do
    it "should be zero when there aren't any jobs being processed" do
      expect(processor.num_jobs_processing).to eq(0)
    end
    it "should increment when a job is added for processing" do
      processor.process_job(job)
      expect(processor.num_jobs_processing).to eq(1)
    end
  end

  describe "#job_finished" do
    context "handling a job that is currently being processed" do
      it "should pass the result to the job_result_handler" do
        expect(job_result_handler).to receive(:handle_job_result).with(result)
        processor.process_job(job)
        processor.job_finished(job, result)
      end
      it "should decrement the number of jobs currently processing" do
        expect(job_result_handler).to receive(:handle_job_result).with(result)
        processor.process_job(job)
        expect(processor.num_jobs_processing).to eq(1)
        processor.job_finished(job, result)
        expect(processor.num_jobs_processing).to eq(0)
      end

    end
    context "handling a job that is NOT currently being processed" do
      it "should NOT pass the result to the job_result_handler" do
        expect(job_result_handler).not_to receive(:handle_job_result)
        processor.job_finished(job, result)
      end
      it "should NOT decrement the number of jobs being processed" do
        processor.process_job(job)
        expect(processor.num_jobs_processing).to eq(1)
        processor.job_finished(job2, result)
        expect(processor.num_jobs_processing).to eq(1)
      end
    end
  end
end
