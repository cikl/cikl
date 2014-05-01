class cikl::rabbitmq {
  include cikl::rabbitmq::repo
  contain cikl::rabbitmq::service
  contain cikl::rabbitmq::deps
  contain cikl::rabbitmq::package

  Class['cikl::rabbitmq::repo'] -> Class['cikl::rabbitmq::package']
  Class['cikl::rabbitmq::deps'] -> Class['cikl::rabbitmq::package']
  Class['cikl::rabbitmq::package'] -> Class['cikl::rabbitmq::service']
}
