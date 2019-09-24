class profile::common::osseclocal {

  class { '::profile::common::ossec':
  }

  $ossectype = "local"

  file { "ossecvars":
    path => "${workdir}/${ossecversion}/etc/preloaded-vars.conf",
    ensure => present,
    content => template("ossec/preloaded-vars.conf-${ossectype}"),
    require => Exec["extract-ossec"],
  }

  exec { "install-ossec":
    cwd => "${workdir}/${ossecversion}",
    command => "${workdir}/${ossecversion}/install.sh",
    creates => "/var/ossec/etc",
    user => root,
    require => File["ossecvars"],
  }

  service { "ossec":
    enable => true,
    ensure => running,
  }

  # manage ossec.conf file
  file { "ossec.conf":
    path => "/var/ossec/etc/ossec.conf",
    ensure  => present, owner => root, group => ossec, mode => 550,
    content => template("ossec/ossec-conf-${ossectype}.erb"),
  }

  # manage the /var/ossec/rules
  file { "ossec-rules":
    path => "/var/ossec/rules",
    checksum => "mtime",
    ensure  => directory, owner => root, group => ossec, mode => 550,
    source  => "puppet:///$workdir/ossec/ossec-rules",
    recurse => true,
  }

  exec { "ossec-restart":
    command => "/var/ossec/bin/ossec-control restart",
    subscribe => File[ "ossec.conf" , "ossec-rules" ],
    refreshonly => true,
  }
}
