version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'cikl'
  s.version     = version
  s.summary     = 'Cikl code-base'

  s.license = 'LGPLv3'

  s.author   = 'Michael Ryan'
  s.email    = 'falter@gmail.com'
  s.homepage = 'http://github.com/cikl'

  s.files = []

  s.add_dependency 'cikl-event',                version
  s.add_dependency 'cikl-api',                  version
  s.add_dependency 'cikl-worker',               version
  s.add_dependency 'threatinator-output-cikl',  version

  s.add_dependency 'bundler',         '>= 1.3.0', '< 2.0'
end
