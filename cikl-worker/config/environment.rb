require 'rubygems'
require 'bundler'
Bundler.setup :default
require 'pathname'

module WorkerEnvironment
  APP_ROOT = Pathname.new(__FILE__).dirname.join('../').expand_path
  BIN_PATH = APP_ROOT.join('bin')
  LIB_PATH = APP_ROOT.join('lib')

  $:.unshift LIB_PATH.to_s
end

