class profile::tac_perf_tests (

) {

  require ::profile::base
  require ::profile::docker::host
  require ::profile::docker::registry
  role::register_role { 'tac_perf_tests': }

}
