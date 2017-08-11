#
# Sets up elasticsearch instance and waits for the service to start
#
class profile::elasticsearch (

  $plugins_hash   = undef,
  $security_group = 'not_available',
  $cluster_name   = undef,
  $heap_size      = undef,
  $config         = undef,
  $status         = running,
  $datadir        = '/usr/share/elasticsearch/data',
  $storage_device = undef,

) {

  class { '::profile::common::mount_device':
    device  => $storage_device,
    path    => $datadir,
    options => 'noatime,nodiratime'
  } ->
  class { '::profile::elasticsearch::setup':
    plugins_hash   => $plugins_hash,
    security_group => $security_group,
    cluster_name   => $cluster_name,
    heap_size      => $heap_size,
    config         => $config,
    status         => $status,
    datadir        => $datadir,
  } ->
  class { '::profile::elasticsearch::wait':
    status => $status,
  }

  contain ::profile::elasticsearch::setup
  contain ::profile::elasticsearch::wait

  include ::profile::common::concat
  include ::profile::common::cloudwatchlogs
  include ::profile::elasticsearch::backup
  
  profile::register_profile { 'elasticsearch': }

}
