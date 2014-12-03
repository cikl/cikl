version = File.read(File.expand_path('../../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'cikl-api'
  s.version     = version
  s.summary     = 'Cikl API'

  s.license = 'LGPLv3'

  s.author   = 'Michael Ryan'
  s.email    = 'falter@gmail.com'
  s.homepage = 'http://github.com/cikl'

  s.files = Dir[
    'LICENSE',
    'config.ru',
    'Rakefile',
    'README.md',
    'CONTRIBUTING.md',
    'app/**/*',
    'config/**/*',
    'lib/**/*',
    'vendor/**/*'
  ]

  s.add_dependency 'cikl-event',                version
  s.add_dependency 'multi_json',                '>= 1.10.0'
  s.add_dependency 'virtus',                    '>= 1.0.0'
  s.add_dependency 'puma',                      '>= 2.8.2'
  s.add_dependency 'elasticsearch',             '~> 1.0.0'
  s.add_dependency 'connection_pool',           '~> 2.0.0'
  s.add_dependency 'jbuilder',                  '>= 2.0.0'
  s.add_dependency 'typhoeus',                  '>= 0.6.8'
  s.add_dependency 'mongo',                     '~> 1.10.0'
  s.add_dependency 'bson_ext',                  '~> 1.10.0'
  s.add_dependency 'rack-cors',                 '~> 0.2.0'
  s.add_dependency 'grape',                     '~> 0.7.0'
  s.add_dependency 'grape-entity',              '~> 0.4.0', '>= 0.4.3'
  s.add_dependency 'grape-swagger',             '~> 0.7.0'
end
