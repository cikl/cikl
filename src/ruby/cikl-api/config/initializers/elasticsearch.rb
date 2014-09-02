require 'elasticsearch'

module Cikl
  ESClient = ::Elasticsearch::Client.new(hosts: Cikl::Config.elasticsearch_hosts, log: false)
end
