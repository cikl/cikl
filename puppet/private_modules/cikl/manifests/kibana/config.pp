class cikl::kibana::config {
  $kibana_conf = "${cikl::kibana_root}/config.js"

  file { $kibana_conf:
    content => template('cikl/kibana-config.js.erb'),
    replace => true
  }

  file { "${cikl::kibana_root}/app/dashboards/${cikl::kibana_dashboard}":
    content => template('cikl/kibana-dashboard.json.erb'),
    replace => true
  }
}



