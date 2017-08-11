#
# Backup of zookeeper 
#
class profile::zookeeper::backup (
 	$backup_bucket = $::backup_bucket,
    $backup_cron_hour = '*',
    $backup_cron_minute = '0',
	$cron_ensure = 'absent',

) {
	
    package {
        'pyasn1' :
            ensure   => present,
            provider => 'pip';
    }

    $backup_buckets = split(regsubst($backup_bucket, '[\s\[\]\"]', '', 'G'), ',')
    $backup_bucket_name = $backup_buckets[0]

    file {
        '/usr/local/bin/zookeeper_backup.sh':
            source  => 'puppet:///modules/profile/usr/local/bin/zookeeper_backup.sh',
            mode    => '0755',
            owner   => 'root',
            require => Package[awscli];

        '/usr/local/bin/zookeeper_restore.sh':
            source  => 'puppet:///modules/profile/usr/local/bin/zookeeper_restore.sh',
            mode    => '0755',
            owner   => 'root',
            require => Package[awscli];
    }

    cron {
        'zookeeper_backup':
            ensure  => $cron_ensure,
            command => "/usr/bin/flock -n /var/run/zookeeper_backup.lock /usr/local/bin/zookeeper_backup.sh ${backup_bucket_name} 2>&1 | logger -t zookeeper-backup",
            hour    => $backup_cron_hour,
            minute  => $backup_cron_minute,
            require => Package[awscli]
    }

}