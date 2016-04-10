<?php
require_once dirname(dirname(__FILE__)).'/config/config.php';
require_once dirname(dirname(__FILE__)).'/classes/Func.php';
require_once dirname(dirname(__FILE__)).'/classes/System.php';

$system = new System();
$_SERVER['HTTP_HOST'] = "l5system.com";
if (!$system->settings->is_conveyer_disabled) {
    //general conveyer
    $generalConveyer = new Conveyers("general", "console");
    if (!$generalConveyer->ExecCommand("check")) {
        $generalConveyer = new Conveyers("general", "force_start");
        $generalConveyer->Run('http://'.$_SERVER['HTTP_HOST'] . "/cron/conveyers/general/minor.php", false);
    } 
}

?>
<META HTTP-EQUIV="REFRESH" CONTENT="25;URL=<?php echo SITE_URL.'cron/conveyer_runner.php'; ?>"/>