workdir=/root/vncc/docker_recover/
mkdir -p $workdir

文件名:active_docker_mon.sh
cat >$workdir/active_docker_mon.sh<<"EOF"
#!/bin/bash
path=$(dirname $0)
while true
do
docker ps -q > $path/doclist.tmp
sleep 300s
done
EOF

#对应的supervisor的配置
cat >/etc/supervisor/conf.d/dockmon.conf<<"EOF"
[program:dockmon]
command =bash /root/vncc/docker_recover/active_docker_mon.sh
autostart = true
autorestart = true
user = root
EOF

主机启动
/root/vncc/docker_recover/docker_recover.sh

cat >$workdir/docker_recover.sh<<"EOF"
#!/bin/bash
path=$(dirname $0)
while read line
do
docker start $line 
docker exec $line bash -c "service ssh restart"
docker exec $line bash -c "nohup /etc/vncc/vncc -c /etc/vncc/vncc.conf &"
done < ${path}/doclist.tmp
EOF

chmod +x /root/vncc/docker_recover/docker_recover.sh


cat >/etc/rc.local<<EOF
#!/bin/bash
bash /root/vncc/docker_recover/docker_recover.sh
exit 0
EOF


supervisorctl reload
supervisorctl status
