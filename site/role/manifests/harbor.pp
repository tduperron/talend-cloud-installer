#
# Docker registry with Harbor instance role
#
class role::harbor {
  require ::profile::base
  require ::profile::docker::registry::harbor

  role::register_role { 'harbor': }
}
