
class cikl::update_repo {
  case $::osfamily {
    'Debian': {
      exec { 'cikl::update_repo': 
        command => '/usr/bin/apt-get update -y -qq'
      }
      Exec['cikl::update_repo'] -> Package <| provider == 'apt' |>
    }
    'RedHat': {
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }

  }
}
