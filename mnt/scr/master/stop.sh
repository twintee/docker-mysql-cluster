#!/bin/sh

# get variables
source /tmp/common/settings.sh

slave_host=`echo ${MYSQL_SLAVE_HOST} | jq .`
len=$(echo ${slave_host} | jq length)

# lock master
echo "----- lock master table -----"
mysql ${ROOT_OPTF} -e "FLUSH TABLES WITH READ LOCK;"

# stop all replications 
for i in $( seq 0 $((${_len} - 1)) ); do
    _ref=`echo ${SLAVE_HOST} | jq -r ".[${i}].ip"`
    echo "stop slave---[${_ref}:${SLAVE_PORT}]"
    mysql ${ROOT_OPTF} -h ${_ref} --port=${SLAVE_PORT} -e "STOP SLAVE;"
done
