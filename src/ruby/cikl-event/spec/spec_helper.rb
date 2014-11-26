require 'rubygems'
require 'pathname'

SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
PROJECT_ROOT = (SPEC_ROOT + '../').expand_path

require 'simplecov'

SimpleCov.start do
#  add_filter PROJECT_ROOT.join('spec').to_s
#  add_filter PROJECT_ROOT.join('.gem').to_s
#  add_group 'lib', PROJECT_ROOT.join('lib').to_s
end 

Dir["#{SPEC_ROOT.to_s}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # Use new syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

