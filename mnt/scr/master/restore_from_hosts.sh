#!/bin/bash

# get variables
source /tmp/common/settings.sh

echo "----- segment -----"
echo ${SEGMENT}

echo "----- master host -----"
echo ${MASTER_HOST}

echo "----- slave host list -----"
for i in $( seq 0 $((${_len} - 1)) ); do
    _ref=`echo ${SLAVE_HOST} | jq -r ".[${i}].ip"`
    echo ${_ref}
done
echo ""

read -p "input which host restore from. :" _host_from
if [ -z ${_host_from} ]; then echo "input restore from host." ; exit 1; fi

read -p "input which host restore to. :" _host_to
if [ -z ${_host_to} ]; then echo "input restore to host." ; exit 1; fi
# if [ "${_host_from}" = "${_host_to}" ]; then echo "input not same host." ; exit 1; fi

host_from=
port_from=
host_to=
port_to=
for i in $( seq 0 $((${_len} - 1)) ); do
    _ref=`echo ${SLAVE_HOST} | jq -r ".[${i}].ip"`
    if [ "${_host_from}" = "${_ref}" ]; then
        host_from=${_ref}
        port_from=${SLAVE_PORT}
    fi
    if [ "${_host_to}" = "${_ref}" ]; then
        host_to=${_ref}
        port_to=${SLAVE_PORT}
    fi
done
if [ "${_host_from}" = "${MASTER_HOST}" ]; then
    host_from=${_host_from}
    port_from=${MASTER_PORT}
fi
if [ "${_host_to}" = "${MASTER_HOST}" ]; then
    host_to=${_host_to}
    port_to=${MASTER_PORT}
fi

error=false
if [ -z ${host_from} ]; then
    echo "[error] : unmatch restore from host."
    error=true
fi
if [ -z ${host_to} ]; then
    echo "[error] : unmatch restore to host."
    error=true
fi
if ${error} ; then
    exit 1
fi
# if [ "${host_from}" = "${host_to}" ]; then
#     echo "[error] : can not restore self host."
#     exit 1
# fi

delete_dump=true
read -p "delete dump file? (*/n) :" yn
case "$yn" in 
    [nN]*)
        delete_dump=false
        echo "without delete dump file."
    ;;
    *)
        echo "delete dump file."
    ;;
esac

port_from=11000 # test
port_to=11001 # test

read -p "restore start [${host_from}:${port_from}]---->[${host_to}:${port_to}]. ok? (y/*): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

# gen slave dump
dump_file="dump_${host_from}-`date '+%y%m%d_%H%M%S'`.sql"
opt_from="${ROOT_OPTF} -h ${host_from} --port=${port_from}"
opt_to="${ROOT_OPTF} -h ${host_to} --port=${port_to}"

echo "get dump file from [${host_from}:${port_from}] - start."
# --all-databases
# mysqldump ${opt_from} --all-databases --master-data --single-transaction --flush-logs --events > /tmp/dump/${dump_file}
# single database(set replica-do-db in conf)
mysqldump ${opt_from} --databases ${MYSQL_DATABASE} --master-data --single-transaction --flush-logs --events > /tmp/dump/${dump_file}
# mysqldump ${opt_from} ${MYSQL_DATABASE} --master-data --single-transaction --flush-logs --events > /tmp/dump/${dump_file}
# mysqldump ${ROOT_OPT} -h ${i} -B [database_name] --master-data --single-transaction --flush-logs --events > /tmp/dump_slave.sql
echo "get dump file from [${host_from}:${port_from}] - finish."

# do restore
echo "restore [${host_from}:${port_from}]---->[${host_to}:${port_to}] - start"

mysql ${opt_to} -e "SET PERSIST innodb_flush_log_at_trx_commit = 0";
mysql ${opt_to} -e "SET PERSIST sync_binlog = 0";

mysql ${opt_to} < /tmp/dump/${dump_file}

mysql ${opt_to} -e "SET PERSIST innodb_flush_log_at_trx_commit = 1";
mysql ${opt_to} -e "SET PERSIST sync_binlog = 1";

echo "restore [${host_from}:${port_from}]---->[${host_to}:${port_to}] - finished"

# delete temprary dump file
if ${delete_dump} ; then
    echo "delete dump file - start."
    rm -f /tmp/dump/${dump_file}
    echo "delete dump file - finished."
fi
