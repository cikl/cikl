require 'rubygems'

require 'pathname'
SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
PROJECT_ROOT =  SPEC_ROOT.join('../').expand_path
SUPPORT_ROOT = SPEC_ROOT.join('support')
FIXTURES_ROOT =  SPEC_ROOT.join('fixtures')

require 'simplecov'

if ENV['COVERAGE_DIR']
  SimpleCov.coverage_dir(ENV['COVERAGE_DIR'])
  SimpleCov.at_exit {
    SimpleCov.result
  }
end
SimpleCov.command_name 'threatinator-output-cikl'
SimpleCov.start do
  project_root = RSpec::Core::RubyProject.root
  add_filter PROJECT_ROOT.join('spec').to_s
  add_filter PROJECT_ROOT.join('.gem').to_s
  add_filter PROJECT_ROOT.join('.git').to_s
end 

require 'factory_girl'
Dir.glob(SUPPORT_ROOT.join('**','*.rb')).sort.each { |f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

