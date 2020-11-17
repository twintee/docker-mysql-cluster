#!/bin/bash

# 各種設定変数取得
source /tmp/common/settings.sh

# masterのbin-logのファイル名とポジション取得
echo "---------- SHOW SLAVE HOSTS ----------"
mysql ${ROOT_OPTF} -e "SHOW SLAVE HOSTS\G"
echo ""

log_file=`mysql ${ROOT_OPTF} -e "SHOW MASTER STATUS\G" | grep File: | awk '{print $2}'`
pos=`mysql ${ROOT_OPTF} -e "SHOW MASTER STATUS\G" | grep Position: | awk '{print $2}'`

for i in $( seq 0 $((${_len} - 1)) ); do
    _ref=`echo ${SLAVE_HOST} | jq -r ".[${i}].ip"`
    _status=`mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "SHOW SLAVE STATUS\G" | grep " Slave_IO_State:"`
    _log_file=`mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "SHOW SLAVE STATUS\G" | grep " Master_Log_File:" | awk '{print $2}'`
    _pos=`mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "SHOW SLAVE STATUS\G" | grep "Read_Master_Log_Pos:" | awk '{print $2}'`
    echo "---------- ${_ref} status ----------"
    echo ${_status}
    echo "${log_file}:${pos}----->${_log_file}:${_pos}"
    echo ""
done
