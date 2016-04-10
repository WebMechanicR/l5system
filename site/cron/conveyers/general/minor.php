<?php

define("CONVEYER_FREQUENCY", 1);

require_once $_SERVER['DOCUMENT_ROOT'].'/config/config.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/classes/Func.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/classes/System.php';
$system = new System();

$conveyer = new Conveyers("general");
$conveyer->Run("http://".$_SERVER['HTTP_HOST']."/cron/conveyers/general/major.php");

?>