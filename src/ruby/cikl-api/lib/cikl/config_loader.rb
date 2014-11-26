require 'virtus'
require 'yaml'
module Cikl
  class ConfigLoader
    include Virtus.model #(strict: true)

    attribute :mongo_uri, String, 
      default: ENV['CIKL_MONGO_URI'] || 'mongodb://localhost/cikl'
    attribute :elasticsearch_hosts, Array[String], 
      default: [ ENV['CIKL_ELASTICSEARCH_URI'] || 'http://localhost:9200']
    attribute :elasticsearch_index, String, 
      default: ENV['CIKL_ELASTICSEARCH_INDEX'] || 'cikl'
    attribute :elasticsearch_index_pattern, String, default: lambda { |i, o|
      "#{i.elasticsearch_index}-*"
    }
    attribute :elasticsearch_template_path, String, 
      default: File.expand_path('../../../config/elasticsearch_template.json',__FILE__)
  end
end
