<?php

define("CONVEYER_FREQUENCY", 7);

require_once $_SERVER['DOCUMENT_ROOT'].'/config/config.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/classes/Func.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/classes/System.php';

$system = new System();

if(!$system->settings->is_conveyer_disabled && ($system->settings->seo_promo_start_date - time() <= 0)){
    $conveyer = new Conveyers("general");
    $conveyer->Run("http://".$_SERVER['HTTP_HOST']."/cron/conveyers/general/minor.php", "generalConveyerHandler");
}
else{
    if(file_exists('mutex.mut') and !(@unlink('mutex.mut')))
            exit;
    else{
        $mut = fopen('mutex.mut', 'a+');
        
        generalConveyerHandler();
        fclose($mut);
    }
}

function generalConveyerHandler(){
	global $system;
        $system->economic_news->parse_calendar();
}

?>