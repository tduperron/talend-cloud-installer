#
# Installing Docker registry Harbor
#
class profile::docker::registry::harbor (
  $version = undef,
  $checksum = undef,
  $install_dir = undef,
) {

  require ::profile::base

  include '::archive'

  profile::register_profile { 'harbor': }

  $harbor_installer = "harbor-online-installer-v${version}.tgz"

  # Install docker engine and docker-compose
  class {'::docker':
    ensure                      => present,
    service_state               => 'running',
    service_enable              => true,
    use_upstream_package_source => true,
    repo_opt                    => '',
  } -> class {'::docker::compose':
    ensure => present,
  }

  # Download vmware/harbor online installer (pull images at startup if not present)
  archive { $harbor_installer:
    ensure        => present,
    path          => "/tmp/${harbor_installer}",
    source        => "https://storage.googleapis.com/harbor-releases/release-${version}/${harbor_installer}",
    checksum      => $checksum,
    checksum_type => 'md5',
    extract       => true,
    extract_path  => $install_dir,
    creates       => "${install_dir}/harbor/harbor.cfg",
    cleanup       => true,
  } ~>
  # Create a script to pull docker images found in harbor docker-compose files
  file {'/tmp/pull_harbor_images.sh':
    ensure    => file,
    path      => '/tmp/pull_harbor_images.sh',
    mode      => 'ug+x',
    owner     => 'root',
    content   => template('profile/tmp/harbor/pull_harbor_images.erb'),
  } ~>
  # Execute the script to pull docker images
  exec { 'pull_images':
    path      => ['/usr/local/bin', '/usr/bin', '/usr/local/sbin', '/usr/sbin'],
    command   => '/tmp/pull_harbor_images.sh',
    user      => 'root',
    require   => Service['docker'],
  }

}
