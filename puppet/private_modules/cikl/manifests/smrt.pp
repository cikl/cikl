class cikl::smrt () {
  include cikl::packages::smrt-deps

#  exec { 'install Cikl': 
#    command => '/usr/bin/cpanm --notest --skip-satisfied Cikl Cikl::RabbitMQ',
#    require => [ 
#      Class[
#        'cikl::packages::smrt-deps']
#    ]
#  }
  # Generate cikl.conf

  file { 'cikl-conf': 
    path    => "/etc/cikl.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/cikl.conf.erb')
  }

}
