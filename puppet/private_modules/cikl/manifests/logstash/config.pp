class cikl::logstash::config (
  $elasticsearch_template_path = '/etc/cikl-elasticsearch-template.json',
  $elasticsearch_cluster_name = 'cikl_cluster',
) {
  file { 'elasticsearch-cikl-template': 
    path    => $elasticsearch_template_path,
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/elasticsearch-cikl-template.json.erb')
  }

  ::logstash::configfile { 'input-rabbitmq':
    content => template('cikl/logstash-input-rabbitmq.conf.erb'),
    order   => 10
  }

  ::logstash::configfile { 'filter-event':
    content => template('cikl/logstash-filter-event.conf.erb'),
    order   => 20
  }

  ::logstash::configfile { 'output-elasticsearch':
    content => template('cikl/logstash-output-event.conf.erb'),
    require => File['elasticsearch-cikl-template'],
    order   => 30
  }

  logstash::configfile { 'output-resolve':
    content => template('cikl/logstash-output-resolve.conf.erb'),
    order   => 40
  }
}



