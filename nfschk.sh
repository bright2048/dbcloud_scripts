#!/bin/bash
#检查nfs是否正常挂载,如果失败则自动挂载
#!/bin/bash
NFSIP=`grep nfs /etc/fstab |grep ^#|awk -F: '{print $1}'`
NFS_SRC=`grep nfs /etc/fstab |grep ^#|awk  '{print $1}'`
NFS_DEST=`grep nfs /etc/fstab |grep ^#|awk  '{print $2}'`
while true
do
    if [ -z "$NFSIP" ]
    then
	   exit 0
    else
        MOUNT_FLAG=`mount |grep ${NFSIP}|wc -l`
		if [ ${MOUNT_FLAG} -ne 1 ]
		then
		    echo "nfs umounted , try to mount again"
		    mount $NFS_SRC $NFS_DEST 
		    [ $? -ne 0 ] && echo "mount nfs server error, check network"
		else
		    echo "nfs mount is healthy!"
		fi
        sleep 10s
    fi
done

#对应的supervisor配置:
cd /etc/supervisor*/conf.d/
cat >nfschk.conf <<EOF
[program:nfschk]
command =bash /root/agent/sh/nfschk.sh
autostart = true
autorestart = true
user = root
EOF
