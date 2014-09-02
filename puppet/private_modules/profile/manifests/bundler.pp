class profile::bundler (
) inherits profile::base {
  ensure_packages(['ruby', 'ruby-dev'])
  package { 'bundler':
    ensure   => 'latest',
    provider => 'gem',
    require  => [
      Package['ruby', 'ruby-dev']
    ]
  }
}

