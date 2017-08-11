#!/bin/bash

DESTINATION="/root/zookeeper-backup/"
SOURCE="/var/lib/zookeeper/data"
DATE="$(date +"%Y-%m-%d-%H-%M")"

mac=`curl -s "http://169.254.169.254/latest/meta-data/network/interfaces/macs/"`
vpc_id=`curl -s "http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac}vpc-id"`
S3_URL="s3://$1/$vpc_id/zookeeper"

echo stat | nc localhost 2181 | grep leader
is_leader=$(echo $?)

echo $leader

if [ "$is_leader" = 0 ]; then

	rm -rf $DESTINATION
	mkdir -p $DESTINATION

	echo "creating tar.gz"
	cd $SOURCE
	tar czPf $DESTINATION/zookeeper.tar.gz version-2

	echo "syncing tar to S3"
	aws s3 cp $DESTINATION $S3_URL/$DATE/ --sse AES256 --recursive

fi
