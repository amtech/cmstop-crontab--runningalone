#!/bin/bash

# 计划任务按照ID执行,需要传参
# 示例:
# 设置linux计划任务: 5分钟执行一次计划任务,任务序号ID 45
# crontab -e
# */5 * * * * /bin/bash /data/www/cmstop/cron/crontab_runingalone_cmstop.sh 45
# 计划任务序号ID:45 查看方法:数据库cmstop_cron 中字段 cronid (根据需要自行替换)

function CMSTOP_RUN_CRONID()
{

if [ ! $1 ]; then
    echo "No planned task ID for CMSTOP Crontab..."
    exit 0
fi

cur_dir=$(cd "$(dirname "$0")"; pwd)
cd $cur_dir

pid="cmstop_cron_$1.pid"
if [ -f "$pid" ] && [ -e /proc/`cat $pid` ]; then
        echo "CmsTop Crontab Running..."
        exit 0
fi

trap "rm -fr $pid; exit 0" 0 1 2 3 15
echo $$ > $pid

/usr/local/server/php/bin/php cmstop_run_cronid.php $1

# 输出换行,因为默认cmstop的返回没有换行,会导致日志黏连在一起
echo -e "\n"

}

CMSTOP_RUN_CRONID $1 2>&1 | tee -a /var/log/crontab_runingalone_cmstop.$1.$(date +"%Y-%m").log
