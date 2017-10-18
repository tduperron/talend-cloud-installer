#
# Installs Amazon SSM agent
#
class profile::common::ssm (

  $include        = true,
  $region         = undef,
  $service_enable = true,
  $service_ensure = running,

) {

  if $include {
    $url  = "https://amazon-ssm-${region}.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm"
    $path = '/opt/amazon-ssm-agent.rpm'

    if ! defined(Package['wget']) {
      ensure_packages(['wget'])
    }

    exec { 'download-ssm-agent':
      command => "/usr/bin/wget -T60 -N ${url} -O ${path}",
      creates => $path,
      require => Package['wget']
    } ->
    package { 'amazon-ssm-agent':
      ensure   => present,
      provider => 'rpm',
      source   => $path,
    } ->
    service { 'amazon-ssm-agent':
      ensure => $service_ensure,
      enable => $service_enable,
    }
  }
  

}
