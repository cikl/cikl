require 'sidekiq'
require 'multi_json'
require 'cikl/workers/threatinator_worker'

module Cikl
  module Workers
    class ThreatinatorRunAllWorker
      include Sidekiq::Worker

      def perform()
        output = `bundle exec threatinator list --list.format=json`
        unless $?.success?
          raise "threatinator list returned non-zero exit code: #{$?.exitstatus}"
        end

        feeds = MultiJson.load(output)
        feeds.each do |feed|
          Cikl::Workers::ThreatinatorWorker.perform_async(feed["provider"], feed["name"])
        end
      end
    end
  end
end


