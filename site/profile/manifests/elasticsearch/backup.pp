#
# Backup of elasticsearch 
#
class profile::elasticsearch::backup (
    $backup_bucket = $::backup_bucket,
    $region = $::region,
    $backup_cron_hour = '*/2',
	$backup_cron_minute = '15',
	$cron_ensure = 'absent',
) {
	$backup_buckets = split(regsubst($backup_bucket, '[\s\[\]\"]', '', 'G'), ',')
	$backup_bucket_name = $backup_buckets[0]
	
	file {
		'/usr/local/bin/elasticsearch_backup.sh':
			source => 'puppet:///modules/profile/usr/local/bin/elasticsearch_backup.sh',
	        mode   => '0755',
	        owner  => 'root'
			}
	cron {
		'elasticsearch_full_backup':
			ensure  => $cron_ensure,
	        command => "/usr/bin/flock -n /var/run/elasticsearch_backup.lock /usr/local/bin/elasticsearch_backup.sh ${backup_bucket_name} ${region} full-backup 2>&1 | logger -t elasticsearch-backup",
	        hour    => '0',
	        minute  => '0',
	        weekday => '1'
			}
	cron {
		'elasticsearch_backup':
			ensure  => $cron_ensure,
	        command => "/usr/bin/flock -n /var/run/elasticsearch_backup.lock /usr/local/bin/elasticsearch_backup.sh ${backup_bucket_name} ${region} incremental 2>&1 | logger -t elasticsearch-backup",
	        hour    => $backup_cron_hour,
	        minute  => $backup_cron_minute
			}
}

