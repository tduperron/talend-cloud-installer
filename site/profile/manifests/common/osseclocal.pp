# Install and configure an Ossec server

class profile::common::osseclocal {

  class { '::profile::common::ossec':
  }

  $ossectype = 'local'

  file { 'ossecvars':
    ensure  => present,
    path    => "${::workdir}/${::ossecversion}/etc/preloaded-vars.conf",
    content => template("profile/ossec/preloaded-vars.conf-${ossectype}.erb"),
    require => Exec['extract-ossec'],
  }

  exec { 'install-ossec':
    cwd     => "${::workdir}/${::ossecversion}",
    command => "${::workdir}/${::ossecversion}/install.sh",
    creates => '/var/ossec/etc',
    user    => root,
    require => File['ossecvars'],
  }

  service { 'ossec':
    ensure => running,
    enable => true,
  }

  # manage ossec.conf file
  file { 'ossec.conf':
    ensure  => present,
    path    => '/var/ossec/etc/ossec.conf',
    owner   => root,
    group   => ossec,
    mode    => '0550',
    content => template("profile/ossec/ossec-conf-${ossectype}.erb"),
  }

  # manage the /var/ossec/rules
  file { 'ossec-rules':
    ensure   => directory,
    path     => '/var/ossec/rules',
    checksum => 'mtime',
    owner    => root,
    group    => ossec,
    mode     => '0550',
    source   => "${::workdir}/ossec/ossec-rules",
    recurse  => true,
  }

  exec { 'ossec-restart':
    command     => '/var/ossec/bin/ossec-control restart',
    subscribe   => File[ 'ossec.conf' , 'ossec-rules' ],
    refreshonly => true,
  }
}
