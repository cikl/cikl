require 'elasticsearch'

module Cikl
  ESClient = ::Elasticsearch::Client.new(url: Cikl::Config.elasticsearch_uri, log: false)
end
