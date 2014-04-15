class cikl::repositories {
  if !defined(Class['apt']) {
    class { 'apt': }
  }

  # Ensure that apt-get update is run prior to installing any packages.
}
