#!/bin/bash

mac=`curl -s "http://169.254.169.254/latest/meta-data/network/interfaces/macs/"`
vpc_id=`curl -s "http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac}vpc-id"`
S3_BASE_URL="s3://$1/$vpc_id/zookeeper"
RESTORE_DESTINATION="/var/lib/zookeeper/data"

stop_zk(){
    systemctl stop zookeeper.service
}

start_zk(){
    systemctl start zookeeper.service
}

download_s3(){
    aws s3 cp --quiet $S3_BASE_URL/$1/zookeeper.tar.gz /tmp/
}

extract_backup(){
    cd $RESTORE_DESTINATION
    tar pxf /tmp/zookeeper.tar.gz ; rm -rf /tmp/zookeeper.tar.gz
}
case $2 in

  "latest")
              echo "checking for latest backup"
              latest_backup=`aws s3 ls $S3_BASE_URL/ | grep PRE | tail -n 1 | cut -d"E" -f 2 | sed s'/[^0-9-]//'g`
              echo "copy and extract latest backup from s3"
              download_s3 $latest_backup
              echo "stopping ZK service"
              stop_zk
              extract_backup
              start_zk
              echo "zookeeper was restored successfully and zookeeper was restarted"
              exit 0
              ;;

   *)
              if [[ $2  =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2} ]]
              then
                   echo "checking if file is in S3"
                   status=`aws s3 ls $S3_BASE_URL/$2`
                   if [[ -z "${status// }" ]]; then
                        echo  "given file $2 is not in s3... exiting"
                        exit 1
                   fi
                   echo "getting file from s3"
                   download_s3 $2
                   echo "stoping ZK service"
                   stop_zk
                   extract_backup
                   start_zk
                   echo "zookeeper was restored successfully and zookeeper was restarted"
              else
                  echo "Usage: zookeeper_restore.sh bucketname parameter , where parameter is either <latest> or s3 backup dir_name <yy-mm-day-hour-min>"
              fi
              ;;

esac
