$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'config')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'app')))

require 'boot'

Bundler.require :default, ENV['RACK_ENV']

require 'app'
