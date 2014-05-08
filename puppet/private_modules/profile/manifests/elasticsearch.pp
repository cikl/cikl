class profile::elasticsearch (
  $cluster_name = 'cikl_cluster',
  $node_name    = 'cikl_es'
) inherits profile::base  {

  ensure_packages(['openjdk-7-jre-headless'])
  class { '::elasticsearch': 
    manage_repo            => true,
    repo_version           => '1.0',
    config                 => {
      'cluster.name'       => $cluster_name,
      'node.name'          => $node_name,
      index                => {
          number_of_replicas => 0,
          number_of_shards   => 1
        },
      network => {
          host  => '0.0.0.0'
        }
    },
    require => Package['openjdk-7-jre-headless']
  }

  ::elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head'
  }
}

