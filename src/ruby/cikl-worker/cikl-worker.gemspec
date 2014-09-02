# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cikl/worker/version'

Gem::Specification.new do |s|
  s.name = "cikl-worker"
  s.version = Cikl::Worker::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Ryan"]
  s.description = "Workers/Post-processors for Cikl"
  s.email = "falter@gmail.com"
  s.executables = ["dns_worker.rb"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".rspec",
    "cikl-worker.gemspec",
    "Gemfile", 
    "LICENSE.txt", 
    "README.md", 
    "Rakefile", 
    "bin/dns_worker.rb",
    "config/named.root", 
    "config/unbound.conf",
    "config/config-cikl-worker-dns.yaml",
    "config/environment.rb"
  ] + 
    Dir[File.join('lib', '**', '*.rb')] +
    Dir[File.join('spec', '**', '*.rb')] +
    Dir[File.join('spec', 'dns', 'conf', '*.conf')]
  
  s.test_files    = s.files.grep(%r{^spec/})
  s.homepage = "http://github.com/cikl/cikl"
  s.licenses      = ["MIT"]
  s.require_paths = ["lib"]

  s.summary = "Workers/Post-processors for Cikl"

  s.add_runtime_dependency('bunny', "~> 1.2.0")
  s.add_runtime_dependency('unbound', "~> 2.0.0")
  s.add_runtime_dependency('configliere', "~> 0.4.0")
  s.add_runtime_dependency('multi_json', "~> 1.10.0")
  if defined?(JRUBY_VERSION)
    s.add_runtime_dependency('jrjackson', ">= 0") 
  else
    s.add_runtime_dependency('oj', "~> 2.9.0") 
  end

  s.add_development_dependency('rspec', "< 2.99.0")
  s.add_development_dependency('simplecov', "~> 0.8.0")
  s.add_development_dependency('rake', ">= 10.0")
end

