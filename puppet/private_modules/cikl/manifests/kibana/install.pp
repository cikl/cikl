class cikl::kibana::install {
  $kibana_version = '3.0.1'
  $kibana_name = "kibana-${kibana_version}"
  $kibana_install_path = "${cikl::kibana_base}/${kibana_name}"
  $kibana_tgz = "${kibana_name}.tar.gz"
  $kibana_conf = "${kibana_root}/config.js"

  file { $kibana_base: 
    ensure => 'directory'
  }

  staging::file { $kibana_tgz:
    source => "puppet:///modules/cikl/${kibana_tgz}"
  }

  staging::extract { $kibana_tgz:
    target  => $cikl::kibana_base,
    creates => $kibana_install_path,
    require => [
      Staging::File[$kibana_tgz],
      File[$kibana_base]
    ]
  }

  file { $kibana_root: 
    ensure  => $kibana_install_path,
    require => Staging::Extract[$kibana_tgz]
  }

  file { $kibana_conf:
    content => template('cikl/kibana-config.js.erb'),
    replace => true
  }

  file { "${kibana_root}/app/dashboards/${cikl::kibana_dashboard}":
    content => template('cikl/kibana-dashboard.json.erb'),
    replace => true
  }
}



