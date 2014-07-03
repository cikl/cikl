$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'config')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'app')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'boot'
Bundler.require :default, ENV['RACK_ENV']
require 'cikl/config_loader'
module Cikl
  Config = Cikl::ConfigLoader.load(File.expand_path('../config.yaml', __FILE__), ENV['RACK_ENV'])
end

require 'initializers/mongo'
require 'initializers/elasticsearch'
require 'initializers/typhoeus'

require 'app'
