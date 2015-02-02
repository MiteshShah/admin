#!/bin/bash
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# Copyright (C) 2015 by Mitesh Shah (Mr.Miteshah@gmail.com)

ELASTICSEARCH_VERSION=1.4
LOGSTASH_VERSION=1.4
KIBANA_VERSION=3.1.2
ES_CLUSTER_NAME=DEV-ES
ES_NODE_NAME=DEV-NODE

echo "Install EPEL repository, please wait..."
yum -y install epel-release

echo "Installing syslog-ng, please wait..."
yum -y install syslog-ng syslog-ng-libdbi

echo "Execute: service rsyslog stop"
service rsyslog stop
chkconfig rsyslog off

#echo "Execute: service syslog-ng start"
#service syslog-ng start

echo "Fetching Elasticsearch GPGkey, please wait..."
rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch

echo "Adding Elasticsearch repository, please wait..."
echo "[elasticsearch]" > /etc/yum.repos.d/elk.repo
echo "name=Elasticsearch repository" >> /etc/yum.repos.d/elk.repo
echo "baseurl=http://packages.elasticsearch.org/elasticsearch/$ELASTICSEARCH_VERSION/centos" >> /etc/yum.repos.d/elk.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/elk.repo
echo "gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/elk.repo
echo "enabled=1" >> /etc/yum.repos.d/elk.repo

echo "Adding Logstash repository, please wait..."
echo "[logstash]" >> /etc/yum.repos.d/elk.repo
echo "name=logstash repository" >> /etc/yum.repos.d/elk.repo
echo "baseurl=http://packages.elasticsearch.org/logstash/$LOGSTASH_VERSION/centos" >> /etc/yum.repos.d/elk.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/elk.repo
echo "gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/elk.repo
echo "enabled=1" >> /etc/yum.repos.d/elk.repo

echo "Adding NGINX repository, please wait..."
echo "[nginx]" > /etc/yum.repos.d/nginx.repo
echo "name=NGINX" >> /etc/yum.repos.d/nginx.repo
echo "baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/" >> /etc/yum.repos.d/nginx.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/nginx.repo
echo "enabled=1" >> /etc/yum.repos.d/nginx.repo

echo "Installing Elasticsearch, Logstash, Kibara and NGINX, please wait..."
yum -y install elasticsearch logstash logstash-contrib nginx

echo "Install/Setup Kibana, please wait..."
cd /usr/share/nginx/html/
wget -qc https://download.elasticsearch.org/kibana/kibana/kibana-$KIBANA_VERSION.tar.gz
tar -zxf /usr/share/nginx/html/kibana-$KIBANA_VERSION.tar.gz
mv kibana-$KIBANA_VERSION /usr/share/nginx/html/kibana
rm -f kibana-$KIBANA_VERSION.tar.gz

# Configure Elasticsearch
echo "Configuring Elasticsearch, please wait..."
sed -i "s/#cluster.name.*/cluster.name: $ES_CLUSTER_NAME/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/#node.name.*/node.name: $ES_NODE_NAME/" /etc/elasticsearch/elasticsearch.yml

sed -i "s/#index.number_of_shards: 1/index.number_of_shards: 1/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/#index.number_of_replicas: 0/index.number_of_replicas: 0/" /etc/elasticsearch/elasticsearch.yml

echo "Installing Marvel plugin, please wait..."
cd /usr/share/elasticsearch/
bin/plugin -i elasticsearch/marvel/latest

# Disable auto create index and dynamic scripts
grep "action.auto_create_index" elasticsearch.yml &> /dev/null
if [ $? -ne 0 ]; then
  echo "action.auto_create_index: false" >> /etc/elasticsearch/elasticsearch.yml
  echo "index.mapper.dynamic: false" >> /etc/elasticsearch/elasticsearch.yml
  echo "script.disable_dynamic: true" >> /etc/elasticsearch/elasticsearch.yml
  echo 'http.cors.allow-origin: "/.*/"' >> /etc/elasticsearch/elasticsearch.yml
  echo 'http.cors.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
fi

# Restart Elasticsearch
service elasticsearch restart
nginx -t && service nginx restart
