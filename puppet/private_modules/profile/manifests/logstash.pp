class profile::logstash (
  $elasticsearch_template_path = '/etc/cikl-elasticsearch-template.json',
  $elasticsearch_cluster_name = 'cikl_cluster',
  $rabbitmq_host = 'localhost',
  $rabbitmq_port = 5672,
  $rabbitmq_username = 'guest',
  $rabbitmq_password = 'guest',
  $rabbitmq_vhost = '/',
) 
inherits profile::base {
  ensure_packages(['openjdk-7-jre-headless'])

  class { '::logstash': 
    manage_repo       => true,
    repo_version      => '1.4',
    require           => Package['openjdk-7-jre-headless'],
    install_contrib   => true,
    restart_on_change => true,
    status            => enabled
  }

  file { 'elasticsearch-cikl-template': 
    path    => $elasticsearch_template_path,
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/logstash/elasticsearch-cikl-template.json.erb'),
    before  => Class['::logstash'],
    notify  => Class['::logstash::service']
  }

  ::logstash::configfile { 'input-rabbitmq':
    content => template('profile/logstash/logstash-input-rabbitmq.conf.erb'),
    order   => 10
  }

  ::logstash::configfile { 'filter-event':
    content => template('profile/logstash/logstash-filter-event.conf.erb'),
    order   => 20
  }

  ::logstash::configfile { 'output-elasticsearch':
    content => template('profile/logstash/logstash-output-event.conf.erb'),
    require => File['elasticsearch-cikl-template'],
    order   => 30
  }

  logstash::configfile { 'output-resolve':
    content => template('profile/logstash/logstash-output-resolve.conf.erb'),
    order   => 40
  }

  file { 'profile::logstash::disable-web':
    path    => '/etc/init/logstash-web.override',
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => 'manual',
    before  => Class['::logstash']
  }

  file_line { 'add-plugins':
    path    => '/etc/default/logstash',
    line    => "LS_OPTS='--pluginpath /vagrant/logstash-plugins'",
    notify => Class['::logstash::service']
  }
}
