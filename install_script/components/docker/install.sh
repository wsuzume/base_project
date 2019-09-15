#!/bin/sh

# Install Docker
sudo yum remove docker docker-common docker-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum makecache fast
sudo yum install docker-ce

sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo docker run hello-world

# Install Docker Compose
sudo yum install epel-release
sudo yum install -y python-pip
sudo pip install docker-compose
sudo yum upgrade python*
docker-compose version
