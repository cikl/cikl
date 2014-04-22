class cikl::elasticsearch::package {
  class { '::elasticsearch':
    manage_repo  => false,
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
  }

  contain 'elasticsearch'

  elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head'
  }

}


