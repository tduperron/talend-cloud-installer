#
# Configures cloudwatch with hiera-defined log files
#
class profile::common::cloudwatchlogs (

  $include = true,

) {
  if $include {
    create_resources(
      '::cloudwatchlogs::log',
      hiera_hash('cloudwatchlog_files', {})
    )
  }
}
