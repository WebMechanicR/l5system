<?php

define("CONVEYER_FREQUENCY", 9); 

require_once $_SERVER['DOCUMENT_ROOT'].'/config/config.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/classes/Func.php';
require_once $_SERVER['DOCUMENT_ROOT'].'/classes/System.php';
$system = new System();

if(!$system->settings->is_conveyer_disabled){
   $system->antivirus->Run();
}
else{
    if(file_exists('mutex.mut') and !(@unlink('mutex.mut')))
            exit;
    else{
        $mut = fopen('mutex.mut', 'a+');
        if($system->settings->antivirus_enabled)
            $system->antivirus->ExecAlertHandlers();
        fclose($mut);
    }
}

?>