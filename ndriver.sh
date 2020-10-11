#!/bin/bash
DRIVER_FILE="/root/NVIDIA-Linux-x86_64-450.66.run"
sudo service lightdm stop \
; sudo init 3
sudo apt-get update
sudo apt-get -y install software-properties-common python-software-properties wget
sudo apt install gcc-6-base=6.0.1-0ubuntu1 gcc make -y
if [ ! -e $DRIVER_FILE ]
then
    wget -O /root/NVIDIA-Linux-x86_64-450.66.run http://registry.youmijack.com:8880/NVIDIA-Linux-x86_64-450.66.run
fi
chmod +x /root/NVIDIA-Linux-x86_64-450.66.run
bash -c "/root/NVIDIA-Linux-x86_64-450.66.run --compat32-libdir --no-x-check --no-nouveau-check --no-opengl-files --silent"
