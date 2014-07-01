require 'spec_helper'
require 'cikl/worker/base/config'
require 'cikl/worker/base/consumer'
require 'cikl/worker/base/job'
require 'cikl/worker/base/job_builder'
require 'cikl/worker/base/job_result'
require 'cikl/worker/base/job_result_handler'
require 'cikl/worker/base/processor'
require 'cikl/worker/base/job_result_payload'
require 'cikl/worker/amqp'
require 'cikl/worker/exceptions'
require 'bunny'

module AMQPSpec
  class Payload < Cikl::Worker::Base::JobResultPayload
    attr_reader :value
    def initialize(value)
      super()
      @value = value
    end

    def ==(other)
      @value == other.value
    end

    def to_hash
      super().merge({:value => @value})
    end
  end
  class Result 
    include Cikl::Worker::Base::JobResult
    def initialize(job)
      @value = job.value
    end

    def payloads
      [Payload.new("processed: " + @value.to_s)]
    end
  end

  # Instantly processes jobs
  class Processor < Cikl::Worker::Base::Processor
    def process_job(job)
      super(job)
      result = Result.new(job)
      job.finish!(result)
    end
  end

  class Job < Cikl::Worker::Base::Job
    attr_reader :value
    def initialize(payload, opts)
      super(opts)
      @value = payload
    end
  end

  class Builder < Cikl::Worker::Base::JobBuilder
    def build(payload, opts = {})
      if payload == "RAISE_ERROR" 
        raise Cikl::Worker::Exceptions::JobBuildError.new("raising an error")
      end
      Job.new(payload, opts)
    end
  end
end

describe Cikl::Worker::AMQP do
  include WorkerHelper

  let(:config) {
    Cikl::Worker::Base::Config.create_config(WorkerHelper::PROJECT_ROOT)
  }

  let(:amqp) { 
    described_class.new(config) 
  }

  let(:worker_name) { "my_worker_name" }

  before :each do
    @worker_name = "my_worker_name"
    config.worker_name = worker_name
    now = Time.now.to_f
    config[:jobs_routing_key] = "cikl.testing.#{now.to_s}.jobs"
    config[:results_routing_key] = "cikl.testing.#{now.to_s}.results"

    @old_logger = Cikl::Worker.logger
    Cikl::Worker.logger = nil
  end

  after :each do
    Cikl::Worker.logger = @old_logger
  end

  context "when failing to connect" do
    before :each do
      config[:amqp][:port] = config[:amqp][:port] + 1
    end

    context "with recover_from_connection_close set to false" do
      before :each do
        config[:amqp][:recover_from_connection_close] = false
      end

      it "should raise AMQPConnectionFailed if it cannot connect to the server" do
        expect do
          amqp.start
        end.to raise_error(Cikl::Worker::Exceptions::AMQPConnectionFailed)
        expect(amqp.failed_connection_attempts).to eq(1)
      end
    end

    context "with recover_from_connection_close set to true" do
      before :each do
        config[:amqp][:recover_from_connection_close] = true
        config[:amqp][:max_recovery_attempts] = 2
        config[:amqp][:network_recovery_interval] = 1.0
      end

      it "should raise AMQPConnectionFailed if it cannot connect to the server" do
        expect do
          amqp.start
        end.to raise_error(Cikl::Worker::Exceptions::AMQPConnectionFailed)
        expect(amqp.failed_connection_attempts).to eq(3)
      end
    end
  end

  describe "#job_result_handler" do
    it "should raise a AMQPNotStarted exception if it hasn't been started" do
      expect {
        amqp.job_result_handler
      }.to raise_error(Cikl::Worker::Exceptions::AMQPNotStarted)
    end
  end

  describe "when started" do
    before :each do
      @bunny = Bunny.new(config[:amqp])
      @bunny.start
      @channel = @bunny.create_channel
      @results_queue = @channel.queue(config[:results_routing_key], :auto_delete => true)
      amqp.start
    end

    after :each do
      @channel.queue_delete(config[:jobs_routing_key])
      @results_queue.delete()
      @bunny.close
    end

    after :each do
      amqp.stop
    end

    let(:builder) { AMQPSpec::Builder.new }
    let(:processor) { AMQPSpec::Processor.new(amqp.job_result_handler, config)}
    let(:consumer) { Cikl::Worker::Base::Consumer.new(processor, builder, config) }

    
    describe "#start" do
      it "should raise an AMQPAlreadyStarted exception" do
        expect {
          amqp.start
        }.to raise_error(Cikl::Worker::Exceptions::AMQPAlreadyStarted)
      end
    end
    describe "#job_result_handler" do
      it "should not raise an exception" do
        expect {
          amqp.job_result_handler
        }.not_to raise_error
      end
    end
    describe "#register_consumer" do
      it "should create a queue named for :jobs_routing_key and subscribe to it" do
        expect(@bunny.queue_exists?(config[:jobs_routing_key])).to be_false
        amqp.register_consumer(consumer)
        expect(@bunny.queue_exists?(config[:jobs_routing_key])).to be_true
        queue = @channel.queue(config[:jobs_routing_key], :passive => true)
        expect(queue.status[:consumer_count]).to eq(1)
      end
    end

    describe "consuming data" do
      before :each do
        amqp.register_consumer(consumer)
      end

      it "should consume data, process it, and put results in the results queue" do
        expect(@results_queue.message_count).to eq(0)
        routing_key = config[:jobs_routing_key]
        expected_payloads = []
        actual_payloads = []
        expect(amqp).to receive(:ack).exactly(100).times.and_call_original
        100.times do
          payload = "Secret message: #{Random.rand(1_000_000)} #{Random.rand(1_000_000)}"
          @channel.default_exchange.publish(payload, :routing_key => routing_key)
          expected_payload = {
            "source" => "cikl-worker",
            "value" => "processed: " + payload,
            "@timestamp" => kind_of(String)

          }
          expected_payloads << expected_payload
        end
        sleep 1
        expect(@results_queue.message_count).to eq(100)
        100.times do
          delivery_info, properties, payload = @results_queue.pop
          actual_payloads << MultiJson.decode(payload)
        end
        expect(expected_payloads).to eq(actual_payloads)
      end

      it "should nack payloads when an error occurs while building a job" do
        expect(@results_queue.message_count).to eq(0)
        routing_key = config[:jobs_routing_key]
        expected_payloads = []
        actual_payloads = []
        expect(amqp).to receive(:ack).exactly(1).times.and_call_original
        expect(amqp).to receive(:nack).exactly(1).times.and_call_original
        1.times do
          payload = "Secret message: #{Random.rand(1_000_000)} #{Random.rand(1_000_000)}"
          @channel.default_exchange.publish(payload, :routing_key => routing_key)
          expected_payload = {
            "source" => "cikl-worker",
            "value" => "processed: " + payload,
            "@timestamp" => kind_of(String)
          }
          expected_payloads << expected_payload
        end
        1.times do
          payload = "RAISE_ERROR"
          @channel.default_exchange.publish(payload, :routing_key => routing_key)
        end
        sleep 1
        expect(@results_queue.message_count).to eq(1)
        1.times do
          delivery_info, properties, payload = @results_queue.pop
          actual_payloads << MultiJson.decode(payload)
        end
        expect(expected_payloads).to eq(actual_payloads)
      end

    end
  end
end
