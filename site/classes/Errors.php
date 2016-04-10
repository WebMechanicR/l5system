<?php
/**
 * Autonomy system of error handling.
 * @author Tim Ismailov <webmechanicR@gmail.com>
 */
 
error_reporting(E_ALL);

define("ERROR_HANDLER_ENABLE", true);										#Enables or disables system
if(!defined("ERROR_HANDLER_DEVELOPMENT"))									#Enables or disables mode for developers (may be defined in config.php)
    define("ERROR_HANDLER_DEVELOPMENT", false);
define("ERROR_HANDLER_SUPPORTED_ERROR_MODE", E_ALL);								#Error mode which will be suported with the system
define("ERROR_HANDLER_ERROR_LOG", strtr(ROOT_DIR_SERVICE.'error_log.err', "\\", "/"));				#Path to error log file
define("ERROR_HANDLER_USER", "USER");										#User error identifier						
define("ERROR_HANDLER_SYSTEM", "SYSTEM");                                                                       #Error error identifier
                                                                                                                #Error may have following types : 
define("ERROR_HANDLER_WARNING", "WARNING");                                                                     #1) warning;
define("ERROR_HANDLER_ERROR", "ERROR");                                                                         #2) error (serious error)
define("ERROR_HANDLER_NOTICE", "NOTICE");                                                                       #3) notice
define("ERROR_HANDLER_SENDING_INTERVAL", 1800);									#sending interval (sending of  new error messages)
define("ERROR_HANDLER_CLEANING_LOG_INTERVAL", 2580000); //one month;						#interval for cleaning of error log file

/**
 * providing of error catching, their accumulating and displaying
 */

class Errors{
    
    /**
     * number of errors being in errors queue
     * @return int
     */
    public function GetNumErrors(){
        return count($this->errorsQueue);
    }
    
    /**
     * adds error in errors queue
     * @param string $degree
     * @param int $code
     * @param string $message
     * @param string $file
     * @param string $line
     */
    public function Push($degree, $code = 0, $message = "", $file = "", $line = ""){
        
        //definition of current file and line which is running
        if(!$file and !$line){
            $trace = debug_backtrace();
            $file = $trace[0]['file'];
            $line = $trace[0]['line'];
        }
        $this->AddError(ERROR_HANDLER_USER, $degree, $code, $message, $file, $line);
        if($degree == ERROR_HANDLER_ERROR) //system must be stopped in serious error
            exit;
    }
    
    /**
     * fetches error from top of errors queue and removes it from the queue
     * @return mixed
     */
    public function GetError(){
        return array_shift($this->errorsQueue); 
    }
    
    //--->>> start handlers
    
    /**
     * ShutDownHandler catches errors of E_ERROR and E_PARSE modes. Next it writes errorsQueue in log file
     * and sends that to developers if it is necessary.
     */
   
   public function ShutDownHandler(){
        $error = error_get_last();
        if ($error and ($error['type'] == E_ERROR or $error['type'] == E_PARSE or $error['type'] == E_COMPILE_ERROR)) { //catches serious errors
           $this->AddError(ERROR_HANDLER_SYSTEM, ERROR_HANDLER_ERROR, $error['type'], $error['message'], $error['file'], $error['line']);
        }
        //openes error log file
        $info = $this->ErrorLogPreparer();

        if($this->GetNumErrors()){
            $this->Log($info);                  //writes errors queue in log
            echo $this->FormMessage(false);     //shows error messages
            $this->errorsQueue = array();
        }
        $this->SendLastErrors($info);           //sending of new errors
        if($this->GetNumErrors()){              //if any errors happened in sending, writes them in log
             $this->Log($info); 
        }    
        fclose($info['fp']); 
    } 
    
    /**
     * error handler which be assigned by set_error_handler function
     * adds error in error queue
     * @param int $errno
     * @param string $errstr
     * @param string $errfile
     * @param int $errline
     * @return boolean
     */
    public function ErrorHandler($errno, $errstr, $errfile, $errline){
        if(error_reporting() == 0) //if @ was used
            return false;
        $degree = ERROR_HANDLER_WARNING;
        switch($errno){
            case E_ERROR:
                $degree = ERROR_HANDLER_ERROR; break;
            case E_NOTICE:
                $degree = ERROR_HANDLER_NOTICE; break;
        }
        $this->AddError(ERROR_HANDLER_SYSTEM, $degree, $errno, $errstr, $errfile, $errline); //adds only system errors
        return true;
    }
    
