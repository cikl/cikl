require 'rubygems'
require 'rspec/its'
require 'pathname'
ENV['RACK_ENV'] = 'test'

SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
PROJECT_ROOT = (SPEC_ROOT + '../').expand_path

require 'rspec/core/ruby_project'
RSpec::Core::RubyProject.add_to_load_path('config')

require 'simplecov'

SimpleCov.start do
  add_filter PROJECT_ROOT.join('spec').to_s
  add_filter PROJECT_ROOT.join('.gem').to_s
  add_group 'app', PROJECT_ROOT.join('app').to_s
  add_group 'lib', PROJECT_ROOT.join('app').to_s
end 

require 'environment'

require 'timecop'
require 'rack/test'
Dir["#{SPEC_ROOT.to_s}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # Use new syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

