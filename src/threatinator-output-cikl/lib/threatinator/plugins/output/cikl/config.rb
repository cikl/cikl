require 'threatinator/output'

module Threatinator
  module Plugins
    module Output
      require 'threatinator/plugins/output/cikl'
      class Cikl
        class Config < Threatinator::Output::Config
          attribute :url, String, description: "The hostname/ip of the RabbitMQ server"

          attribute :routing_key, String, default: lambda { |c,a| 'cikl.event' },
            description: "Routing key for Cikl events"

        end
      end
    end
  end
end
