class cikl::perl() {

  if (!defined(Class['::perl'])) {
    class { '::perl': 
    }
  }

  if ($cikl::use_perlbrew == true) {
    include cikl::perl::perlbrew
    Class['cikl::perl::perlbrew'] -> Class['::perl']
  }

}





