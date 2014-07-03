require 'models/event'
require 'models/observable/dns_answer'
require 'models/observable/fqdn'
require 'models/observable/ipv4'

module Cikl
  module API
    module Helpers
      module Elasticsearch
        def search_events(opts = {})
          opts[:index] = Cikl::Config.elasticsearch_index
          opts[:type] = 'event'
          Cikl::ESClient.search(opts)
        end
      end
    end
  end
end


