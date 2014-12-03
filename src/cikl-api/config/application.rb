$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'config')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'app')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'boot'
require 'cikl/config_loader'
module Cikl
  CONFIG_FILE = ENV['CIKL_API_CONFIG'] || File.expand_path('../config.yaml', __FILE__)
  Config = Cikl::ConfigLoader.new(YAML.load_file(CONFIG_FILE))
end

require 'initializers/mongo'
require 'initializers/elasticsearch'
require 'initializers/typhoeus'

require 'app'
