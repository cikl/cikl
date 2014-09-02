# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "cikl-event"
  s.version = File.read(File.expand_path('../VERSION', __FILE__))

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Ryan"]
  s.description = "Event model for Cikl"
  s.summary = s.description

  s.email = "falter@gmail.com"
  s.files = [
    "cikl-event.gemspec",
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


  s.add_runtime_dependency('virtus', ">= 1.0.0")

  s.add_development_dependency('rake', ">= 10.0")
  s.add_development_dependency('rspec', ">= 3.0.0")
  s.add_development_dependency('simplecov', "~> 0.8.0")
end

