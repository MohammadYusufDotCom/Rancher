#!/bin/bash

sudo yum install telnet -y
sudo yum install docker -y
sudo systemctl restart docker 
sudo  curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sudo mkdir -p /mysql/data
sudo cat <<EOF > ~/docker-compose.yml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    container_name: rancher-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rancher
      MYSQL_DATABASE: rancher
      MYSQL_USER: rancher
      MYSQL_PASSWORD: rancher123
    ports:
      - "3306:3306"
    volumes:
      - /mysql/data:/var/lib/mysql
    command: --default-authentication-plugin=mysql_native_password
EOF

sudo docker-compose up -d 

# sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=enX0 --advertise-address=10.0.1.198" K3S_DATASTORE_ENDPOINT="mysql://rancher:rancher123@tcp($(hostname -I | awk '{print $1}'))/rancher" sh -
