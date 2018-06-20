#!/bin/bash

local_domain=$(grep search /etc/resolv.conf | awk '{print $2}')
env=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-12-01" | grep -oE 'name[^,]+' | awk -F ':' '{print $2}' | sed 's/"//g' | awk -F '-' '{print $3}' | grep -oE '[a-z]+')

tmsh create ltm node app01 fqdn { name "f5-app-${env}01.${local_domain}" }
tmsh create ltm node app02 fqdn { name "f5-app-${env}02.${local_domain}" }

tmsh create ltm pool HTTP_3001
tmsh create ltm pool HTTP_3002
tmsh create ltm pool HTTP_4001
tmsh create ltm pool HTTP_4002

tmsh modify ltm pool HTTP_3001 members replace-all-with { app01:3001 app02:3001} monitor http load-balancing-mode least-connections-node
tmsh modify ltm pool HTTP_3002 members replace-all-with { app01:3002 app02:3002 { state user-down } } monitor http load-balancing-mode least-connections-node

tmsh modify ltm pool HTTP_4001 members replace-all-with { app01:4001 } monitor http 
tmsh modify ltm pool HTTP_4002 members replace-all-with { app01:4002 app02:4002} monitor http 

tmsh create ltm virtual HTTP_3001 source "0.0.0.0/0" destination "0.0.0.0:3001"
tmsh create ltm virtual HTTP_3002 source "0.0.0.0/0" destination "0.0.0.0:3002"
tmsh create ltm virtual HTTP_4001 source "0.0.0.0/0" destination "0.0.0.0:4001"
tmsh create ltm virtual HTTP_4002 source "0.0.0.0/0" destination "0.0.0.0:4002"

tmsh modify ltm virtual HTTP_3001 pool HTTP_3001
tmsh modify ltm virtual HTTP_3001 profiles replace-all-with { "http" }
tmsh modify ltm virtual HTTP_3001 source-address-translation { type "automap" }
tmsh modify ltm virtual HTTP_3001 translate-address "enabled"
tmsh modify ltm virtual HTTP_3001 persist replace-all-with { "cookie" }
tmsh modify ltm virtual HTTP_3001 security-log-profiles replace-all-with { "Log all requests" }

tmsh modify ltm virtual HTTP_3002 pool HTTP_3002
tmsh modify ltm virtual HTTP_3002 profiles replace-all-with { "http" }
tmsh modify ltm virtual HTTP_3002 source-address-translation { type "automap" }
tmsh modify ltm virtual HTTP_3002 persist replace-all-with { "cookie" }
tmsh modify ltm virtual HTTP_3002 security-log-profiles replace-all-with { "Log all requests" }

tmsh modify ltm virtual HTTP_4001 source-address-translation { type "automap" }
tmsh modify ltm virtual HTTP_4001 translate-address "enabled"

tmsh modify ltm virtual HTTP_4002 profiles replace-all-with { "http" }
tmsh modify ltm virtual HTTP_4002 source-address-translation { type "automap" }
tmsh modify ltm virtual HTTP_4002 translate-address "enabled"
tmsh modify ltm virtual HTTP_4002 persist replace-all-with { "cookie" }
tmsh modify ltm virtual HTTP_4002 security-log-profiles replace-all-with { "Log all requests" }


tmsh save sys config