#!/bin/bash
yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -
yum -y install mysql npm nodejs jq mariadb-server server

get_ip() {
    ip_list=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network?api-version=2017-08-01" | grep 'privateIpAddress' |awk '{print $2}' | sed -e 's/\"//g' -e 's/,//g')

    echo $ip_list
}

ips=$(get_ip)
ip1=$(echo $ips | awk '{print $1}')
ip2=$(echo $ips | awk '{print $2}')

service maridb start

mysql < db.sql

node server.js $ip1 3001 &
disown
node server.js $ip2 3002 &
disown

node server.js $ip1 4001 &
disown
node server.js $ip2 4002 &
disown



