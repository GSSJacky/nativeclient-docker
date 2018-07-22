# nativeclient-docker

# prerequisite

1.You need to download a gemfire 9.2.0 installer(zip version) and native client 9.2.0 from pivotal network, then put this zip file under `gemfireproductlist` folder.
`pivotal-gemfire-9.2.0.zip`
`pivotal-gemfire-native-9.2.0-build.10-Linux-64bit.tar.gz`

Download URL:
https://network.pivotal.io/products/pivotal-gemfire#/releases/8052
https://network.pivotal.io/products/pivotal-gemfire#/releases/51551/file_groups/869

2.Tested with `Docker Community Edition for Mac 18.05.0-ce-mac66`

https://docs.docker.com/docker-for-mac/install/

# Building the container image
The current Dockerfile is based on a ubuntu:14.04 image + JDK8u181 + Gemfire9.2.0 + NativeClient9.2.0

Run the below command to compile the dockerfile to build the image:
```
docker build . -t nativeclient92:0.1
```

```
XXXXXnoMacBook-puro:gemfire9X user1$ docker build . -t nativeclient92:0.1
Sending build context to Docker daemon   25.6kB
Step 1/43 : FROM ubuntu:14.04
 ---> 971bb384a50a
Step 2/43 : MAINTAINER GemfireGSS <xxxxxxxxx@gmail.com>
 ---> Using cache
 ---> f9e8e1ede28a
Step 3/43 : ENV JAVA_VERSION 8u181
 ---> Running in f143666810a6
Removing intermediate container f143666810a6
 ---> 46fc3dcbdc1a
Step 4/43 : ENV BUILD_VERSION b13
 ---> Running in 3a03459ea436
Removing intermediate container 3a03459ea436
 ---> bc9acebf821f
Step 5/43 : ENV JAVA_SUB_VERSION 181
 ---> Running in 5cbe2998911b
Removing intermediate container 5cbe2998911b
 ---> e6f260b6544a
Step 6/43 : ENV JDK_HASH_VALUE 96a7b8442fe848ef90c96a2fad6ed6d1
 ---> Running in f8f62ab5c014
Removing intermediate container f8f62ab5c014
 ---> 0fcdbe07bd44
Step 7/43 : ENV GEMFIREVERSION 9.2.0
 ---> Running in ab4a4e0c3cdd
..............
[ 86%] Linking CXX executable RegisterInterest
[ 86%] Built target RegisterInterest
Scanning dependencies of target RemoteQuery
[ 88%] Building CXX object CMakeFiles/RemoteQuery.dir/RemoteQuery.cpp.o
[ 89%] Building CXX object CMakeFiles/RemoteQuery.dir/queryobjects/Portfolio.cpp.o
[ 91%] Building CXX object CMakeFiles/RemoteQuery.dir/queryobjects/Position.cpp.o
[ 93%] Linking CXX executable RemoteQuery
[ 93%] Built target RemoteQuery
Scanning dependencies of target Transactions
[ 94%] Building CXX object CMakeFiles/Transactions.dir/Transactions.cpp.o
[ 96%] Linking CXX executable Transactions
[ 96%] Built target Transactions
Scanning dependencies of target TransactionsXA
[ 98%] Building CXX object CMakeFiles/TransactionsXA.dir/TransactionsXA.cpp.o
[100%] Linking CXX executable TransactionsXA
[100%] Built target TransactionsXA
Removing intermediate container 8542e92e0345
 ---> 62e22f5bae8c
Successfully built 62e22f5bae8c
Successfully tagged nativeclient92:0.1
```

# Login into container

