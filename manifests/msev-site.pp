File { backup => false }

Package {
  allow_virtual => true,
}

Exec {
  path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
}


node default {
  # This is where you can declare dynamic classes for all nodes.
  # concat::fragment { "10_fragment_role_${name}":
  #   target  => '/etc/sysconfig/puppetRole',
  #   content => "$name\n"
  # }

  include ::profile::common::concat

  role::register_role { "$name": }

}
