class profile::base {
  if !defined(Class['apt']) {
    class { 'apt': }
  }

  exec { 'cikl::apt-update': 
    command => '/usr/bin/apt-get update -y -q'
  }

  # Ensure that apt-get update is run prior to installing any packages via apt
  Exec['cikl::apt-update'] -> Package <| provider == 'apt' |>
}
