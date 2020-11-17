#!/bin/bash

# 各種設定変数取得
source /tmp/common/settings.sh

echo "----- slave host list -----"
for i in $( seq 0 $((${_len} - 1)) ); do
    _ref=`echo ${SLAVE_HOST} | jq -r ".[${i}].ip"`
    echo ${_ref}
done
echo ""

read -p "input which slave host stop replication. :" _host
if [ -z ${_host} ]; then echo "input purge slave host." ; exit 1; fi

#stop replication from slave host
host_stop=
for i in $( seq 0 $((${_len} - 1)) ); do
    _ref=`echo ${SLAVE_HOST} | jq -r ".[${i}]"`
    if [ "${_host}" = "${_ref}" ]; then
        echo "stop slave - ${_ref}"
        mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "STOP SLAVE;"
        host_stop=${_host}
    fi
done
if [ -z ${host_stop} ]; then
    echo "[error] : unmatch stop host."
    exit 1
fi
