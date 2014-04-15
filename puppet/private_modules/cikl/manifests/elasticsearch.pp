class cikl::elasticsearch {
  include cikl::repositories
  include cikl::packages::java7

  class { '::elasticsearch':
    config => {
      'cluster.name' => $cikl::params::elasticsearch_cluster_name,
        'node.name' => $::ipaddress,
        'index' => {
          'number_of_replicas' => '0',
          'number_of_shards' => '1',
        },
        'network' => {
          'host' => '0.0.0.0',
        }
    },
    require =>  
      Class[
        'cikl::repositories',
        'cikl::packages::java7'
      ]
  }

  elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head'
  }

}


