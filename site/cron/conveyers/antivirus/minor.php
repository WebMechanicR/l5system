<?php

define("CONVEYER_FREQUENCY", 1); 

require_once $_SERVER['DOCUMENT_ROOT'].'/config/config.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/classes/Conveyers.php';

$conveyer = new Conveyers("antivirus");
$conveyer->Run("http://".$_SERVER['HTTP_HOST']."/cron/conveyers/antivirus/major.php");

?>