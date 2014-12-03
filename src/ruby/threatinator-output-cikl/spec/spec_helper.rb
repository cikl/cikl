require 'rubygems'

require 'pathname'
SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
PROJECT_ROOT =  SPEC_ROOT.join('../').expand_path
SUPPORT_ROOT = SPEC_ROOT.join('support')
FIXTURES_ROOT =  SPEC_ROOT.join('fixtures')

require 'simplecov'

SimpleCov.start do
  if ENV['COVERAGE_DIR']
    coverage_dir(ENV['COVERAGE_DIR'])
  end
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

