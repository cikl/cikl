class cikl::perl::perlbrew () {
  require cikl::packages::build-essential

  anchor { 'cikl::perl::perlbrew::begin': } ->
  anchor { 'cikl::perl::perlbrew::end': }

  $perlbrew_root = "/opt/perlbrew"
  $perlbrew_bin = "${perlbrew_root}/bin/perlbrew"
  $perl_version = "5.18.2"
  $perl_name    = "cikl-perl-${perl_version}"
  $patchperl_bin = "${perlbrew_root}/bin/patchperl"

  file { [ $perlbrew_root, "${perlbrew_root}/bin" ]: 
    ensure => 'directory'
  } 
  ->
  file { $perlbrew_bin :
    source => 'puppet:///modules/cikl/perlbrew',
    mode   => '0755',
    ensure => present
  } 
  ->
  file { $patchperl_bin :
    source => 'puppet:///modules/cikl/patchperl',
    ensure => present,
    mode   => '0755'
  } 

  exec { 'init_perlbrew':
    command     => "/usr/bin/perl ${perlbrew_bin} init",
    environment => ["PERLBREW_ROOT=${perlbrew_root}"],
    creates     => "${perlbrew_root}/perls",
    require     => File[ $perlbrew_bin, $patchperl_bin ]
  } 

  exec { 'install_cikl-perl':
    command     => "/usr/bin/perl ${perlbrew_bin} install perl-5.18.2 --as ${perl_name} --thread --64int --multi --ld --noman --notest",
    environment => ["PERLBREW_ROOT=${perlbrew_root}"],
    timeout     => 0,
    creates     => "${perlbrew_root}/perls/${perl_name}",
    require     => Exec['init_perlbrew'],
    before      => Anchor['cikl::perl::perlbrew::end']
  } 
}




