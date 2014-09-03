class bundler::setup {
  ensure_packages(['build-essential', 'ruby', 'ruby-dev'])

  package { 'bundler':
    ensure   => 'latest',
    provider => 'gem',
    require  => [
      Package['ruby', 'ruby-dev', 'build-essential']
    ]
  }
}
