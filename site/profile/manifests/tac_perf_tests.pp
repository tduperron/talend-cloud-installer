#
# Profile for TAC Performance tests
#
class profile::tac_perf_tests () {
  if $::run_mysql == 'true' {

      $network_name = 'tactests-vnet'

      docker_network { $network_name:
        ensure => present,
        driver => 'bridge',
      }


      docker::run { 'mysql':
        image           => $::mysql_image,
        ports           => ['3306'],
        expose          => ['3306'],
        net             => $network_name,
        memory_limit    => '1g',
        # cpuset          => ['0', '3'],
        restart_service => false,
        pull_on_start   => true,
        extra_parameters => [ '--restart=no' ],
      }

      # docker::run { 'helloworld':
      #   image   => 'nginx',
      #   command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
      # }

      info('koko')

  }
}
