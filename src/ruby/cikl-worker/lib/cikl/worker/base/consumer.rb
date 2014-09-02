require 'cikl/worker/logging'
require 'cikl/worker/exceptions'

module Cikl
  module Worker
    module Base
      class Consumer
        include Cikl::Worker::Logging

        attr_reader :routing_key, :prefetch

        def initialize(processor, builder, config)
          @processor = processor
          @builder = builder
          @routing_key = config[:jobs_routing_key]
          @prefetch = config[:job_channel_prefetch]
        end

        def stop
          debug "-> Consumer#stop"
          debug "Processor: stopping"
          @processor.stop
          debug "Processor: stopped"
          debug "<- Consumer#stop"
        end

        def handle_payload(payload, amqp, delivery_info)
          begin
            on_finish_cb = Proc.new do |j, r|
              #info "Finished: #{payload}"
              amqp.ack(delivery_info) rescue nil
              @processor.job_finished(j, r)
            end
            job = @builder.build(payload, :on_finish => on_finish_cb)
            @processor.process_job(job)
          rescue Cikl::Worker::Exceptions::JobBuildError => e
            amqp.nack(delivery_info)
          end
        end
      end

    end
  end
end


