#!/bin/bash
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# Copyright (C) 2012 by Mitesh Shah (Mr.Miteshah@gmail.com)

ELASTICSEARCH_VERSION=1.4
LOGSTASH_VERSION=1.4
KIBANA_VERSION=3.1.2

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
echo "baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/" >> /etc/yum.repos.d/nginx.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/nginx.repo
echo "enabled=1" >> /etc/yum.repos.d/nginx.repo

echo "Installing Elasticsearch, Logstash, Kibara and NGINX, please wait..."
yum -y install elasticsearch logstash nginx

echo "Install/Setup Kibana, please wait..."
wget -qcO /tmp/kibana.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-$KIBANA_VERSION.tar.gz
tar -zxf /tmp/kibana.tar.gz
mv kibana-3.1.2 /usr/share/nginx/html/kibana
