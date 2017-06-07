#
# Sets up the kafka instance
#
class profile::kafka (
  $kafka_version  = '0.10.1.1',
  $scala_version  = '2.11',
  $kafka_protocol_version = '0.10.1.1',
  $kafka_datapath = '/var/lib/kafka',
  $storage_device       = undef,
  $zookeeper_nodes      = '', # A string f.e. '[ "10.0.2.12", "10.0.2.23" ]'
  $zookeeper_kafkapath  = '', # A string f.e. '/kafka/logs'
  $kafka_broker_id   = '-1',
  $kafka_broker_config = {},
  $kafka_topics_config = {},
  $kafka_topics_default_replication = 1,
  $kafka_topics_default_partitions = 1,
  $log_retention_days = 31,
  $log_level = 'WARN'
) {

  require ::profile::common::packages
  require ::profile::java
  include ::logrotate
  include ::profile::common::concat
  # FIXME rework cloudwatch to add defines and so manage easily each mount in each profiles
  include ::profile::common::cloudwatch
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'kafka': }

  if empty($zookeeper_nodes){
    $zookeeper_connect = "127.0.0.1:2181${zookeeper_kafkapath}"
  } else {
    $zookeeper_connect = join(suffix(split(regsubst($zookeeper_nodes, '[\s\[\]\"]', '', 'G'), ','), ":2181${zookeeper_kafkapath}"), ',')
  }

  $_kafka_broker_config = {
    'broker.id'                     => $kafka_broker_id,
    'zookeeper.connect'             => $zookeeper_connect,
    'log.dir'                       => $kafka_datapath,
    'log.dirs'                      => $kafka_datapath,
    'inter.broker.protocol.version' => $kafka_protocol_version,
    'auto.create.topics.enable'     => false
  }

  class { '::profile::common::mount_device':
    device  => $storage_device,
    path    => $kafka_datapath,
    options => 'noatime,nodiratime,noexec',
  } ->
  class { '::kafka':
    version       => $kafka_version,
    scala_version => $scala_version,
    install_java  => false
  } ->
  class { '::kafka::broker':
    config                     => deep_merge($_kafka_broker_config, $kafka_broker_config),
    service_requires_zookeeper => false
  }

  file { $kafka_datapath:
    ensure  => 'directory',
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0750',
    require => [ User['kafka'], Group['kafka'] ],
    notify  => Service['kafka']
  }

  file { '/etc/cron.daily/kafka':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('profile/etc/cron.daily/kafka.erb'),
  }

  file { '/opt/kafka/config/log4j.properties':
    ensure  => 'present',
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0644',
    content => template('profile/opt/kafka/config/log4j.properties.erb'),
    require => File['/opt/kafka/config'],
    notify  => Service['kafka']
  }

  unless empty($kafka_topics_config) {
    exec { 'wait-for-kafka':
      command   => 'timeout 1 bash -c "cat < /dev/null > /dev/tcp/localhost/9092"',
      tries     => 10,
      try_sleep => 10,
      path      => ['/bin', '/usr/bin'],
      require   => Service['kafka']
    }

    create_resources('::profile::kafka::broker_topic',
      $kafka_topics_config,
      {
        replication_factor => $kafka_topics_default_replication,
        partitions         => $kafka_topics_default_partitions,
        require            => Exec['wait-for-kafka']
      }
    )
  }

  contain ::kafka::broker
}
