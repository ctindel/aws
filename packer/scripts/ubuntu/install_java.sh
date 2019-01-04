#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

# Auto accept the oracle jdk licenses
yes '' | sudo add-apt-repository -y ppa:webupd8team/java
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get -y update
apt-get install -y oracle-java8-installer oracle-java8-set-default maven
