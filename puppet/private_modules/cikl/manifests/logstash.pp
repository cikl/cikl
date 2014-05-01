class cikl::logstash (
    $elasticsearch_template_path = '/etc/cikl-elasticsearch-template.json',
    $elasticsearch_cluster_name = 'cikl_cluster',
    $rabbitmq_host = 'localhost',
    $rabbitmq_port = 5672,
    $rabbitmq_username = 'guest',
    $rabbitmq_password = 'guest',
    $rabbitmq_vhost = '/',
  )
{
  file { 'elasticsearch-cikl-template': 
    path    => $elasticsearch_template_path,
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/logstash/elasticsearch-cikl-template.json.erb'),
    before  => Class['::logstash']
  }

  ::logstash::configfile { 'input-rabbitmq':
    content => template('cikl/logstash/logstash-input-rabbitmq.conf.erb'),
    order   => 10
  }

  ::logstash::configfile { 'filter-event':
    content => template('cikl/logstash/logstash-filter-event.conf.erb'),
    order   => 20
  }

  ::logstash::configfile { 'output-elasticsearch':
    content => template('cikl/logstash/logstash-output-event.conf.erb'),
    require => File['elasticsearch-cikl-template'],
    order   => 30
  }

  logstash::configfile { 'output-resolve':
    content => template('cikl/logstash/logstash-output-resolve.conf.erb'),
    order   => 40
  }

  file { 'cikl::logstash::disable-web':
    path    => '/etc/init/logstash-web.override',
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => 'manual',
    before  => Class['::logstash']
  }
}
