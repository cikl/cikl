require 'cikl/event'

module Cikl
  module API
    module Helpers
      module Elasticsearch
        def search_events(opts = {})
          opts[:index] = Cikl::Config.elasticsearch_index_pattern
          opts[:type] = 'event'
          Cikl::ESClient.search(opts)
        end
      end
    end
  end
end


