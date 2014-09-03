# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "threatinator-output-cikl"
  s.version = File.read(File.expand_path('../VERSION', __FILE__))

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Ryan"]
  s.description = "Threatinator output for cikl"
  s.summary = s.description

  s.email = "falter@gmail.com"
  s.files = [
    "threatinator-output-cikl.gemspec",
    "CHANGELOG.md",
    "Gemfile", 
    "LICENSE", 
    "Rakefile", 
    "VERSION",
    "README.md"
  ] + 
    Dir[File.join('lib', '**', '*.rb')] +
    Dir[File.join('spec', '**', '*.rb')]
  
  s.test_files    = s.files.grep(%r{^spec/})
  s.homepage = "http://github.com/cikl/cikl"
  s.licenses      = ["LGPLv3"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency('bunny', ">= 1.2.0")
  s.add_runtime_dependency('multi_json', ">= 1.10.0")
  s.add_runtime_dependency('cikl-event', ">= 0")

  if defined?(JRUBY_VERSION)
    s.add_runtime_dependency('jrjackson', ">= 0") 
  else
    s.add_runtime_dependency('oj', ">= 2.9.0") 
  end

end

