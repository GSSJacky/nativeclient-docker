#!/bin/bash

mkdir -p /opt/pivotal/data
mkdir -p /opt/pivotal/data/$HOSTNAME

gfsh start server --name=$HOSTNAME --locators=locator[10334] --mcast-port=0 --dir=/opt/pivotal/data/$HOSTNAME/ --cache-xml-file=/opt/pivotal/scripts/cache.xml "$@" --include-system-classpath=true --statistic-archive-file=cacheserver.gfs

while true; do
    sleep 10
  done
done
