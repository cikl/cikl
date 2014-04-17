class cikl::repo::yum {
  # Enable EPEL repositories
  anchor { 'cikl::repo::yum::begin': } ->
  anchor { 'cikl::repo::yum::end': }
  class { '::epel': } -> Anchor['cikl::repo::yum::end']
}
