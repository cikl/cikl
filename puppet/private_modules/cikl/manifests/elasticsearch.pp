class cikl::elasticsearch (
  $cluster_name = 'cikl_cluster'
)
{
  contain cikl::elasticsearch::deps
  contain cikl::elasticsearch::package

  Class['cikl::elasticsearch::deps'] -> Class['cikl::elasticsearch::package']
}


