#!/bin/bash
#First backup every monday is a full backup and rest are incremental

DATE="$(date -dlast-monday +"%Y-%m-%d")"
SNAPSHOT_NAME="snapshot_$(date +"%m%d%H")"

if [ $3 = "full-backup" ]; then
        DATE="$(date +"%Y-%m-%d")"
        SNAPSHOT_NAME='snapshot'
fi

MASTER=$(curl localhost:9200/_cat/master |awk '{print $2}')
HOSTNAME=$(/bin/hostname)

mac=`curl -s "http://169.254.169.254/latest/meta-data/network/interfaces/macs/"`
vpc_id=`curl -s "http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac}vpc-id"`


if [ "$MASTER" = "$HOSTNAME" ]; then
		curl -XPUT 'http://localhost:9200/_snapshot/backups' -d '{"type":"s3","settings":{"compress":"true","server_side_encryption":"true","base_path":"'$vpc_id'/elastic/acc/'$DATE'/","region":"'$2'","bucket":"'$1'"}}'
		curl -XPUT 'http://localhost:9200/_snapshot/backups/'$SNAPSHOT_NAME'?wait_for_completion=true'
fi