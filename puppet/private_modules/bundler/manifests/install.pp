define bundler::install($source_path, $gem_root) {
  include bundler::setup

  exec { "create gem root $source_path $gem_root": 
    command => "/bin/mkdir -p $gem_root",
    unless  => "/usr/bin/test -d $gem_root"
  } -> 
  exec { "bundle install $source_path $gem_root":
    cwd     => $source_path,
    environment => [ "BUNDLE_JOBS=7", "BUNDLE_PATH=$gem_root" ],
    command => "/usr/local/bin/bundle install --path=$gem_root",
    require => [
      Class['bundler::setup']
    ],
    unless => "/usr/local/bin/bundle check"
  }
}
