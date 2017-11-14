#
# TIC Frontend profile
#
class profile::tic_frontend (

  $version = undef,

) {

  include ::logrotate
  include ::profile::common::concat

  profile::register_profile { 'tic_frontend': }

  if size($version) > 0 {
    $_version = $version
  } else {
    $_version = 'installed'
  }

  class { '::tic::frontend':
    version => $_version,
  }

  contain ::tic::frontend

  if $::environment == 'ami' {
    class { 'profile::build_time_facts':
      facts_hash => {
        'ipaas_frontend_build_version' => $_version,
        'tic_frontend_version'         => $_version,
      }
    }
  }

}
