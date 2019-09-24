class profile::common::ossec {

  $ossecversion = "ossec-hids-3.3.0"
  $ossecfile = "$ossecversion.tar.gz"
  $workdir = "/opt/ossec-tmp"

  file { "/opt/ossec-tmp":
    ensure  => directory,
    owner => root,
    group => root,
    mode => 760,
  }

  profile::common::download_file { "${ossecfile}":
    site => "https://github.com/ossec/ossec-hids/archive",
    cwd => "${workdir}",
    creates => "${workdir}/$name",
    require => File["/opt/ossec-tmp"],
    user => root,
  }

  exec { "extract-ossec":
    cwd => "${workdir}",
    command => "/bin/tar xzf ${ossecfile}",
    creates => "${workdir}/${ossecversion}",
    require => Download_file["${ossecfile}"],
    user => root,
  }
}
