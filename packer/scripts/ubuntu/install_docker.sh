#!/bin/bash -e

apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list
apt-get -y update
apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get install -y docker-engine 

# Ubuntu 16.04 package for docker-compose is 1.5.2 and we need at least 1.6 to
# work with docker-compose version 2 yaml config files.
curl -s -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

chmod 755 /usr/local/bin/docker-compose

# VPC provides a DNS server at 169.254.169.253
echo "DOCKER_OPTS=\"--dns 169.254.169.253\"" >> /etc/default/docker
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/docker.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon --dns 169.254.169.253
EOF
systemctl daemon-reload
systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu
usermod -aG docker amazon
