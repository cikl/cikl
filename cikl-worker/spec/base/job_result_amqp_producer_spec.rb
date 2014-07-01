require 'spec_helper'
require 'cikl/worker/base/job_result_amqp_producer'
require 'cikl/worker/base/job_result_payload'
require 'multi_json'

describe Cikl::Worker::Base::JobResultAMQPProducer do
  describe "#handle_job_result" do
    class FakeJobResultPayload < Cikl::Worker::Base::JobResultPayload
      def initialize(value)
        @value = value
      end

      def ==(other)
        @value == other.value 
      end

      def to_hash
        {:value => @value}
      end
    end
    let(:job_result) { 
      double("job_result") 
    }
    let(:exchange) { double("exchange") }
    let(:routing_key) { double("some.routing.key") }
    let(:worker_name) { "my_worker_name" }
    let(:job_result_producer) { 
      Cikl::Worker::Base::JobResultAMQPProducer.new(exchange, routing_key, worker_name)
    } 

    it "should publish the result payload to the exchange" do
      payload1 = FakeJobResultPayload.new("some payload1")
      payload2 = FakeJobResultPayload.new("some payload2")
      encoded1 = MultiJson.dump(payload1.to_hash)
      encoded2 = MultiJson.dump(payload2.to_hash)
      expect(job_result).to receive(:payloads).and_return([payload1, payload2])
      expect(payload1).to receive(:stamp).with(worker_name, kind_of(DateTime)).and_call_original
      expect(payload2).to receive(:stamp).with(worker_name, kind_of(DateTime)).and_call_original
      expect(exchange).to receive(:publish).with(encoded1, :routing_key => routing_key)
      expect(exchange).to receive(:publish).with(encoded2, :routing_key => routing_key)
      job_result_producer.handle_job_result(job_result)
    end
  end
end
