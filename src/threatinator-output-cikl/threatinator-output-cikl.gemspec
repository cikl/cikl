version = File.read(File.expand_path('../../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'threatinator-output-cikl'
  s.version     = version
  s.summary     = 'threatinator-output-cikl'

  s.license = 'LGPLv3'

  s.author   = 'Michael Ryan'
  s.email    = 'falter@gmail.com'
  s.homepage = 'http://github.com/cikl'
  s.bindir   = 'bin'

  s.files = Dir[
    'LICENSE',
    'Rakefile',
    'README.md',
    'lib/**/*'
  ]

  s.add_dependency 'cikl-event',                version
  s.add_dependency 'bunny',                     '>= 1.2.0'
  s.add_dependency 'multi_json',                '>= 1.10.0'
  if defined?(JRUBY_VERSION)
    s.add_runtime_dependency('jrjackson', ">= 0")
  else
    s.add_runtime_dependency('oj', ">= 2.9.0")
  end

  s.add_development_dependency 'rspec',         '>= 3.0.0'
  s.add_development_dependency 'simplecov',     '~> 0.8.0'
  s.add_development_dependency 'threatinator',  '= 0.1.6'
  s.add_development_dependency 'factory_girl',  '~> 4.0'
  s.add_development_dependency 'rake',          '>= 10.0'
end