    /**
     * error handler which be assigned by set_exception_handler function
     * adds error in error queue
     * @param object $ex
     */
    public function ExceptionHandler($ex){
        $this->AddError(ERROR_HANDLER_USER, ERROR_HANDLER_WARNING, $ex->getCode(), $ex->getMessage(), $ex->getFile(), $ex->getLine());
    }
    
    //<<<---end handlers 
     
    
    //--->>>following methods are private
    
    /**
     * adds error in errors queue
     * @param string $type
     * @param string $degree
     * @param int $code
     * @param string $message
     * @param string $file
     * @param string $line
     * @param int $time
     */
    private function AddError($type, $degree, $code, $message = "", $file = "", $line = "", $time = 0){
        array_push($this->errorsQueue, array("type" => $type,
                         "degree" => $degree,
                         "code" => intval($code),
                         "location" => array("file" => $file, "line" => $line),
                         "message" => preg_replace('/\s+/si', ' ', $message),   //not allows \n symbols because \n is delimiter in error log file
                         "time" => ($time)?$time:time()
                  ));
    }
            
    /**
     * prepares error log file
     * @return array
     */
    private function ErrorLogPreparer(){
        fclose(fopen(ERROR_HANDLER_ERROR_LOG, "a+"));      //creates file in multiple thread mode
        $info = array('fp' => false);
        $info['fp']= fopen(ERROR_HANDLER_ERROR_LOG, "r+b"); 
		if(!$info['fp']){
			$this->AddError(ERROR_HANDLER_USER, ERROR_HANDLER_ERROR, 1, "Не удалось открыть файл для записи ошибок. Проверьте права доступа.");
			echo $this->FormMessage(false);
			exit;
		}
        $this->GetMetaData($info);                         //reads or writes metadata  
        return $info;
    }
    
    /**
     * reads metadata or creates them if they does not exist.
     * @param array $info
     */
    private function GetMetaData(&$info){
        if(!$info['fp'] or !$this->OwnFlock($info['fp'], LOCK_SH))              
        {
            $this->InternalError();  //failed in locking of error log file
        }
        $metaStr = fgets($info['fp']);
        $this->OwnFlock($info['fp'], LOCK_UN);
        @$metaData = unserialize(substr($metaStr, 3));
        if(!$metaData){
            $info['last_sending_time'] = time() - ERROR_HANDLER_SENDING_INTERVAL - 1;     #time of last sending of new error messages
            $info['last_writing_pos'] = 1;                                                #line in error log file which points to new error messages
            $info['last_clear_log_time'] = time();                                        #time of last clearing of erro log file
            $this->WriteMetaData($info, true);                     
        }
        else
        {
            $info['meta_data_length'] = strlen($metaStr) - 3;                             #length of metadata array
            $info['last_sending_time'] = $metaData['last_sending_time'];
            $info['last_writing_pos'] = $metaData['last_writing_pos'];
            $info['last_clear_log_time'] = $metaData['last_clear_log_time'];
        }
    }
    
    /**
     * writes metadata it error log file
     * @param array $info
     * @param boolean $clearFile
     */
    private function WriteMetaData(&$info, $clearFile = false){
         $metaStr = serialize(array("last_sending_time" => $info['last_sending_time'], "last_writing_pos" => $info['last_writing_pos'], "last_clear_log_time" => $info['last_clear_log_time']))."\n";
         $meta_data_length = sprintf("%03d", strlen($metaStr));  //for string view
         $old_data_length = 0;
         if(isset($info['meta_data_length']))
               $old_data_length = $info['meta_data_length'];     //length of former metadata

         //we must rewrite metadata
         if((intval($old_data_length) != intval($meta_data_length)) and !$clearFile)
         {
            if(!$info['fp'] or !$this->OwnFlock($info['fp'], LOCK_EX))
            {
                $this->InternalError();
            }
            //extracts all errors
            fseek($info['fp'], strlen($old_data_length) + intval($old_data_length));
            $buffer = fread($info['fp'], filesize(ERROR_HANDLER_ERROR_LOG));  
            //clearing of file
            ftruncate($info['fp'] ,0);
            fseek($info['fp'], 0);
            //writes new metadata
            fwrite($info['fp'], $meta_data_length.$metaStr);
            //writes all errors after metadata
            fwrite($info['fp'], $buffer);
	    fflush($info['fp']);    //need of multiple thread mode
            $this->OwnFlock($info['fp'], LOCK_UN);
         }
         else
         {
            if(!$info['fp'] or !$this->OwnFlock($info['fp'], LOCK_EX))
            {
                $this->InternalError();
            }
            if($clearFile)
                ftruncate($info['fp'], 0); //clearing of the file
            fseek($info['fp'], 0);
            fwrite($info['fp'], $meta_data_length.$metaStr);
	    fflush($info['fp']);   //need of multiple thread mode
            $this->OwnFlock($info['fp'], LOCK_UN); 
         }
         
         $info['meta_data_length'] = $meta_data_length;     //length of new metadata   
    }
    
