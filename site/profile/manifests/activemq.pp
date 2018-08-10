#
# ActiveMQ service profile
#
class profile::activemq {

  require ::profile::common::packagecloud_repos
  require ::profile::java
  require ::profile::postgresql

  include ::profile::common::concat
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'activemq': }

  # prevent postgres provisioning on all the nodes except one: ActiveMQ-A
  # this should be replaced with more sophisticated solution in the future
  $ec2_userdata = pick_default($::ec2_userdata, '')
  if $ec2_userdata =~ /InstanceA/ {
    $update_user_password = "/usr/bin/psql \
    -U ams \
    -h ${::profile::postgresql::hostname} \
    -d ams \
    -c \"update amqsec_system_users set password = '\$AMS_ADMIN_PASSWORD' where username = 'admin'\""

    class { '::activemq': } ->
    class { '::profile::postgresql::provision': } ->
    exec { 'update the amqsec_system_users':
      environment => [
        "PGPASSWORD=${::profile::postgresql::password}",
        "AMS_ADMIN_PASSWORD=${::profile::postgresql::password}"
      ],
      command     => $update_user_password,
    }
    contain ::activemq
    contain ::profile::postgresql::provision
  } else {
    contain ::activemq
  }

}
