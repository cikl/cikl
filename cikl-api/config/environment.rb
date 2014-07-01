ENV['RACK_ENV'] ||= "test"

require 'typhoeus'
require 'typhoeus/adapters/faraday'

require File.expand_path('../application', __FILE__)