    /**
     * provides own blocking of files
     * @param resource $fp
     * @param int $mode
     * @return boolean
     */
    private function OwnFlock($fp, $mode){
        $i = 0;
        $waitingLimit = 5;
        while($i < $waitingLimit and !flock($fp, $mode))
        {
            usleep(1);
            $i++;
        }
        if($waitingLimit == $i)
            return false;
        return true;
    }
    
    /**
     * if will happen internal error of the system, this function be called.
     */
    private function InternalError(){
        $this->AddError(ERROR_HANDLER_SYSTEM, ERROR_HANDLER_ERROR, 0, "Внутренний сбой обработки ошибок");
        echo $this->FormMessage(false);
        exit;
    }
    
    /**
     * formates error message from errors queue for error log file or message of browser
     * @param boolean $forLogFile
     * @return string
     */
    private function FormMessage($forLogFile = true){
        $result = "";
        if($count = count($this->errorsQueue)){
            $i = 1;
            foreach($this->errorsQueue as $val){
                if($forLogFile or ERROR_HANDLER_DEVELOPMENT or ((defined("ADMINS_HAT") and ADMINS_HAT) or defined("IS_ADMIN")))     
                    $errorStr = "[".date("d-m-Y H:i:s", $val['time'])."] ".$val['type']." FAILURE - ".$val['degree']." ".$val['code'].": ".
                                strtr($val['message'], "\r\n", " ")." in ".$val['location']['file']." on line ".$val['location']['line']."\n";
                else {
                    //if visitor of the website is not administrator or developer,
                    //error message must be cut
                    $errorStr = ($i++).") ".$val['type']." FAILURE - ".$val['degree']." ".$val['code'].": Обратитесь к администратору или разработчику\n";
                }
                
                $result .= $errorStr;
            }
            if(!$forLogFile){
                //window for error message in browser
                $result = "<div style = 'position: absolute; z-index: 100000; top: 0px; left:0px; border: 2px; border-color:#F08C8C; background-color:#F0D7D7; width: 350px; font-size: 13px; padding: 20px;'>".
                          "<span style = 'color:#A23E3E; font-size: 20px;'>".(($count > 1)?"Произошли следующие ошибки:":"Ошибка!")."</span><br/><br/>".
                          nl2br(wordwrap($result, 50, "\n", true)).
                          "</div>";
            }
        }
        return $result;
    }
    
    /**
     * writes error queue in error log file
     * @param array $info
     */
    private function Log($info){
         $msg = $this->FormMessage();
         if(!$info['fp'] or !$this->OwnFlock($info['fp'], LOCK_EX))
         {
                $this->InternalError();
         }
         fseek($info['fp'], filesize(ERROR_HANDLER_ERROR_LOG));
         fwrite($info['fp'], $msg);
		 fflush($info['fp']);
         $this->OwnFlock($info['fp'], LOCK_UN);
    }       
    
