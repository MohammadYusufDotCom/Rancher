# Rancher HA Installation

https://docs.k3s.io/blog/2025/03/10/simple-ha
```
############################ ha configuration ##################
on machine 1 

yum install haproxy -y 

systemctl restart  haproxy
systemctl status  haproxy

cd /etc/haproxy
mv haproxy.cfg haproxy.cfg-org
vim /etc/haproxy/haproxy.cfg


#/etc/haproxy/haproxy.cfg
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
```

```
################### MySQL Using Docker compose ###########

yum install telnet -y 
yum install docker -y
systemctl restart docker 

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version
 

mkdir -p /mysql/data

cat <<EOF > docker-compose.yml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    container_name: rancher-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: admin@123
      MYSQL_DATABASE: rancher
      MYSQL_USER: rancher
      MYSQL_PASSWORD: rancher123
    ports:
      - "3306:3306"
    volumes:
      - /mysql/data:/var/lib/mysql
    command: --default-authentication-plugin=mysql_native_password
EOF

docker-compose up -d 

```




### install k3s
https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/k3s-for-rancher#1-install-kubernetes-and-set-up-the-k3s-server

```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=enX0" K3S_DATASTORE_ENDPOINT="mysql://rancher:rancher123@tcp(172.31.31.29:3306)/rancher" | sh - 


#############    Working and update version of above (for first node)

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=enX0 --advertise-address=10.0.1.106" K3S_DATASTORE_ENDPOINT="mysql://rancher:rancher123@tcp($(hostname -I | awk '{print $1}'))/rancher" sh -

cat /var/lib/rancher/k3s/server/token
```




### Download the latest kubectl binary (option and need to run when on other node)
```
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
```


### join other node
```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=enX0" K3S_DATASTORE_ENDPOINT="mysql://rancher:rancher123@tcp(172.31.31.29:3306)/rancher" sh - 


curl -sfL https://get.k3s.io |INSTALL_K3S_EXEC="--flannel-iface=enX0" K3S_DATASTORE_ENDPOINT="mysql://rancher:rancher123@tcp(10.0.1.54:3306)/rancher" sh -s - --server https://10.0.1.106:6443 --token 'K108b2da8d698ba3b10bdd8b264b185350f315a325f85648d600dc0d1d296486de5::server:a00e312a33a8ad86a6840abb70c0b2c5'
```


### Uninstall
```
/usr/local/bin/k3s-uninstall.sh
rm -f /usr/local/bin/k3s-uninstall.sh

rm -rf /usr/local/bin/k3s-uninstall.sh
rm -rf /var/lib/rancher/
rm -rf /etc/rancher/
```



### after installation 
```
mkdir ~/.kube/config

cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

vim  ~/.kube/config

chmod 755 ~/.kube/config


wget https://get.helm.sh/helm-v3.18.4-linux-amd64.tar.gz
tar -xvzf helm-v3.18.4-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
chmod 755 /usr/local/bin/helm
```

### install cert manager

https://cert-manager.io/docs/installation/helm/
https://www.youtube.com/watch?v=APsZJbnluXg

```

helm repo add jetstack https://charts.jetstack.io --force-update


helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.18.2 \
  --set crds.enabled=true
```


### Insatall Rancher 

```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable --force-update

helm install rancher rancher-stable/rancher --version 2.11.3 --set hostname=poc.rancher.yusuf --namespace cattle-system --create-namespace
```
 we do not have to specify --set hostname=poc.rancher.yusuf if we specify this then we can only access this using the passed hostname this is mentioned in the ingress of the rancher  below are the command for this 

```
kubectl get ingress -n cattle-system -o wide

kubectl edit ingress -n cattle-system -o yaml
```


### Load balancer rafrance guide for rancher with Nginx
```
[rancher document Link](https://shorturl.at/6HvoJ)
```
