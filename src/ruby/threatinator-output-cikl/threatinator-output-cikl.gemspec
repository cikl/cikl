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
end


