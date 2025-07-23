#!/bin/bash
sudo yum install haproxy -y 

sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-org
sudo cat <<EOF > /etc/haproxy/haproxy.cfg
frontend k3s
    bind *:6443
    mode tcp
    default_backend k3s

backend k3s
    mode tcp
    option tcp-check
    balance roundrobin
    server server-0 10.0.1.157:6443 check
    server server-1 10.0.1.252:6443 check
EOF

sudo  systemctl start haproxy
sudo  systemctl restart haproxy

curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl



wget https://get.helm.sh/helm-v3.18.4-linux-amd64.tar.gz
tar -xvzf helm-v3.18.4-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
chmod 755 /usr/local/bin/helm
