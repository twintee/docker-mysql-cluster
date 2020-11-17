#!/bin/sh

# 各種設定変数取得
source /tmp/common/settings.sh

#stop replication
echo "stop slave - ${my_host}"
mysql ${ROOT_OPTF} -e "STOP SLAVE;"
