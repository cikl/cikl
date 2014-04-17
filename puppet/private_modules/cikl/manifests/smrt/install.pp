class cikl::smrt::install () {
  include cikl::smrt::deps

  perl::module { 'Cikl': 
    require          => Class['cikl::smrt::deps'],
    exec_environment => [ 'PERL_CPANM_OPT=--notest --skip-satisfied' ],
    exec_timeout          => 0
  } ->
  perl::module { 'Cikl::RabbitMQ': 
    exec_environment => [ 'PERL_CPANM_OPT=--notest --skip-satisfied' ],
    exec_timeout          => 0
  }

  # Generate cikl.conf
  file { 'cikl-conf': 
    path    => "/etc/cikl.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/cikl.conf.erb')
  }

}
