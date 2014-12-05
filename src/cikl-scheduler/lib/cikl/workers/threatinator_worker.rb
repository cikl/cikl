require 'sidekiq'

module Cikl
  module Workers
    class ThreatinatorWorker
      include Sidekiq::Worker

      def perform(provider, name)
        cmd = "bundle exec threatinator run --run.output.cikl.url=#{ENV['CIKL_RABBITMQ_URL']} --run.output.format=cikl #{provider} #{name}"
        unless system(cmd) == true
          raise "Failed to process #{provider} #{name}"
        end
      end
    end
  end
end