Run the below command to run the container instance(you need to modify the volume directory according to your machine's path):
```
docker run -it nativeclient92:0.1 bash
```

# Start a locator and a cacheserver from container. Create a partition region: exampleRegion.
```
root@3facc296b49f:/opt/pivotal# gfsh
    _________________________     __
   / _____/ ______/ ______/ /____/ /
  / /  __/ /___  /_____  / _____  / 
 / /__/ / ____/  _____/ / /    / /  
/______/_/      /______/_/    /_/    9.2.0

Monitor and Manage Pivotal GemFire
gfsh>start locator
Starting a Geode Locator in /opt/pivotal/walk-lively-dust...
..............
Locator in /opt/pivotal/walk-lively-dust on 3facc296b49f[10334] as walk-lively-dust is currently online.
Process ID: 73
Uptime: 14 seconds
Geode Version: 9.2.0
Java Version: 1.8.0_181
Log File: /opt/pivotal/walk-lively-dust/walk-lively-dust.log
JVM Arguments: -Dgemfire.enable-cluster-configuration=true -Dgemfire.load-cluster-configuration-from-dir=false -Dgemfire.launcher.registerSignalHandlers=true -Djava.awt.headless=true -Dsun.rmi.dgc.server.gcInterval=9223372036854775806
Class-Path: /opt/pivotal/pivotal-gemfire-9.2.0/lib/geode-core-9.2.0.jar:/opt/pivotal/pivotal-gemfire-9.2.0/lib/geode-dependencies.jar

Successfully connected to: JMX Manager [host=3facc296b49f, port=1099]

Cluster configuration service is up and running.
```

```
gfsh>start server --locators=localhost[10334]
Starting a Geode Server in /opt/pivotal/escape-wrong-pet...
..............
Server in /opt/pivotal/escape-wrong-pet on 3facc296b49f[40404] as escape-wrong-pet is currently online.
Process ID: 199
Uptime: 15 seconds
Geode Version: 9.2.0
Java Version: 1.8.0_181
Log File: /opt/pivotal/escape-wrong-pet/escape-wrong-pet.log
JVM Arguments: -Dgemfire.locators=localhost[10334] -Dgemfire.start-dev-rest-api=false -Dgemfire.use-cluster-configuration=true -XX:OnOutOfMemoryError=kill -KILL %p -Dgemfire.launcher.registerSignalHandlers=true -Djava.awt.headless=true -Dsun.rmi.dgc.server.gcInterval=9223372036854775806
Class-Path: /opt/pivotal/pivotal-gemfire-9.2.0/lib/geode-core-9.2.0.jar:/opt/pivotal/pivotal-gemfire-9.2.0/lib/geode-dependencies.jar
gfsh>list members
      Name       | Id
---------------- | ----------------------------------------------------
walk-lively-dust | 172.17.0.2(walk-lively-dust:73:locator)<ec><v0>:1024
escape-wrong-pet | 172.17.0.2(escape-wrong-pet:199)<v1>:1025

gfsh>create region --name=exampleRegion --type=PARTITION
     Member      | Status
---------------- | -----------------------------------------------------
escape-wrong-pet | Region "/exampleRegion" created on "escape-wrong-pet"

gfsh>exit
```

# Switch to NCWork folder which has the compiled quickstart samples. Run the BasicOperations sample and do some operations to exampleRegion.

```
root@3facc296b49f:/opt/pivotal# cd /opt/pivotal/NCWork
root@3facc296b49f:/opt/pivotal/NCWork# ./BasicOperations 
[config 2018/07/22 08:25:42.208363 UTC 3facc296b49f:347 139873689532288] Using Geode Native Client Product Directory: /opt/pivotal/pivotal-gemfire-native
[config 2018/07/22 08:25:42.211925 UTC 3facc296b49f:347 139873689532288] Product version: Pivotal Gemfire Native 9.2.0-build.10 (64bit) Wed, 24 Jan 2018 10:53:51 -0800
[config 2018/07/22 08:25:42.212781 UTC 3facc296b49f:347 139873689532288] Source revision: c6fee485fd81691d4e2991a6d857cb9c5cd823e6
[config 2018/07/22 08:25:42.212807 UTC 3facc296b49f:347 139873689532288] Source repository: 
[config 2018/07/22 08:25:42.212830 UTC 3facc296b49f:347 139873689532288] Running on: SystemName=Linux Machine=x86_64 Host=3facc296b49f Release=4.9.87-linuxkit-aufs Version=#1 SMP Fri Mar 16 18:16:33 UTC 2018
[config 2018/07/22 08:25:42.213485 UTC 3facc296b49f:347 139873689532288] Current directory: /opt/pivotal/NCWork
[config 2018/07/22 08:25:42.214214 UTC 3facc296b49f:347 139873689532288] Current value of PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/pivotal/current_java:/opt/pivotal/current_java/bin:/opt/pivotal/pivotal-gemfire-9.2.0/bin:/opt/pivotal/pivotal-gemfire-native/bin
[config 2018/07/22 08:25:42.214708 UTC 3facc296b49f:347 139873689532288] Current library path: :/opt/pivotal/pivotal-gemfire-native/lib
[config 2018/07/22 08:25:42.215840 UTC 3facc296b49f:347 139873689532288] Geode Native Client System Properties:
  appdomain-enabled = false
  archive-disk-space-limit = 0
  archive-file-size-limit = 0
  auto-ready-for-events = true
  bucket-wait-timeout = 0
  cache-xml-file = 
  conflate-events = server
  connect-timeout = 59
  connection-pool-size = 5
  connect-wait-timeout = 0
  crash-dump-enabled = true
  disable-chunk-handler-thread = false
  disable-shuffling-of-endpoints = false
  durable-client-id = 
  durable-timeout = 300
  enable-time-statistics = false
  grid-client = false
  heap-lru-delta = 10
  heap-lru-limit = 0
  log-disk-space-limit = 0
  log-file = 
  log-file-size-limit = 0
  log-level = config
  max-fe-threads = 4
  max-socket-buffer-size = 66560
  notify-ack-interval = 1
  notify-dupcheck-life = 300
  on-client-disconnect-clear-pdxType-Ids = false
  ping-interval = 10
  read-timeout-unit-in-millis = false
  redundancy-monitor-interval = 10
  security-client-auth-factory = 
  security-client-auth-library = 
  security-client-dhalgo = 
  security-client-kspath = 
  ssl-enabled = false
  ssl-keystore = 
  ssl-truststore = 
  stacktrace-enabled = false
  statistic-archive-file = statArchive.gfs
  statistic-sampling-enabled = true
  statistic-sample-rate = 1
  suspended-tx-timeout = 30
  tombstone-timeout = 480000
[config 2018/07/22 08:25:42.290361 UTC 3facc296b49f:347 139873689532288] Starting the Geode Native Client
[info 2018/07/22 08:25:42.291459 UTC 3facc296b49f:347 139873689532288] Using GFNative_drXDUta4TQ347 as random data for ClientProxyMembershipID
[info 2018/07/22 08:25:42.296991 UTC 3facc296b49f:347 139873689532288] Created the Geode Cache
[info 2018/07/22 08:25:42.297079 UTC 3facc296b49f:347 139873689532288] Created the RegionFactory
[info 2018/07/22 08:25:42.350703 UTC 3facc296b49f:347 139873689532288] Set default pool with localhost:40404
[info 2018/07/22 08:25:42.350977 UTC 3facc296b49f:347 139873689532288] Creating region exampleRegion attached to pool default_geodeClientPool
[info 2018/07/22 08:25:42.351769 UTC 3facc296b49f:347 139873260402432] ClientMetadataService started for pool default_geodeClientPool
[info 2018/07/22 08:25:42.353158 UTC 3facc296b49f:347 139873689532288] Created the Region Programmatically.
[info 2018/07/22 08:25:42.353539 UTC 3facc296b49f:347 139873260402432] Using socket send buffer size of 64240.
[info 2018/07/22 08:25:42.353599 UTC 3facc296b49f:347 139873260402432] Using socket receive buffer size of 64240.
[info 2018/07/22 08:25:42.537463 UTC 3facc296b49f:347 139873689532288] Put the first Entry into the Region
[info 2018/07/22 08:25:42.556413 UTC 3facc296b49f:347 139873689532288] Put the second Entry into the Region
[info 2018/07/22 08:25:42.556761 UTC 3facc296b49f:347 139873689532288] Obtained the first Entry from the Region
[info 2018/07/22 08:25:42.558912 UTC 3facc296b49f:347 139873689532288] Obtained the second Entry from the Region
[info 2018/07/22 08:25:42.568620 UTC 3facc296b49f:347 139873689532288] Invalidated the first Entry in the Region
[info 2018/07/22 08:25:42.625337 UTC 3facc296b49f:347 139873689532288] Destroyed the second Entry in the Region
[info 2018/07/22 08:25:42.630722 UTC 3facc296b49f:347 139873260402432] ClientMetadataService stopped for pool default_geodeClientPool
[config 2018/07/22 08:25:42.734318 UTC 3facc296b49f:347 139873689532288] Stopped the Geode Native Client
[info 2018/07/22 08:25:42.734381 UTC 3facc296b49f:347 139873689532288] Closed the Geode Cache
```


```
root@3facc296b49f:/opt/pivotal/NCWork# gfsh
    _________________________     __
   / _____/ ______/ ______/ /____/ /
  / /  __/ /___  /_____  / _____  / 
 / /__/ / ____/  _____/ / /    / /  
/______/_/      /______/_/    /_/    9.2.0

Monitor and Manage Pivotal GemFire
gfsh>connect --locator=localhost[10334]
Connecting to Locator at [host=localhost, port=10334] ..
Connecting to Manager at [host=3facc296b49f, port=1099] ..
Successfully connected to: [host=3facc296b49f, port=1099]

gfsh>describe region --name=/exampleRegion
..........................................................
Name            : exampleRegion
Data Policy     : partition
Hosting Members : escape-wrong-pet

Non-Default Attributes Shared By Hosting Members  

 Type  |    Name     | Value
------ | ----------- | ---------
Region | size        | 1
       | data-policy | PARTITION
gfsh>show metrics

Cluster-wide Metrics

Category  |        Metric         | Value
--------- | --------------------- | -----
cluster   | totalHeapSize         | 888
cache     | totalRegionEntryCount | 1
          | totalRegionCount      | 1
          | totalMissCount        | 5
          | totalHitCount         | 3
diskstore | totalDiskUsage        | 0
          | diskReadsRate         | 0
          | diskWritesRate        | 0
          | flushTimeAvgLatency   | 0
          | totalBackupInProgress | 0
query     | activeCQCount         | 0
          | queryRequestRate      | 0
```