    /**
     * sends new errors from error log file to developers
     * @param array $info
     */
    private function SendLastErrors(&$info){
        if(((time() - $info['last_sending_time']) > ERROR_HANDLER_SENDING_INTERVAL)){
            if(!$info['fp'] or !$this->OwnFlock($info['fp'], LOCK_SH))
            {
                $this->InternalError();
            }
            $errorArrayAll = file(ERROR_HANDLER_ERROR_LOG, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            $this->OwnFlock($info['fp'], LOCK_UN);
            if(isset($errorArrayAll[$info['last_writing_pos']]))
            {
              
                $count = 0;
                $sendingArr = array();
                //new errors only
                while(@$error = $errorArrayAll[$info['last_writing_pos'] + $count]){ 
                    $sendingArr[] = $error;
                    $count++;
                }
                
                if($count)
                {
                                        $errors = implode("**del**", $sendingArr); //special delimiter
					$sendInfo = SendInfoToDev("errors", array("lastErrors" => $errors)); //sends
					if(!$this->GetNumErrors() and ($sendInfo['code'] != 500)){	
						$clearFile = false;
						if((time() - $info['last_clear_log_time']) > (ERROR_HANDLER_CLEANING_LOG_INTERVAL + ERROR_HANDLER_SENDING_INTERVAL))
						{       
                                                        //clearing of error log file
							$clearFile = true;
							$info['last_clear_log_time'] = time();
						}
						$info['last_writing_pos'] += $count;
						$info['last_sending_time'] = time();
						$this->WriteMetaData($info, $clearFile);    //writes new metadata
					}
                }
            }
        }
    }
    
    private $errorsQueue = array();         #all errors which happened in runtime of the script
}

$errorHandlerObject = new Errors();         #creates error handler   

/**
 * sends service information to developers, including files of any sizes
 * @global Errors $errorHandlerObject
 * @param string $type
 * @param array $info
 * @param array $files
 * @return array
 */
function SendInfoToDev($type, $info, $files = array()){
	global $errorHandlerObject;
        //definition of current file and line which is running
	$trace = debug_backtrace();
	$file= $trace[0]['file'];
	$line = $trace[0]['line'];

	$result = array();
	
	if(!$type or !$info or !is_array($info))
		$errorHandlerObject->Push(ERROR_HANDLER_WARNING, 1, "Аргументы не заданы.", $file, $line);
	
	if($files and is_array($files))
		array_walk($files, function(&$val, $key){
			$val = ("@".strval($val));  //handles of file pathes for curl library function
		});
	
	array_walk($info, function(&$val, $key){
		$val = strval($val);
	});
	
	$result['code'] = 400;
	$result['answer'] = "Skipped connection.";
	$result['details'] = "";
	$result['error'] = 0;
	/*
	$ch = curl_init();
    $options = array(
        CURLOPT_URL => DEVELOPMENT_SERVER_ADDRESS,  
        CURLOPT_AUTOREFERER => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => array_merge(array("type" => $type,                                                                    #error or antivirus or any more
                                                "licenseKey" => ((defined("LICENSE_KEY"))?LICENSE_KEY:0),                           
                                                "hostName" => isset($_SERVER['HTTP_HOST'])?$_SERVER['HTTP_HOST']:"", 
						"language" => isset($SiteLanguageGlobal)?$SiteLanguageGlobal:0,                     #language of the website
						"userAgent" => isset($_SERVER['HTTP_USER_AGENT'])?$_SERVER['HTTP_USER_AGENT']:"",
						"remoteAddr" => isset($_SERVER['REMOTE_ADDR'])?$_SERVER['REMOTE_ADDR']:""),
						array_merge($info, $files))                                                         #sending of files
    );
	
    curl_setopt_array($ch, $options);
    $acceptData = curl_exec($ch);
    //if error happened, we should return 500 code for all applications
    //the applications must solve how to work
    if(curl_errno($ch)) 
    {	
	curl_close($ch);
	   
           //$errorHandlerObject->Push(ERROR_HANDLER_WARNING, 2, "Не удалось связаться с сервером разработчиков для отправки служебной информации.", $file, $line);
	   $result['code'] = 500;
	   $result['answer'] = "Bad gateway.";
	   $result['details'] = "";
	   $result['error'] = 0;
    }
   else{
		curl_close($ch);
                //parsing of unique answer from developers
		@$xml = simplexml_load_string($acceptData);
		if($xml)
		{ 
			$result['code'] = $xml->code;
			$result['answer'] = $xml->answer;
			$result['details'] = $xml->details;
			$result['error'] = $xml->error;
			
                        //developers sent error
			if(strval($result['error']))
			{
			    $errorHandlerObject->Push(ERROR_HANDLER_WARNING, 4, "Ответ от сервера разработчиков: ".$xml->error, $file, $line);
			}
		}
		else{
			$errorHandlerObject->Push(ERROR_HANDLER_WARNING, 3, "Получен некорректный ответ.", $file, $line);
		}
	}
	*/
	
	return $result;
}


/**
 * sets error handlers and modes of error displaying
 */
if(ERROR_HANDLER_ENABLE):
error_reporting(ERROR_HANDLER_SUPPORTED_ERROR_MODE);
ini_set('display_errors', 0);

register_shutdown_function(array($errorHandlerObject, "ShutDownHandler"));
set_error_handler(array($errorHandlerObject,"ErrorHandler"), ERROR_HANDLER_SUPPORTED_ERROR_MODE);
set_exception_handler(array($errorHandlerObject,"ExceptionHandler"));
endif;
?>