define bundler::binstubs($source_path, $gem_name, $bindir) {
  include bundler::setup

  exec { "bundle binstubs $source_path $gem_name $bindir":
    cwd         => $source_path,
    environment => [ "BUNDLE_BIN=$bindir" ],
    command     => "/usr/local/bin/bundle binstubs $gem_name --force",
    require => [
      Class['bundler::setup']
    ]
  }
}

