require 'configliere'
require 'socket'
module Cikl
  module Worker
    module Base
      module Config
        def self.create_config(app_root)
          config = Configliere::Param.new

          config.define :results_routing_key,
                        :description => "The routing key where we will deliver job results",
                        :required => true

          config.define :jobs_routing_key,
                        :description => "The name of the queue to subscribe to for jobs",
                        :required => true

          config.define :job_timeout,
                        :type => Float,
                        :description => "Timeout (in seconds) for a job to run",
                        :default => 10.0,
                        :required => true

          config.define :job_channel_prefetch,
                        :type => Integer,
                        :description => "The number of jobs that will be processed at a given time",
                        :default => 128,
                        :required => true

          config.define :worker_name,
                        :description => "The name of the worker",
                        :default => ENV['HOSTNAME'] || Socket.gethostname || 'unknown'


          config.define "amqp.url",
                        :description => "URI for AMQP server",
                        :default => ENV['CIKL_RABBITMQ_URL'] || "amqp://guest:guest@localhost/%2Fcikl"
          config.define "amqp.recover_from_connection_close",
                        :description => "Retry closed connections",
                        :type => :boolean,
                        :default => true

          config.define "amqp.network_recovery_interval",
                        :description => "Retry interval",
                        :type => Float,
                        :default => 3.0

          config.define "amqp.max_recovery_attempts",
                        :description => "Maximum number of times to re-attempt connectivity. If nil, go on forever",
                        :type => Integer,
                        :default => nil

          config
        end
      end
    end
  end
end

