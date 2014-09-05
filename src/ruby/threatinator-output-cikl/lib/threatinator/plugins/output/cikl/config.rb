require 'threatinator/output'

module Threatinator
  module Plugins
    module Output
      require 'threatinator/plugins/output/cikl'
      class Cikl
        class Config < Threatinator::Output::Config
          attribute :host, String, default: lambda { |c,a| "localhost" }, 
            description: "The hostname/ip of the RabbitMQ server"
          attribute :port, Integer, default: 5672, 
            description: "The port number that the RabbitMQ server is listening on"
          attribute :username, String, default: lambda { |c,a| "guest" },
            description: "Username for the cikl account on the RabbitMQ server"
          attribute :password, String, default: lambda { |c,a| "guest" },
            description: "Password for the cikl account on the RabbitMQ server"
          attribute :vhost, String, default: lambda { |c,a| '/' },
            description: "RabbitMQ vhost"
          attribute :use_ssl, Boolean, default: false, 
            description: "Enable SSL"

          attribute :routing_key, String, default: lambda { |c,a| 'cikl.event' },
            description: "Routing key for Cikl events"

        end
      end
    end
  end
end
