require 'virtus'
require 'yaml'
module Cikl
  class ConfigLoader
    include Virtus.model #(strict: true)

    attribute :mongo_uri, String, default: 'mongodb://localhost/cikl'
    attribute :elasticsearch_uri, String, default: 'http://localhost:9200'
    attribute :elasticsearch_index, String, default: 'cikl'

    def self.load(filename, environment)
      data = YAML.load_file(filename)
      config_data = data[environment]
      if config_data.nil?
        raise "Environment '#{environment}' not specified in '#{filename}'!"
      end
      new(config_data)
    end
  end
end
