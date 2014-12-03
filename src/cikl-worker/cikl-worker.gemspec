version = File.read(File.expand_path('../../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'cikl-worker'
  s.version     = version
  s.summary     = 'Cikl Worker'

  s.license = 'LGPLv3'

  s.author   = 'Michael Ryan'
  s.email    = 'falter@gmail.com'
  s.homepage = 'http://github.com/cikl'
  s.bindir   = 'bin'

  s.files = Dir[
    'LICENSE.txt',
    'Rakefile',
    'README.md',
    'CONTRIBUTING.md',
    'bin/**/*',
    'config/**/*',
    'lib/**/*'
  ]

  s.add_dependency 'cikl-event',                version
  s.add_dependency 'bunny',                     '>= 1.2.0'
  s.add_dependency 'unbound',                   '~> 2.0.0'
  s.add_dependency 'configliere',               '~> 0.4.0'
  s.add_dependency 'multi_json',                '>= 1.10.0'
  if defined?(JRUBY_VERSION)
    s.add_runtime_dependency('jrjackson', ">= 0")
  else
    s.add_runtime_dependency('oj', ">= 2.9.0")
  end
end

