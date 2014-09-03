class profile::threatinator (
  $local_path,
  $bin_dir,
  $gem_root      = '/opt/cikl/threatinator/gems',
) inherits profile::base {

  ensure_packages(['libxml2-dev'])

  bundler::install { "threatinator":
    source_path => $local_path,
    gem_root    => $gem_root,
    require => [
      Package['libxml2-dev']
    ]
  } -> 
  bundler::binstubs { "threatinator":
    source_path   => $local_path,
    gem_name      => 'threatinator',
    bindir        => $bin_dir
  }
}


