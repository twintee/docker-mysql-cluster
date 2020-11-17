#!/bin/sh

# get variables
source /tmp/common/settings.sh

read -p "start all replication. ok? (y/*): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

# delete master bin-log
echo "reset master bin-log."
mysql ${ROOT_OPTF} -e "RESET MASTER";

# get master bin file and position
echo "get bin-log filename and position."
log_file=`mysql ${ROOT_OPTF} -e "SHOW MASTER STATUS\G" | grep File: | awk '{print $2}'`
pos=`mysql ${ROOT_OPTF} -e "SHOW MASTER STATUS\G" | grep Position: | awk '{print $2}'`
echo "${log_file}:${pos}"
for i in $( seq 0 $((${_len} - 1)) ); do
    _ref=`echo ${SLAVE_HOST} | jq -r ".[${i}].ip"`
    # replication restart
    echo "reset slave replication settings - ${_ref}"
    mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "RESET SLAVE";
    mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "CHANGE MASTER TO MASTER_HOST='${MASTER_HOST}', MASTER_PORT=${MASTER_PORT}, MASTER_USER='${REP_USER}', MASTER_PASSWORD='${MYSQL_REP_PASSWORD}', MASTER_LOG_FILE='${log_file}', MASTER_LOG_POS=${pos};"
    echo "start slave - ${_ref}"
    mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "START SLAVE;"

    echo "wait 5sec for replication"
    echo ""
    sleep 5

    # replication reset
    _status=`mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "SHOW SLAVE STATUS\G" | grep " Slave_IO_State:"`
    _log_file=`mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "SHOW SLAVE STATUS\G" | grep " Master_Log_File:" | awk '{print $2}'`
    _pos=`mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "SHOW SLAVE STATUS\G" | grep "Read_Master_Log_Pos:" | awk '{print $2}'`
    echo "---------- ${_ref} status ----------"
    echo ${_status}
    echo "${log_file}:${pos}----->${_log_file}:${_pos}"
    echo ""
    read -p "replication statas ok? (y/*): " yn
    case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac
done

read -p "unlock master container. ok? (y/*): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

# unlock master
echo "unlock master table."
mysql ${ROOT_OPTF} -e "UNLOCK TABLES;"
