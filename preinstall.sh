#!/bin/sh
###############################################################################################
#
#Copyright (C) 2020 The DBCloud Company
#Version: v3.0
#2020-06-12
#1.add python3-pip gpustat installation
#2.disable the standard output of apt install
###############################################################################################

gwip=$1
name=$2
wget -O /etc/apt/sources.list http://www.youmijack.com/vxgateway/src/sources.list
apt-get update -y
echo -e "\nInstall essential pkg..."
apt-get -y install curl openssh-server qt5-default supervisor expect htop fail2ban arp-scan python3-pip  1>/dev/null
pip3 install gpustat
echo -e "\nInstallation done."
echo -e "\nHardening the GPU node..."
bash -c "sed -i '/UsePAM yes/s/yes/no/g' /etc/ssh/sshd_config"
bash -c "sed -i 's/#Port/Port/g'  /etc/ssh/sshd_config"
bash -c "sed -i '/Port 22/s/22/15654/g' /etc/ssh/sshd_config"
bash -c "sed -i '/PermitRootLogin prohibit-password/s/prohibit-password/yes/g' /etc/ssh/sshd_config"
#产生随机root密码并更改
ROOT_PWD=$( < /dev/urandom tr -dc 'A-Za-z0-9' | head -c10; echo)
bash -c "echo 'root:$ROOT_PWD' |chpasswd"
echo "$ROOT_PWD" > ~/root_token.dat

#插入环境文件，登陆成功即打印token
grep root_token ~/.bashrc &> /dev/null
[ $? -ne 0 ] && cat >>.bashrc<<EOF
echo "\`date +%F\`:\`cat ~/root_token.dat\`"
EOF


cd /root/
mkdir agent
mkdir vncc
mkdir /etc/docker/certs.d/registry.youmijack.com:8088/
wget -O /root/agent/vxagent http://www.youmijack.com/vxgateway/vxagent/vxagent
wget -O /root/agent/updateagent.sh http://www.youmijack.com/vxgateway/vxagent/updateagent.sh
wget -O /root/agent/id_rsa.pub http://www.youmijack.com/vxgateway/vxagent/id_rsa.pub
wget -O /root/vncc/vncc http://www.youmijack.com/vxgateway/vncc/vncc
wget -O /root/vncc/vncc.sh http://www.youmijack.com/vxgateway/vncc/vncc.sh
wget -O /etc/supervisor/conf.d/vncc.conf http://www.youmijack.com/vxgateway/src/vncc.conf
wget -O /etc/supervisor/conf.d/vxagent.conf http://www.youmijack.com/vxgateway/src/vxagent.conf
wget -O /etc/docker/certs.d/registry.youmijack.com:8088/ca.pem http://www.youmijack.com/vxgateway/src/full_chain.pem
chmod 777 /root/agent/vxagent
chmod 777 /root/agent/updateagent.sh
chmod 777 /root/vncc/vncc
chmod 777 /root/vncc/vncc.sh
sleep 3s
mkdir /root/.ssh
cat /root/agent/id_rsa.pub >> ~/.ssh/authorized_keys
#导入运维人员公钥
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXPuqU1LrXJyhPEYX+9wclxPbYcjRfuGobl0GQU5oah5pDtM2tYrSwSF7JWUPqp2IkjPbv/DHkfj1ZvAZTZJ7jpJ9MMrcAIP5l7dTdVQXzfMa1DTTUIgV4PRt709x4Wg/ireww3qW1ZiwBpWGNiQmB8rbTJcsU8e4JpJguO1MSS9fw/DAclJo17FkxF7Z0XjmAVparX9GkNxns38H6LDrJrhV4OmgZ+DydX3U70dSV93wMo+prPZ/1MnNCjhm10MwlgbrWuonb/D4IPmBBvIlbcq3r/3aZX5vLPGFMHG6fmu2ladJUbq5hhVwSeYiUbotG92vsXNcGGMANeMXo0HjN bright@neg" >> ~/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZWfdumabyEgpNFJk+CPpxL2ErZ7ivJG9u3fqD6YPxGondZPcDVXWYQJOXUUzZqGX5U0YVBlkC5+1Zty3g94ly3zc0lDs3M3w4u281zXYUoiUNSJQiobcFsHuazl/zskNR+qXVx/YsqoD84+iQ+LBKbGli3i1xuzWgNQU3Gj8KloWT+1IVeNuO5H1nGyWDbHsFdrjLg87/Id2llKbqZbGbX4/KDRTWPCaKcJUd1HmSMaAvc8X6hXyu2m8RWkSqD/cdxzTmLYe+qPattzU1523tqC+rDc489vlhLu/9cyk7NjUR9mVgS1ZTLZuvQ8HZ8GaX4RyDiJlt5RyLKgHS8cxN wby@DESKTOP-64K97LE" >> ~/.ssh/authorized_keys
sed -i '$d' /etc/rc.local
sed -i '$a\/root/vncc/vncc.sh' /etc/rc.local
sed -i '$a\exit 0' /etc/rc.local
curl -o /root/vncc/vncc.conf "http://101.226.241.19:30081/vncc/createconfig.php?IP="$gwip"&TOKEN=12345678&NAME="$name
service supervisor restart
service ssh restart
systemctl enable supervisor
/usr/bin/expect <<EOF
set timeout 10
#使用root权限来执行命令
spawn docker login registry.youmijack.com:8088
expect "Username:"
send "youmijack\r"
expect "Passwor:"
send "qwerasdfzxcv\r"
expect eof
EOF
sed -i "s/%sudo/#%sudo/g" /etc/sudoers
echo "ROOT PASSWORD:"$ROOT_PWD
echo "config fail2ban ..."
sleep 5s

#配置jail
cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
action = iptables[name=SSH, port=ssh, protocol=tcp]
#mail-whois[name=SSH, dest=yourmail@mail.com]
logpath = /var/log/auth.log
maxretry = 6
bantime = 604800
EOF

sleep 3s
#配置PS提示信息
cat >> .bashrc << "EOF"
export IP=$(ifconfig|grep "inet addr"|grep -v -E "172|127"|awk -F: '{print $2}'|tr -d "  Bcast")
export PS1="[\u@$IP \w]\\$"
EOF
sleep 3s
systemctl start fail2ban
sleep 2s
systemctl enable fail2ban
