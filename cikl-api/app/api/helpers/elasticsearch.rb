require 'models/event'
require 'models/observable/dns_answer'
require 'models/observable/fqdn'
require 'models/observable/ipv4'

module Cikl
  module API
    module Helpers
      module Elasticsearch
        def elasticsearch_client
          return env['elasticsearch']
        end

        def with_elasticsearch
          yield(env['elasticsearch'])
        end


      end
    end
  end
end


