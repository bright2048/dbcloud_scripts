#!/bin/sh
#demo: add2admin.sh test 210.16.188.193 20222 20277 fengrui
NODE_NAME=$1
NODE_IP=$2
SSH_PORT=$3
API_PORT=$4
LAB=$5
curl -H "Content-Type:application/x-www-form-urlencoded" -X POST -d "NODE_NAME=$NODE_NAME&IP=$NODE_IP&SSH_PORT=$SSH_PORT&API_PORT=$API_PORT&ADMIN_USER=admin&ADMIN_PASSWD=123456&NOTE=&NOTE2=&NOTE3=&ACTION=new" "http://101.226.241.19:30081/node/$LAB/pserver_node.php"
