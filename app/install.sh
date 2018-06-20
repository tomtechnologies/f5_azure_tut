#!/bin/bash
yum -y install gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -
yum -y install mysql npm nodejs jq mariadb-server server

get_ip() {
    ip_list=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/network?api-version=2017-08-01" | grep -oE 'privateIpAddress[^,]+'  | awk -F ':' '{print $2}' | sed 's/\"//g')

    echo $ip_list
}

ips=$(get_ip)
ip1=$(echo $ips | awk '{print $1}')
ip2=$(echo $ips | awk '{print $2}')

service maridb start
npm i

mysql < db.sql

for ip in $ip1 $ip2
do
    for p in 3001 3002 4001 4002
    do
        node server.js $ip $p &
        disown
    done
done
