#
# Role for TAC Performance tests
#
class role::tac_perf_tests () {
  require ::profile::base
  require ::profile::docker::host
  require ::profile::docker::registry
  require ::profile::tac_perf_tests
  role::register_role { 'tac_perf_tests': }

}
