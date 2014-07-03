require 'rubygems'
require 'bundler'
Bundler.setup :default, :test
ENV['RACK_ENV'] = 'test'

require 'rspec/core/ruby_project'
RSpec::Core::RubyProject.add_to_load_path('config')

require 'simplecov'

SimpleCov.start do
  project_root = RSpec::Core::RubyProject.root
  add_filter project_root.join('spec').to_s
  add_filter project_root.join('.gem').to_s
  add_group 'app', project_root.join('app').to_s
  add_group 'lib', project_root.join('app').to_s
end 
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # Use new syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'environment'
