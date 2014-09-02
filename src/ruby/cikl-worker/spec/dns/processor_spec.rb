require 'spec_helper'
require 'cikl/worker/dns/processor'
require 'cikl/worker/dns/config'
require 'cikl/worker/dns/job'
require 'shared_examples/processor'


describe Cikl::Worker::DNS::Processor do
  include WorkerHelper
  let(:resolver) { 
    ret = double("resolver") 
    ret.stub(:start)
    ret.stub(:cancel_query)
    ret.stub(:stop)
    ret.stub(:send_query)
    ret
  }
  let(:job_result_handler) { 
    ret = double("job_result_handler") 
    ret.stub(:handle_job_result)
    ret
  }
  let(:job) {
    Cikl::Worker::DNS::Job.new('fakedomain.local.')
  }
  let(:config) {
    ret = Cikl::Worker::DNS::Config.create_config(WorkerHelper::PROJECT_ROOT)
    ret[:job_timeout] = 0.1
    ret[:dns][:unbound_config_file] = unbound_config_file("local_zone.conf")
    ret
  }

  context "when initialized" do
    it "should start the resolver" do
      expect(resolver).to receive(:start)
      begin
        processor = described_class.new(resolver, job_result_handler, config)
      ensure
        processor.stop
      end
    end
  end

  context "when stopped" do
    it "should stop the resolver" do
      processor = described_class.new(resolver, job_result_handler, config)
      expect(resolver).to receive(:stop)
      processor.stop
    end
  end

  describe "#process_job" do
    before :each do
      @processor = described_class.new(resolver, job_result_handler, config)
    end
    after :each do
      @processor.stop
    end
    it "should call send_query four times" do
      processor = described_class.new(resolver, job_result_handler, config)
      queries = job.each_remaining_query.to_a
      expect(queries.count).to be(4)
      expect(resolver).to receive(:send_query).once.with(queries[0])
      expect(resolver).to receive(:send_query).once.with(queries[1])
      expect(resolver).to receive(:send_query).once.with(queries[2])
      expect(resolver).to receive(:send_query).once.with(queries[3])
      processor.process_job(job)
    end
  end

  context "if the timeout expires" do
    it "should cancel each remaining query in the job" do
      processor = described_class.new(resolver, job_result_handler, config)
      queries = job.each_remaining_query.to_a
      expect(queries.count).to be(4)
      expect(resolver).to receive(:cancel_query).once.with(queries[0])
      expect(resolver).to receive(:cancel_query).once.with(queries[1])
      expect(resolver).to receive(:cancel_query).once.with(queries[2])
      expect(resolver).to receive(:cancel_query).once.with(queries[3])
      processor.process_job(job)
      sleep (config[:job_timeout] + 1)
    end
  end

  it_should_behave_like "a job processor" do
    let(:processor) {
        described_class.new(resolver, job_result_handler, config)
    }
    let(:job) {
      Cikl::Worker::DNS::Job.new('fakedomain.local.')
    }
    let(:job2) {
      Cikl::Worker::DNS::Job.new('www.fakedomain.local.')
    }
  end
  
end
