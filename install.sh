yum -y install mysql npm nodejs

get_ip() {

}

mysql < db.sql

node server.js $ip1 3001 &
disown
node server.js $ip2 3002 &
disown

node server.js $ip1 4001 &
disown
node server.js $ip2 4002 &
disown



