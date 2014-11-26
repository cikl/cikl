require 'threatinator/output'
require 'bunny'
require 'cikl/event'
require 'multi_json'

module Threatinator
  module Plugins
    module Output
      module CiklHelpers
        # converts a Threatinator event to a cikl event
        # @param [Threatinator::Event] event
        # @return [Cikl::Event] a Cikl event object
        def ti2cikl(event)
          ret = ::Cikl::Event.new(
            import_time: Time.now,
            feed_provider: event.feed_provider,
            feed_name: event.feed_name,
            source: 'threatinator'
          )
          if event.type
            ret.tags << event.type.to_s
          end

          event.ipv4s.each do |ipv4|
            ret.observables.ipv4 << ::Cikl::Observable::Ipv4.new(ipv4: ipv4)
          end

          event.fqdns.each do |fqdn|
            ret.observables.fqdn << ::Cikl::Observable::Fqdn.new(fqdn: fqdn)
          end

          ret
        end
        module_function :ti2cikl
      end

      class Cikl < Threatinator::Output
        include CiklHelpers
        require 'threatinator/plugins/output/cikl/config'

        def initialize(config)
          bunny_config = {
            host: config.host,
            port: config.port,
            username: config.username,
            password: config.password,
            vhost: config.vhost,
            ssl: config.use_ssl,
            recover_from_connection_close: true,
            network_recovery_interval: 5.0
          }

          @bunny = Bunny.new(bunny_config)
          @bunny.start
          @exchange = @bunny.create_channel.default_exchange
          @routing_key = config.routing_key
        end

        def handle_event(event)
          # Convert event to Cikl format
          cikl_event = ti2cikl(event)
          @exchange.publish(MultiJson.dump(cikl_event.to_serializable_hash), 
                            routing_key: @routing_key)
        end

        def finish
          @exchange = nil
          @bunny.close
        end

      end
    end
  end
end
