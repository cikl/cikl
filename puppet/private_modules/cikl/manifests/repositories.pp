class cikl::repositories {
  if !defined(Class['apt']) {
    class { 'apt': }
  }

  # Ensure that apt-get update is run prior to installing any packages.
  Exec['apt_update'] -> Package <| |>


  anchor {'cikl::repositories::begin': } 
  anchor {'cikl::repositories::end': 
    require => Anchor['cikl::repositories::begin']
  }

  apt::key { 'elasticsearch': 
    key               => 'D88E42B4',
    key_source        => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }
  apt::key { 'logstash': 
    key               => 'D88E42B4',
    key_source        => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  apt::source { 'elasticsearch':
    location          => 'http://packages.elasticsearch.org/elasticsearch/1.0/debian',
    release           => 'stable',
    repos             => 'main',
    include_src       => false,
    require           => [ Apt::Key['elasticsearch'], Anchor['cikl::repositories::begin'] ],
    before            => Anchor['cikl::repositories::end']
  } 

  apt::source { 'logstash':
    location          => 'http://packages.elasticsearch.org/logstash/1.4/debian',
    release           => 'stable',
    repos             => 'main',
    include_src       => false,
    require           => [ Apt::Key['logstash'], Anchor['cikl::repositories::begin'] ],
    before            => Anchor['cikl::repositories::end']
  } 


}
