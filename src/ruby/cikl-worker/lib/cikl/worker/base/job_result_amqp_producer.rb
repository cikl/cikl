require 'cikl/worker/base/job_result_handler'
require 'multi_json'
require 'date'

module Cikl
  module Worker
    module Base
      # Simple handler for AMQP publishing
      class JobResultAMQPProducer
        include JobResultHandler

        # @param [AMQP::Exchange] exchange The exchange through which results
        #   will be published
        # @param [String] routing_key The routing key for where results will
        #   be destined
        def initialize(exchange, routing_key, worker_name)
          @exchange = exchange
          @routing_key = routing_key
          @worker_name = worker_name
        end

        # Process a job result, publishing its payloads to an exchange
        # @param [Cikl::Worker::Base::JobResult] job_result
        def handle_job_result(job_result)
          now = DateTime.now
          job_result.payloads.each do |payload|
            payload.stamp(@worker_name, now)
            @exchange.publish(MultiJson.dump(payload.to_hash), :routing_key => @routing_key)
          end
        end
      end
    end
  end
end

