#!/bin/bash
#docker目录监控脚本
DOCKER_DIR=`docker info | grep "Docker Root Dir"|awk -F: '{print $2}'`
DOCKER_USAGE_RATE=`df -h|grep ${DOCKER_DIR}|head -1|grep -v shm|awk '{print $5}'|tr -d %`
THRESHOLD=80
echo -e "${DOCKER_DIR}:${DOCKER_USAGE_RATE}"
if [ ${DOCKER_USAGE_RATE} -gt 80 ]
then
	BIG_FILE_LIST=`find ${DOCKER_DIR} -size +10G |xargs du -sh`
	echo -e "${DOCKER_DIR}:${DOCKER_USAGE_RATE}"
fi
