version = File.read(File.expand_path('../../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'cikl-event'
  s.version     = version
  s.summary     = 'cikl-event'

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

  s.add_dependency 'virtus',                    '>= 1.0.0'
  s.add_dependency 'equalizer',                 '>= 0.0.0'

  s.add_development_dependency 'rake',          '>= 10.0'
  s.add_development_dependency 'rspec',         '>= 3.0.0'
  s.add_development_dependency 'simplecov',     '~> 0.8.0'
end



