class cikl::elasticsearch (
  $cluster_name = 'vagrant_elasticsearch'
) {

  require cikl::repositories
  include cikl::common_packages

  class { '::elasticsearch':
    config => {
      'cluster.name' => $cluster_name,
        'node.name' => $::ipaddress,
        'index' => {
          'number_of_replicas' => '0',
          'number_of_shards' => '1',
        },
        'network' => {
          'host' => '0.0.0.0',
        }
    },
    require => [ 
      Class['cikl::repositories'],
      Package['cikl::common_packages::java7']
    ] 
  }

  elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head'
  }

}


