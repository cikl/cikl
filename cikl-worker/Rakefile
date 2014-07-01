require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
rescue LoadError
else 
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = "cikl-worker"
    gem.homepage = "http://github.com/justfalter/cikl-worker"
    gem.license = "MIT"
    gem.summary = %Q{Workers/Post-processors for Cikl}
    gem.description = %Q{Workers/Post-processors for Cikl}
    gem.email = "falter@gmail.com"
    gem.authors = ["Mike Ryan"]
    gem.bindir = 'bin'
    gem.executables << 'dns_worker.rb'
    gem.files  = Dir.glob("lib/**/*.rb") + 
      Dir.glob("bin/{*.rb}") + 
      Dir.glob("config/*") + 
      Dir.glob("spec/{*.rb}") + 
      %w(LICENSE.txt Gemfile README.md Rakefile VERSION)

  end
  Jeweler::RubygemsDotOrgTasks.new
end

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue LoadError
else
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end
end
