<?php
/**
 * 使用方法:执行以下命令 后面跟上参数 number (参数为计划任务的ID)
 * 计划任务的ID查看方法:数据库cmstop_cron 中字段 cronid 或者 进入后台->工具->计划任务(查看每个计划任务的ID)
 * ID : 18 为 计划任务:访问统计
 * /usr/local/server/php/bin/php crontab_run_cronid.php cronid
 */

define('CMSTOP_START_TIME', microtime(true));
define('RUN_CMSTOP', true);
define('IN_ADMIN', 1);
define('INTERNAL', 1);

require '../cmstop.php';

$cronid = intval($_SERVER['argv'][1]);

$cmstop = new cmstop('admin');

if (!$cronid) {
    exit(json_encode(array('state'=>false,'info'=>'没有传参')));
}

$cmstop = new cmstop('admin');

$cron = loader::model('admin/cron', 'system');

$cd = $cron->get($cronid);

if($cd['cronid']){
    $cmstop->execute($cd['app'], $cd['controller'], $cd['action']);
}else{
    exit(json_encode(array('state'=>false,'info'=>'不存在这个任务'.$cronid)));
}


