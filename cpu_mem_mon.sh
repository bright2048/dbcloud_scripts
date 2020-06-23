#!/bin/bash
#列出top5 的cpu和内存的占用进程信息
#colume included:  user,pid,%cpu,%mem,start,time,command
set -e
set -u
usage()
{
    echo "script usage: $(basename $0) [-c] [-m] " >&2
}
while getopts 'cm' OPTION; do
  case "$OPTION" in
    c)
      bash -c "ps -e -o user,pid,%cpu,%mem,start,time,command|sort -nrk 3|head -n 5"
      ;;

    m)
      bash -c "ps -e -o user,pid,%cpu,%mem,start,time,command|sort -nrk 4|head -n 5"
      ;;

    ?)
      usage
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"
if [ $# -eq 0] 
then
    usage
    exit 1
fi
