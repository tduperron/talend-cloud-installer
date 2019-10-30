#
# ActiveMQ service role
#
class role::activemq {

  include ::profile::base
  include ::profile::activemq
  include ::profile::nginx_reverseproxy

  role::register_role { 'activemq': }

}
