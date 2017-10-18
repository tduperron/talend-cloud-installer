# -*- mode: puppet -*-
# vi: set ft=puppet
#
# === Authors
# Andreas Heumaier <andreas.heumaier@nordcloud.com>
#
class profile::web::nginx {

  if ! defined(Package['openssl']) {
      package { 'openssl': ensure => 'latest' }

      package['openssl'] -> Class['nginx']
  }

  include ::nginx
  include ::profile::common::concat
  include ::profile::common::cloudwatchlogs


  profile::register_profile{ 'nginx': }

  if $::osfamily == 'RedHat' and $::selinux == 'true' {
    selinux::boolean{ 'httpd_can_network_connect':
      ensure => 'on',
    }
    selinux::boolean{ 'httpd_setrlimit':
      ensure => 'on',
    }

    $vhosts = hiera('nginx::nginx_vhosts', {})
    if has_key($vhosts, 'redirect') {
      selinux::port{ 'allow-http-redirect-port':
        context  => 'http_port_t',
        protocol => 'tcp',
        port     => $vhosts['redirect']['listen_port'],
      }
    }
    if has_key($vhosts, 'tic_services') {
      selinux::port{ 'allow-http-tic_services-port':
        context  => 'http_port_t',
        protocol => 'tcp',
        port     => $vhosts['tic_services']['listen_port'],
      }
    }
  }

}
