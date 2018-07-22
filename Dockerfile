# LICENSE GPL 2.0
#Set the base image :
FROM ubuntu:14.04


#File Author/Maintainer :
MAINTAINER GemfireGSS <xxxxxxxxx@gmail.com>

###################
# for example: 
# http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz
# --》
# "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/$JDK_HASH_VALUE/jdk-$JAVA_VERSION-linux-x64.tar.gz"
###################
ENV JAVA_VERSION 8u181
ENV BUILD_VERSION b13
ENV JAVA_SUB_VERSION 181
ENV JDK_HASH_VALUE 96a7b8442fe848ef90c96a2fad6ed6d1

##################
# Gemfire version
##################
ENV GEMFIREVERSION 9.2.0

#Set workdir :
WORKDIR /opt/pivotal

RUN apt-get update && apt-get install -y wget

#Obtain/download Java SE Development Kit 8u172 using wget :
RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/$JDK_HASH_VALUE/jdk-$JAVA_VERSION-linux-x64.tar.gz"

#Set permissions to gemfire directory to perform operations :
RUN chmod 777 /opt/pivotal

#Setup jdk1.8.x_xx and create softlink :
RUN gunzip jdk-$JAVA_VERSION-linux-x64.tar.gz
RUN tar -xvf jdk-$JAVA_VERSION-linux-x64.tar
RUN ln -s jdk1.8.0_$JAVA_SUB_VERSION current_java
RUN rm jdk-$JAVA_VERSION-linux-x64.tar

#setup unzip 
RUN apt-get update
RUN apt-get install -y unzip zip


#Add gemfire installation file
ADD ./gemfireproductlist/pivotal-gemfire-$GEMFIREVERSION.zip /opt/pivotal/

#Set the username to root :
USER root

#Install pivotal gemfire :
RUN unzip pivotal-gemfire-$GEMFIREVERSION.zip && \
    rm pivotal-gemfire-$GEMFIREVERSION.zip

#Setup environment variables :
ENV JAVA_HOME /opt/pivotal/current_java
ENV PATH $PATH:/opt/pivotal/current_java:/opt/pivotal/current_java/bin:/opt/pivotal/pivotal-gemfire-$GEMFIREVERSION/bin
ENV GEMFIRE /opt/pivotal/pivotal-gemfire-$GEMFIREVERSION
ENV GF_JAVA /opt/pivotal/current_java/bin/java

#classpath setting
ENV CLASSPATH $GEMFIRE/lib/geode-dependencies.jar:$GEMFIRE/lib/gfsh-dependencies.jar:/opt/pivotal/workdir/classes:$CLASSPATH

#COPY the scripts into container
COPY scripts /opt/pivotal/scripts

#This trustore file is for PCC lab21
#COPY lab21.truststore lab21.truststore

# Default ports:
# RMI/JMX 1099
# REST 8080
# PULSE 7070
# LOCATOR 10334
# CACHESERVER 40404
# UDP port: 53160
EXPOSE  8080 10334 40404 40405 1099 7070

# SET VOLUME directory
# VOLUME ["/opt/pivotal/workdir/storage"]


########################
# native client part
########################
ENV NCVERSION 9.2.0
ENV GFCPP /opt/pivotal/pivotal-gemfire-native
ENV GEODE /opt/pivotal/pivotal-gemfire-native
ENV PATH $PATH:$GFCPP/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$GFCPP/lib

# GCC support
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test

# Install packages

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  g++-4.9 \
  gcc-4.9 \
  git \
  libpam0g-dev \
  libssl-dev \
  make
  
# Set up gcc/g++
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9

RUN cd /usr/local/src \ 
    && wget https://cmake.org/files/v3.4/cmake-3.4.3.tar.gz \
    && tar xvf cmake-3.4.3.tar.gz \ 
    && cd cmake-3.4.3 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*

# native client installation
ADD ./gemfireproductlist/pivotal-gemfire-native-$NCVERSION-build.10-Linux-64bit.tar.gz /opt/pivotal/

#RUN gunzip pivotal-gemfire-native-$NCVERSION-build.10-Linux-64bit.tar.gz
#RUN tar -xvf pivotal-gemfire-native-$NCVERSION-build.10-Linux-64bit.tar
#RUN rm pivotal-gemfire-native-$NCVERSION-build.10-Linux-64bit.tar

# compile native client c++ quickstart samples
COPY CMakeLists.txt /opt/pivotal/pivotal-gemfire-native/SampleCode/quickstart/cpp/CMakeLists.txt
COPY BasicOperations.cpp /opt/pivotal/pivotal-gemfire-native/SampleCode/quickstart/cpp/BasicOperations.cpp
RUN chmod a+x /opt/pivotal/scripts/nativeclientcompile.sh
RUN /opt/pivotal/scripts/nativeclientcompile.sh
