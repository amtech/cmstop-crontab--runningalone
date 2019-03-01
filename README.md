# 思拓媒体版CMSTOP-计划任务分离

> 本插件适用于思拓内容管理系统媒体版，调试于CmsTop Media 1.8.0.9888，不保证其他版本能否正常使用(因为没有更改任何系统文件,其它版本可先进行测试)

## 开发原因
思拓后台->工具->计划任务中配置了很多计划任务

但是因思拓系统计划任务使用`Linux`系统`crontab`调用,所有计划任务使用一个`linux`进程

导致就算在系统后台设置了计划任务执行时间也不能保证任务能够按时运行,并且有的任务因为执行数据量大,经常出现执行到一半超时,超出缓存等问题,影响整体任务的运行

为了解决计划任务的性能等各种奇葩问题,将思拓的计划任务分离了出来,可以让任务单独执行,不再依靠一个进程
> 废话:这里为了偷懒直接利用了系统默认的任务,不对原有系统文件进行任何修改,只是添加了一个入口的PHP脚本就实现了,基本上可以放心使用,但是增加了一点Linux系统的维护工作,需要自己去看日志文件

# 使用方法

### 1.上传文件到服务器
#### cron/crontab_run_cronid.php
PHP计划任务执行入口文件(可以使用php命令行单独执行,需要传输一个cronid)
> 注意: cronid 为 cmstop 数据库 cmstop_cron 表中的 cronid 字段
```
$ php crontab_run_cronid.php cronid
```

#### cron/crontab_runingalone_cmstop.sh
> shell脚本,调用PHP计划任务,依赖Linux的`crontab`执行

### 2.设置计划任务自动执行
在`Linux`系统的`crontab`服务中,添加一行任务.我在此处设置的是5分钟执行一次
> 注意: cronid 为 cmstop 数据库 cmstop_cron 表中的 cronid 字段
```
$ crontab -e
*/5 * * * * /bin/bash /data/www/cmstop/cron/crontab_runingalone_cmstop.sh cronid
```

### 3.计划任务日志记录
在文件`cron/crontab_runingalone_cmstop.sh`脚本执行的过程中会记录日志

默认的保存地址为`/var/log`目录下

日志会根据任务ID和日期自动分割,如果需要修改请在`cron/crontab_runingalone_cmstop.sh`脚本的末尾修改`/var/log`

`CMSTOP_RUN_CRONID $1 2>&1 | tee -a /var/log/crontab_runingalone_cmstop.$1.$(date +"%Y-%m").log`

## 注意事项(一定要看):
1.计划任务分离后,产生的日志不能通过后台进行查看,只能进入到`/var/log`目录下查看相关日志

2.分离后的任务只使用了 思拓后台->工具->计划任务 相关设置中的三个参数`App`,`Controller`,`Action`,其它的后台设定或计划任务的状态和运行模式等设置不会在分离任务中起作用

3.计划任务的运行时间以在`Linux`的`crontab`中的执行时间为准

