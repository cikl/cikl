class cikl::smrt () {
  require cikl::rabbitmq
  require cikl::common_packages

  exec { 'install Cikl': 
    command => '/usr/bin/cpanm --notest --skip-satisfied Cikl Cikl::RabbitMQ',
    require => [ 
      Package[
        'cikl::common_packages::build-essential', 
        'cikl::common_packages::cpanminus', 
        'cikl::common_packages::libxml2-dev']
    ]
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
