#!/bin/sh

# Install Docker
yum remove docker docker-common docker-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum makecache fast
yum install docker-ce

systemctl start docker.service
systemctl enable docker.service

# Install Docker Compose
yum install epel-release
yum install -y python-pip
pip install docker-compose
yum upgrade python*
docker-compose version
