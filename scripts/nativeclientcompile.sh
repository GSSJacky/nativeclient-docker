#!/bin/bash

#create a work folder for native client's compilation
mkdir -p /opt/pivotal/NCWork
cd /opt/pivotal/NCWork

#configure the build
cmake $GFCPP/SampleCode/quickstart/cpp
cmake --build .
