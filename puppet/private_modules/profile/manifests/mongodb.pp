class profile::mongodb inherits profile::base {
  class { "::mongodb::server": 
    replset => 'rscikl'
  }

  mongodb_replset { 'rscikl':
    ensure  => present,
    members => ['localhost:27017']
    #members => ['cikl.private:27017']
  }

}

