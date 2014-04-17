class cikl::elasticsearch::install {
  include cikl::elasticsearch::deps

  class { '::elasticsearch':
    manage_repo  => true,
    repo_version => '1.0',
    config => {
      'cluster.name' => $cikl::elasticsearch_cluster_name,
        'node.name' => $::ipaddress,
        'index' => {
          'number_of_replicas' => '0',
          'number_of_shards' => '1',
        },
        'network' => {
          'host' => '0.0.0.0',
        }
    },
    require =>  Class['cikl::elasticsearch::deps']
  }

  elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head'
  }

}


