#!/bin/bash
path=$(dirname $0)
while true
do
count=`ps -ef|grep /root/vncc/vncc.conf|grep -v grep|wc -l`
if [ $count -eq 0 ]
then
    ${path}/vncc -c ${path}/vncc.conf >/dev/null 2>&1
fi
sleep 60s
done


#对应的supervisor的配置
[program:vncc]
command =bash /root/vncc/vncc.sh
autostart = true
autorestart = true
user = root
