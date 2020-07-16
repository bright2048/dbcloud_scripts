#!/bin/bash
echo 'nvidia devices status//////////////////////////'
nvidia-smi --query-gpu=index,name,temperature.gpu,memory.used,memory.total,utilization.gpu --format=csv,noheader,nounits
echo 'disk status////////////////////////////////////'
function split_str()
{
         str="$1"
         OLD_IFS="$IFS"
         IFS="$2"
         array=($str)
         IFS="$OLD_IFS"
         for each in ${array[*]}
         do
            echo $each
         done
}
ret=(`df -H | grep -vE 'udev|tmpfs|cdrom|overlay' |awk 'NR > 1{print $1 "," $2 "," $3 "," $4 "," $5 "," $6}'`)
split=","
for line in ${ret[*]}
do
    arr=(`split_str $line $split`)
    ck=(`echo 'test disk' > ${arr[5]}/tt.ck && rm -f ${arr[5]}/tt.ck`)
    numarr=(`split_str ${arr[4]} "%"`)
    checkflag="ok"
    if [ `expr ${numarr[0]} \> 90` -eq 1 ]
    then
        checkflag="over"
    fi
    if [[ ${ck} != "" ]]
        then
        checkflag="error"
    fi
    echo ${arr[0]}","${arr[1]}","${arr[2]}","${arr[3]}","${arr[4]}","${arr[5]}","${checkflag}
done
echo 'vncc status////////////////////////////////////'
serverip=$(sed -n '2p' /root/vncc/vncc.conf)
serverssh=$(sed -n '9p' /root/vncc/vncc.conf)
serverjkdk=$(sed -n '14p' /root/vncc/vncc.conf)
serverpt=$(sed -n '19p' /root/vncc/vncc.conf)
echo "{|servergl|:|${serverip#*= }":"${serverssh#*= }|,|serverjk|:|${serverip#*= }":"${serverjkdk#*= }|,|serverpt|:|${serverpt#*= }|}"
echo 'nvd status////////////////////////////////////'
nvidia-container-cli -k -d /dev/tty info
nvidia-docker create -it --name checknvd registry.youmijack.com:8088/st-cuda10.0-cudnn7-py36-all:v1.1
nvidia-docker start checknvd
docker exec checknvd bash -c "service ssh restart"
docker stop checknvd
docker rm checknvd
echo 'network status////////////////////////////////////'
router=$(route -n)
pingstr=$(ping -c 2 www.baidu.com)
echo -e $router
echo -e $pingstr
echo 'ssh status////////////////////////////////////'
echo 'publickey'
cat ~/.ssh/authorized_keys
echo 'config'
cat /etc/ssh/sshd_config
date
echo done