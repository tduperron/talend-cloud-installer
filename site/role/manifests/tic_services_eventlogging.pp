#
# TIC Services role
#
class role::tic_services_eventlogging {

  require ::profile::base
  require ::profile::tic_services

  role::register_role { 'tic_services_eventlogging': }

}
