require 'bunny'
require 'cikl/worker/exceptions'
require 'cikl/worker/logging'
require 'cikl/worker/base/job_result_amqp_producer'
require 'thread'

module Cikl
  module Worker
    class AMQP
      include Cikl::Worker::Logging
      attr_reader :failed_connection_attempts

      def initialize(config)
        @state = :init
        @recover_from_connection_close = config[:amqp][:recover_from_connection_close]
        @network_recovery_interval = config[:amqp][:network_recovery_interval]
        @max_recovery_attempts = config[:amqp][:max_recovery_attempts]
        @results_routing_key = config[:results_routing_key]
        @worker_name = config[:worker_name]

        @bunny = init_bunny(config[:amqp])
        @consumers = []
        @ack_queue = Queue.new
        @acker_thread = start_acker()
        @mutex = Mutex.new
        @failed_connection_attempts = 0
      end

      def start
        @mutex.synchronize do
          unless @state == :init
            raise Cikl::Worker::Exceptions::AMQPAlreadyStarted.new
          end
          info "Starting Cikl::Worker::AMQP"
          start_bunny()
          @state = :started
        end
      end

      def job_result_handler
        unless @state == :started
          raise Cikl::Worker::Exceptions::AMQPNotStarted.new
        end
        @job_result_handler ||= 
          Cikl::Worker::Base::JobResultAMQPProducer.new(
            @bunny.default_channel.default_exchange, 
            @results_routing_key,
            @worker_name
        )
      end

      def init_bunny(amqp_config)
        bunny_config = {
          :host => amqp_config[:host],
          :port => amqp_config[:port],
          :username => amqp_config[:username],
          :password => amqp_config[:password],
          :vhost => amqp_config[:vhost],
          :ssl => amqp_config[:ssl],
          :recover_from_connection_close => amqp_config[:recover_from_connection_close],
          :network_recovery_interval => amqp_config[:network_recovery_interval]
        }
        Bunny.new(bunny_config)
      end
      private :init_bunny

      def start_bunny()
        @failed_connection_attempts = 0
        begin
          @bunny.start
        rescue Bunny::TCPConnectionFailed => e
          error "Failed to connect to RabbitMQ service: #{e.message}"
          @failed_connection_attempts += 1

          if (@recover_from_connection_close == true) && (@max_recovery_attempts.nil? || (@failed_connection_attempts <= @max_recovery_attempts))
            info "Retrying connection in #{@network_recovery_interval} seconds"
            sleep @network_recovery_interval
            retry
          else 
            raise Cikl::Worker::Exceptions::AMQPConnectionFailed
          end
        end
        info "RabbitMQ connection established"
      end
      private :start_bunny

      def start_acker
        Thread.new do
          while msg = @ack_queue.pop
            op = msg[0]
            case op
            when :stop
              break
            when :ack
              delivery_info = msg[1]
              delivery_info.channel.ack(delivery_info.delivery_tag)
            when :nack
              delivery_info = msg[1]
              delivery_info.channel.nack(delivery_info.delivery_tag, false)
            end
          end
        end
      end
      private :start_acker

      def stop
        info "Stopping Cikl::Worker::AMQP"
        @mutex.synchronize do
          @consumers.each do |consumer, subscription|
            debug "Canceling Subscription"
            subscription.cancel
            debug "Canceled Subscription"
            debug "Terminating Consumer"
            consumer.stop
            debug "Terminated Consumer"
          end
          @consumers.clear
          @ack_queue.push([:stop])
          if @acker_thread.join(2).nil?
            # :nocov:
            @acker_thread.kill
            # :nocov:
          end

          @bunny.close
          @bunny = nil
          @state = :stopped
        end
        info "Cikl::Worker::AMQP done"
      end

      def ack(delivery_info)
        @ack_queue.push([:ack, delivery_info])
      end

      def nack(delivery_info)
        @ack_queue.push([:nack, delivery_info])
      end

      def register_consumer(consumer)
        @mutex.synchronize do
          return if @bunny.nil?
          channel = @bunny.channel
          channel.prefetch(consumer.prefetch)
          queue = channel.queue(consumer.routing_key, :auto_delete => false)

          subscription = queue.subscribe(:blocking => false, :ack => true) do |delivery_info, properties, payload|
            consumer.handle_payload(payload, self, delivery_info)
          end
          @consumers << [consumer, subscription]
          nil
        end
      end
    end

  end
end
