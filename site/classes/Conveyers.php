<?php
 /**
  * Conveyer system
  * It allows to invoke a few threads
  * It is remarkable to use instead CRON system
  * @author Tim Ismailov <webmechanicR@gmail.com>
  */

require_once(strtr(dirname(__FILE__).'/Errors.php', "\\", "/"));   
 
if(!defined("CONVEYER_FREQUENCY"))                                                                  #frequency of the conveyer (also specifies performance)
	define("CONVEYER_FREQUENCY", 1);
define("CONVEYER_PATH_TO_CONFIG_FILE", strtr(ROOT_DIR_SERVICE."conveyer.ini", "\\", "/"));
	

/**
 * The conveyer consists from two files called major and minor.
 * The files are invoked alternatly according to frequecny pointed in each of them.
 * Each of the files invokes other via sockets and stops its running
 * 
 * Example of major.php
 * $conveyer = new Conveyers("nameOfTheConveyer");
 * $conveyer->Run("minor.php", "anyCallBack");
 * 
 * Example of minor.php
 * $conveyer = new Conveyers("nameOfTheConveyer");
 * $conveyer->Run("major.php", "anyCallBack"); 
 * 
 * The anyCallBack function may do any operations with any duration
 */

class Conveyers {
	
        /**
         * Initializes configuration file and invokes passed command for conveyer with the name
         * @global object $errorHandlerObject
         * @param string $name
         * @param string $command
         */
	public function __construct($name, $command = false){
		global $errorHandlerObject;
                $this->errorHandlerObject = $errorHandlerObject;
		$this->runStart = time();
                $this->isSecond = (isset($_GET['isSecond']) and $_GET['isSecond'])?0:1;
                
		$executable = isset($_GET['ConveyerKey'])?$_GET['ConveyerKey']:0;
		$this->executable = $executable;
		$newKey = mt_rand(1, 1000000); //number of the session
		$executableKey = $executable;
		
		if(!$name)
		{
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 5, "Недопустимое имя конвейера", $fileLine[0], $fileLine[1]);
		}
		
		fclose(fopen(CONVEYER_PATH_TO_CONFIG_FILE, "a+"));      //creates configuration file in multiple thread mode
		$fp = fopen(CONVEYER_PATH_TO_CONFIG_FILE, "r+");
		if(!$fp){
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
                }
                
                //--->>> locking of configuration file
                
		flock($fp, LOCK_EX); 
                
		$config = "";
		while(!feof($fp))
			$config .= fread($fp, 100000);
		@$config = parse_ini_string($config, true);
		
		//Protection from external calls
		if($executableKey and ($config[$name]['executable_key'] != $executableKey)){
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Нарушение защиты", $fileLine[0], $fileLine[1]);
		}
                
		if($command == "force_start" and isset($config[$name]) and !$executable)  //mode of force start (even with same names)
                    unset($config[$name]);
     
