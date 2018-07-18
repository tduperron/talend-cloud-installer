#
# Profile for TAC Performance tests
#
# MYSQL container can be launched on the same host as TAC
# MYSQL server DNS name can be overrided with $mysql_override
#
class profile::tac_perf_tests (
  $ensure = 'present',
  $tac_image = 'localhost:5000/talend/tacperf-tac:latest',
  $mysql_image = 'localhost:5000/talend/tacperf-mysql:latest',
  $discovery_image = 'localhost:5000/talend/tacperf-discovery:latest',
  $run_mysql = true,
  $tac_ext_port = 48080,
  $cloud_env = true,
  $debug_tac = false,
  $delay_migr = 0,
  $disable_tac_migr = false,
  $dns_prefix = 'tac-perftest-',
  $dns_suffix = '.datapwn.com',
  $mysql_port = 3306,
  $mysql_timeout = 180,
  $tac_migr_timeout = 450,
  $mysql_override = undef,
  $tac_java_opts = '-Xms1g -Xmx6g',
  $hosted_zone = 'ZA03FQPZM492O'
) {

  require ::profile::docker::host
  require ::profile::docker::registry

  $network_name = 'tactests-vnet'
  $state_dir_path = '/tmp/app_state'

  docker_network { $network_name:
    ensure => present,
    driver => 'bridge',
  }

  file { $state_dir_path:
    ensure => 'absent',
    force  => true
  }

  exec {'check_tac_systemd':
    command => '/bin/true',
    onlyif  => '/usr/bin/test -e q',
  }

  exec {'stop_tac':
    command => 'sudo systemctl stop docker-tac.service || true',
    require => Exec['check_tac_systemd'],
  }


  $temp_tac_env_vars = [  "APP_STATE_PATH=${state_dir_path}",
                          "CLOUD_ENVIRONMENT=${cloud_env}",
                          "DEBUG_TAC=${debug_tac}",
                          "DELAY_BEFORE_MIGRATION=${delay_migr}",
                          "DISABLE_TAC_MIGRATION=${disable_tac_migr}",
                          "DNS_PREFIX=${dns_prefix}",
                          "DNS_SUFFIX=${dns_suffix}",
                          "MYSQL_PORT=${mysql_port}",
                          "MYSQL_READY_TIMEOUT=${mysql_timeout}",
                          "TAC_MIGR_TIMEOUT=${tac_migr_timeout}",
                          "\"JAVA_OPTS=${tac_java_opts}\""
                        ]

  if $mysql_override != undef {
    $tac_env_vars = concat($temp_tac_env_vars, "MYSQL_SERVER_OVERRIDE=${mysql_override}")
    notice("MySQL server name was overrided with: ${mysql_override}")
  } else {
    $tac_env_vars = $temp_tac_env_vars
  }

  docker::run { 'tac':
    ensure                    => $ensure,
    image                     => $tac_image,
    ports                     => ['48080:8080'],
    net                       => $network_name,
    memory_limit              => '10g',
    restart_service           => false,
    pull_on_start             => true,
    remove_container_on_start => true,
    extra_parameters          => [ '--restart=no --rm' ],
    env                       => $tac_env_vars,
    volumes                   => [ "${state_dir_path}:${state_dir_path}" ],
    require                   => Exec['stop_tac'],
    after                     => [ 'registry' ]
  }

  $temp_tac_disc_vars = [ 'APP_STATE_LOOKUP=VOLUME',
                          'APP_SUCCESS_TIMEOUT=450',
                          'DEBUG_ENABLED=false',
                          'DNS_PREFIX=tac-perftest-',
                          'DNS_SUFFIX=.datapwn.com',
                          "HOSTED_ZONE_ID=${hosted_zone}",
                          'NUM_OF_SERVICES=1',
                          'SERVICE_NAME=tac',
                          "VOLUME_PATH=${state_dir_path}"
                        ]


  if $environment == 'vagrant' {
    $tac_disc_vars = concat( $temp_tac_disc_vars,
                            "AWS_ACCESS_KEY_ID=${::aws_accesskey}",
                            "AWS_SECRET_ACCESS_KEY=${::aws_secretkey}",
                            "AWS_DEFAULT_REGION=${::region}"
                          )
  } else {
    $tac_disc_vars = $temp_tac_disc_vars
  }


  docker::run { 'tac-discovery':
    ensure                    => $ensure,
    image                     => $discovery_image,
    memory_limit              => '128m',
    restart_service           => false,
    pull_on_start             => true,
    remove_container_on_start => true,
    volumes                   => [ "${state_dir_path}:${state_dir_path}" ],
    extra_parameters          => [ '--restart=no --rm' ],
    env                       => $tac_disc_vars,
    after                     => [ 'registry' ]
  }

  if $run_mysql {

      exec {'check_mysql_systemd':
        command => '/bin/true',
        onlyif  => '/usr/bin/test -e /etc/systemd/system/docker-mysql.service',
      }

      exec {'stop_mysql':
        command => 'sudo systemctl stop docker-mysql.service || true',
        require => Exec['check_mysql_systemd'],
      }

      docker::run { 'mysql':
        ensure           => $ensure,
        image            => $mysql_image,
        ports            => ['3306'],
        expose           => ['3306'],
        net              => $network_name,
        memory_limit     => '1g',
        restart_service  => false,
        pull_on_start    => true,
        extra_parameters => [ '--restart=no --rm' ],
        require          => Exec['stop_mysql'],
        after            => [ 'registry' ]
      }

      Docker_network[$network_name] -> Docker::Run['mysql'] -> Docker::Run['tac'] -> Docker::Run['tac-discovery']

  } else {

    Docker_network[$network_name] -> Docker::Run['tac'] -> Docker::Run['tac-discovery']

  }
}
