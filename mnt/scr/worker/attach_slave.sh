#!/bin/sh

# get variables
source /tmp/common/settings.sh

slave_host=`echo ${MYSQL_SLAVE_HOST} | jq .`
len=$(echo ${slave_host} | jq length)

read -p "start replication. ok? (y/*): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

# delete master bin-log
echo "reset master bin-log."
mysql ${ROOT_OPTF} -e "RESET MASTER";

# get master bin file and position
echo "get bin-log filename and position."
log_file=`mysql ${ROOT_OPTF} -e "SHOW MASTER STATUS\G" | grep File: | awk '{print $2}'`
pos=`mysql ${ROOT_OPTF} -e "SHOW MASTER STATUS\G" | grep Position: | awk '{print $2}'`
echo "${log_file}:${pos}"
for i in $( seq 0 $((${len} - 1)) ); do
    _ref=`echo ${slave_host} | jq -r ".[${i}]"`
    # replication reset
    echo "reset slave replication settings - ${_ref}"
    mysql ${ROOT_OPTF} -h ${_ref} --port=11001 -e "RESET SLAVE";
    mysql ${ROOT_OPTF} -h ${_ref} --port=11001 -e "CHANGE MASTER TO MASTER_HOST='${MYSQL_MASTER_HOST}', MASTER_PORT=11000, MASTER_USER='${REP_USER}', MASTER_PASSWORD='${MYSQL_REP_PASSWORD}', MASTER_LOG_FILE='${log_file}', MASTER_LOG_POS=${pos};"
    echo "start slave - ${_ref}"
    mysql ${ROOT_OPTF} -h ${_ref} --port=11001 -e "START SLAVE;"
done

read -p "release master container. ok? (y/*): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

# unlock master
echo "unlock master table."
mysql ${ROOT_OPTF} -e "UNLOCK TABLES;"
