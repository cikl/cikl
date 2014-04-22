class cikl::smrt::package () {
  perl::module { 'Cikl': 
    require          => Class['cikl::smrt::deps'],
    exec_environment => [ 'PERL_CPANM_OPT=--notest --skip-satisfied' ],
    exec_timeout          => 0
  } ->
  perl::module { 'Cikl::RabbitMQ': 
    exec_environment => [ 'PERL_CPANM_OPT=--notest --skip-satisfied' ],
    exec_timeout          => 0
  }
}