		if(isset($config[$name]) and !$command and !$executable)    //does not allow same names for conveyer
		{	
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 5, "Недопустимое имя конвейера.", $fileLine[0], $fileLine[1]);
		}
		
		if(!isset($config[$name]) and $command != "console")
			$config[$name] = array(
				"iteration" => 0,                                               #quantity of iterations
				"start_time" => date("m-d-Y H:i:s", time()),                    
                                "frequency_of_first" => CONVEYER_FREQUENCY,                     #frq of first file of the conveyer
                                "frequency_of_second" => "",                                    #frq of second file of the conveyer
                                "last_iteration_time" => time(),                                #last time of call
				"current_command" => "",                                        
				"executable_key" => $newKey                                     #number of session
			);
			
		if(!$command and $executable)   //takes command from config file
		{
			$command = $config[$name]['current_command'];                 
		}	
		
		$this->name = $name;
		$this->currentCommand = $command;	
		
                //invokes command
		$this->ExecCommand($command, $config);
		
		if(isset($config[$name]) and $executable){
			$config[$name]['iteration'] += 1;
			$config[$name]['executable_key'] = $newKey;
			
                         if(($config[$name]['frequency_of_first'] != CONVEYER_FREQUENCY) and !$this->isSecond)
                             $config[$name]['frequency_of_first'] = CONVEYER_FREQUENCY;
                         if(($config[$name]['frequency_of_second'] != CONVEYER_FREQUENCY) and $this->isSecond)
                             $config[$name]['frequency_of_second'] = CONVEYER_FREQUENCY;
                         $config[$name]['last_iteration_time'] = time();
                 }
				
		//writes configuration file	
		$config = $this->GenerateIni($config);
		ftruncate($fp, 0);
		fseek($fp, 0);
		fwrite($fp, $config);
		fflush($fp);
		flock($fp, LOCK_UN); 
		fclose($fp);
		
                //<<<--- end of locking of configuration file
                
		$this->executableKey = $newKey;         #new number of session
		$this->currentConfig = $config;         #configuration data
	}
	
        /**
         * Invokes callback function and calls other file of the conveyer
         * @param string $ownFriend
         * @param callback $ownCallback
         * @return void
         */
	public function Run($ownFriend, $ownCallback = false){
		if($this->currentCommand == "end" or $this->currentCommand == "console")
			return;
		if($this->executable){  //allows calling file be stopped
                    ignore_user_abort(true);
                    echo str_repeat("OK", 1000000);
                    @ob_end_flush();
                }
		set_time_limit(0);
		
		$ownFriend = parse_url($ownFriend);
		$ownFriend['scheme'] = "http";
		
		if(!$ownFriend['host'])
		{
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 1, "Адрес друга задан неправильно", $fileLine[0], $fileLine[1]);
		}
		$this->ownFriend = $ownFriend;
		$this->ownCallback = $ownCallback;
		if(is_array($ownCallback))
		{
			if(!method_exists($ownCallback[0], $ownCallback[1]))
			{
				$fileLine = $this->FileLineCalc();
				$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 2, "Передан недействительный функтор", $fileLine[0], $fileLine[1]);
			}
		}
		else if($ownCallback and !function_exists($ownCallback))
		{
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 2, "Передан недействительный функтор", $fileLine[0], $fileLine[1]);
		}
		
		if($ownCallback)
			$this->execute();
		$this->callOwnFriend();
	}
	
        /**
         * Invokes passed command
         * @param sting $command
         * @param array $config
         * @return boolean
         */
	public function ExecCommand($command, &$config = false){
		$name = $this->name;
                $executable = $this->executable;
		if($command)
		{
			$command = strtolower($command);
			switch($command)
			{
				case "allow_running":
					$this->currentCommand = "";
				case "end": 
                                        //the command stops the conveyer
					if(!$executable){
                                                if(!$config){   
                                                    fclose(fopen(CONVEYER_PATH_TO_CONFIG_FILE, "a+"));
                                                    $fp = fopen(CONVEYER_PATH_TO_CONFIG_FILE, "r+");
													if(!$fp){
														$fileLine = $this->FileLineCalc();
														$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
													}
                                                    flock($fp, LOCK_EX);
                                                    $config = "";
                                                    while(!feof($fp))
                                                         $config .= fread($fp, 100000); 
                                            
                                                    @$config = parse_ini_string($config, true);
                                                    $config[$name]['current_command'] = "end";
                                                    ftruncate($fp, 0);
                                                    fseek($fp, 0);
                                                    fwrite($fp, $this->GenerateIni($config));
					            fflush($fp);
						    flock($fp, LOCK_UN);
                                                    fclose($fp);
                                                }
                                                else
                                                    $config[$name]['current_command'] = "end";
					}
					else    //console mode
						unset($config[$name]);
					break;
                                case "check":
                                        //checks whether conveyer with the name is running or not
                                        if(!$config){ //console mode
                                            fclose(fopen(CONVEYER_PATH_TO_CONFIG_FILE, "a+"));
                                            $fp = fopen(CONVEYER_PATH_TO_CONFIG_FILE, "r+");
											if(!$fp){
												$fileLine = $this->FileLineCalc();
												$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
											}
                                            flock($fp, LOCK_EX);
                                            $config = "";
                                            while(!feof($fp))
                                                $config .= fread($fp, 100000); 
                                            flock($fp, LOCK_UN);
											fclose($fp);
                                            @$config = parse_ini_string($config, true);
                                            if(!$config)
												return false;
                                            if($config and isset($config[$name]))
                                                if(@(abs(intval(time() - $config[$name]['last_iteration_time'])) <= ($config[$name]['frequency_of_first'] + $config[$name]['frequency_of_second'] + 1)))
                                                    return true;
						else if (file_exists(ROOT_DIR_SERVICE.'mut_'.$this->name.'_conveyer.mut') and !(@unlink(ROOT_DIR_SERVICE.'mut_'.$this->name.'_conveyer.mut'))) //mutex is busy
						    return true;
                                            return false;
                                        }
                                        else{
                                            $this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 7, "Данная команда конвейера выполняется только в режиме консоли", $fileLine[0], $fileLine[1]);
                                        }
                                        break;
                                        
				default: if(!in_array($command, $this->allCommands)) $this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 6, "Неизвестная команда конвейера", $fileLine[0], $fileLine[1]);
			}
		}
	}
	
        /**
         * Invokes callback function
         */
	private function execute(){
		if(!$this->mutex)   //takes mutex
			$this->mutex = fopen(ROOT_DIR_SERVICE.'mut_'.$this->name.'_conveyer.mut', 'a+');
		call_user_func($this->ownCallback);
		$this->callOwnFriend();
	}
	
        /**
         * Calling other file of the conveyer
         * and frees mutex
         * @return void
         */
	private function callOwnFriend(){
		if($this->isCalledOwnFriend)
			return;
				
		if(CONVEYER_FREQUENCY and (($executionTime = (time() - $this->runStart)) <  CONVEYER_FREQUENCY))
			sleep(CONVEYER_FREQUENCY - $executionTime);
			
		set_time_limit(10);
		$sh = fsockopen($this->ownFriend['host'], 80, $errno, $errstr);
		if($errno)
		{
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 4, "Конвейер остановлен: ".$errstr);
		}
		
		fputs($sh, "GET ".($this->ownFriend['scheme'])."://".($this->ownFriend['host']).($this->ownFriend['path'])."?isSecond=".$this->isSecond."&ConveyerKey=".$this->executableKey." HTTP/1.1\n");
		fputs($sh, "Host: ".$this->ownFriend['host']."\n");
		fputs($sh, "User-Agent: Conveyer\n");
		fputs($sh, "Connection: close\n\n");
		
		$str = fgets($sh, 50);
		if(strpos($str, "200") === false)
		{
			$this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 4, "Конвеер: пустой ответ от второго скрипта");
		}
		
		stream_set_blocking($sh, 0);    //non-blocking mode
		set_time_limit(0);

		$this->isCalledOwnFriend = true;
		if($this->mutex)
			fclose($this->mutex);
	}
        
        /**
         * Creates ini string
         * @param array $arrValues
         * @param boolean $withSection
         * @return string
         */
	private function GenerateIni($arrValues, $withSection = true)
	{
		$result = "";
		
		foreach($arrValues as $key => $val)
		{
			if($withSection)
			{
				$sectionValues = $val;
				$result .= "\n\n[".$key."]\n\n";
				foreach($sectionValues as $key2 => $val2){
					$val2 = (is_string($val2))?'"'.$val2.'"':$val2;
					$result .= ($key2." = ".$val2."\n");
				}
			}
			else{
				
				$result .= ($key." = ".$val."\n\n");
			}
		}
		
		return $result;
	}
	
        /**
         * Finds current file and line for error handler
         * @return array
         */
	private function FileLineCalc(){
		$trace = debug_backtrace();
		return array($trace[1]['file'], $trace[1]['line']);
	}
	
	private $isCalledOwnFriend = false;         #points to the fact that other file of a conveyer was called
	
	private $errorHandlerObject;                #error handling
	
	private $name;                              #name of a conveyer
	private $currentCommand = "";               #current command for conveyer with the name
	private $executable;                        #whether the script is background process or not
	private $executableKey;                     #unique number of the current session
	private $isSecond;                          #points to the fact that script in first time was invoked by other script but not user
	private $ownCallback;                       #anyCallBack function
	private $ownFriend = "";                    #address of other file of a conveyer
	private $currentConfig;                     #data of current configuration file
	private $mutex = false;                     #mutex file for checking of whether conveyer with the name is running or not.
        private $runStart;
	
	private $allCommands = array("end",         #allowed commands for conveyer
                                     "console", 
                                     "allow_running", 
                                     "force_start", 
                                     "check");
}
?>