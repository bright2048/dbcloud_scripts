#!/bin/bash
path=$(dirname $0)
while true
do
count=`ps -ef|grep vncs.ini|grep -v grep|wc -l`
if [ $count -eq 0 ]
then
    ${path}/vncs -c ${path}/vncs.ini >/dev/null 2>&1
fi
sleep 60s
done


#对应的supervisor的配置
[program:vncs]
command =bash /root/vncc/vncs.sh
autostart = true
autorestart = true
user = root
