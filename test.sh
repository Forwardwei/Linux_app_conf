#!/bin/bash
MY_PROCESS='bacserv'
MY_STORAGE='/run'
STORAGESIZE=80%
MY_LOGDIR='/home/firefly/test.log'
CLEARSIZE=20000
PINGADDR="192.168.0.1 8.8.8.8 www.baidu.com"
NEEDREPAIR=1

echo -e "\n" >> /home/firefly/test.log

CLEAR=`ls -l /home/firefly/test.log | awk '$5>$CLEARSIZE{print $5}'`
if [ $CLEAR -gt $CLEARSIZE ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` "logfile will be clear at "  > /home/firefly/test.log
else
    echo `date "+%Y-%m-%d %H:%M:%S"` "logfile used $CLEAR b at "  >> /home/firefly/test.log
fi

for IP in $PINGADDR; do
    NUM=1
    while [ $NUM -le 3 ]; do
        if ping -c 1 $IP > /dev/null; then
            echo `date "+%Y-%m-%d %H:%M:%S"` "$IP Ping is successful."  >> /home/firefly/test.log
            break
        else
            echo `date "+%Y-%m-%d %H:%M:%S"` "$IP Ping is failure $NUM"  >> /home/firefly/test.log
            FAIL_COUNT[$NUM]=$IP
            let NUM++
        fi
    done
    if [ ${#FAIL_COUNT[*]} -eq 3 ];then
        echo -e `date "+%Y-%m-%d %H:%M:%S"` "\033[31m ${FAIL_COUNT[1]} Ping is failure! system will be repaired! \033[0m" >> /home/firefly/test.log
        unset FAIL_COUNT[*]
        NEEDREPAIR=0
    fi
done

USED=`df $MY_STORAGE | grep -w $MY_STORAGE | awk '{print $5}'`
if [[ "$USED" > "$STORAGESIZE" ]]; then
    echo -e `date "+%Y-%m-%d %H:%M:%S"` "\033[31m $MY_STORAGE storage $USED more than $STORAGESIZE! \033[0m" >> /home/firefly/test.log
    NEEDREPAIR=0
else
    echo `date "+%Y-%m-%d %H:%M:%S"` "$MY_STORAGE storage $USED less than $STORAGESIZE !" >> /home/firefly/test.log
fi


PIDS=`ps -ef |grep -w $MY_PROCESS |grep -v grep | awk '{print $2}'`
if [ "$PIDS" != "" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` "$MY_PROCESS is runing! PIDS=$PIDS" >> /home/firefly/test.log
else
    echo -e `date "+%Y-%m-%d %H:%M:%S"` "\033[31m $MY_PROCESS was not found ,system will be repaired! \033[0m"  >> /home/firefly/test.log
    NEEDREPAIR=0
fi

if [ $NEEDREPAIR -eq 0 ]; then
    echo -e `date "+%Y-%m-%d %H:%M:%S"` "\033[31m test.sh will call repair.sh to reboot system! \033[0m"  >> /home/firefly/test.log
    #/usr/local/bin/repair.sh
else
    echo -e `date "+%Y-%m-%d %H:%M:%S"` "\033[32m everything is ok! \033[0m"  >> /home/firefly/test.log
fi
