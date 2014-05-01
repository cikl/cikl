class cikl::elasticsearch (
  $cluster_name = 'cikl_cluster'
)
{
  include cikl::elasticsearch::repo
  contain cikl::elasticsearch::deps
  contain cikl::elasticsearch::package

  Class['cikl::elasticsearch::repo'] -> Class['cikl::elasticsearch::package']
  Class['cikl::elasticsearch::deps'] -> Class['cikl::elasticsearch::package']
}


