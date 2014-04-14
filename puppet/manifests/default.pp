class { 'cikl::elasticsearch':
  cluster_name => "vagrant_logstash"
}

class { 'cikl::rabbitmq': 
}

class { 'cikl::logstash':
}

class { 'cikl::smrt': 
}

#class {'jruby': 
#  version => '1.7.11'
#}
