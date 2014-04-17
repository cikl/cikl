stage { "init": before => Stage['main'] }
class { 'cikl::repositories': 
  stage => 'init'
}

class { 'cikl':
  elasticsearch_cluster_name => "vagrant_logstash"
}

#class {'jruby': 
#  version => '1.7.11'
#}
