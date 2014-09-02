# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cikl/api/version'

Gem::Specification.new do |s|
  s.name = "cikl-api"
  s.version = Cikl::API::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Ryan"]
  s.description = "API for Cikl"
  s.summary = s.description

  s.email = "falter@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".rspec",
    "cikl-api.gemspec",
    "config.ru", 
    "CONTRIBUTING.md", 
    "Gemfile", 
    "LICENSE", 
    "Rakefile", 
    "README.md",
    "config/config.yaml",
    "config/elasticsearch_template.json"
  ] + 
    Dir[File.join('app', '**', '*.rb')] +
    Dir[File.join('config', '**', '*.rb')] +
    Dir[File.join('lib', '**', '*.rb')] +
    Dir[File.join('spec', '**', '*.rb')] +
    Dir[File.join('vendor', '**', '*')]
  
  s.test_files    = s.files.grep(%r{^spec/})
  s.homepage = "http://github.com/cikl/cikl"
  s.licenses      = ["LGPLv3"]
  s.require_paths = ["lib"]


  s.add_runtime_dependency('cikl-event', ">= 0")
  s.add_runtime_dependency('puma', ">= 2.8.2")
  s.add_runtime_dependency('elasticsearch', "~> 1.0.0")
  s.add_runtime_dependency('connection_pool', "~> 2.0.0")
  s.add_runtime_dependency('jbuilder', ">= 2.0.0")
  s.add_runtime_dependency('typhoeus', ">= 0.6.8")
  s.add_runtime_dependency('mongo', "~> 1.10.0")
  s.add_runtime_dependency('bson_ext', "~> 1.10.0")
  s.add_runtime_dependency('virtus', ">= 1.0.0")
  s.add_runtime_dependency('rack-cors', "~> 0.2.0")
  s.add_runtime_dependency('grape', "~> 0.7.0")
  s.add_runtime_dependency('grape-entity', "~> 0.4.0", ">= 0.4.3")
  s.add_runtime_dependency('grape-swagger', "~> 0.7.0")
  s.add_runtime_dependency('multi_json', "~> 1.10.0")

  if defined?(JRUBY_VERSION)
    s.add_runtime_dependency('jrjackson', ">= 0") 
  else
    s.add_runtime_dependency('oj', "~> 2.9.0") 
  end

  s.add_development_dependency('rake', ">= 10.0")

  s.add_development_dependency('rspec', ">= 3.0.0")
  s.add_development_dependency('rspec-its', ">= 1.0.0")
  s.add_development_dependency('rack-test', ">= 0.6.2")
  s.add_development_dependency('simplecov', "~> 0.8.0")
  s.add_development_dependency('elasticsearch-extensions', ">= 0.0.15")
  s.add_development_dependency('fabrication', "~> 2.11.0")
  s.add_development_dependency('timecop', "~> 0.7.0")
end

