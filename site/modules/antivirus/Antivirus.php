<?php
/**
 * PHP Antivirus
 * @author Tim
 */
class Antivirus extends Module {
    
    public function __construct(){
		parent::__construct();
		$this->enable = false;
		if($this->settings->antivirus_enabled)
			$this->enable = true;
        $this->configFile = ROOT_DIR_SERVICE."antivirus.dat";
		$this->dataOfFileAlert = ROOT_DIR_SERVICE."dataOfFileAlerts.dat";
		$this->currentConfig = $this->GetConfig(true);
		
		//signs
		$this->signsOfInjectionAlerts = array(
			array('regex' => '/(=)[^\n]*((\')|(\-\-)|(\/\*)|(;))/is', 'type' => $this->injectionAlertTypes[0]),
			array('regex' => '/\w*\'or/ixs', 'type' => $this->injectionAlertTypes[0]),
			array('regex' => '/(\')union/ixs', 'type' => $this->injectionAlertTypes[0]),
			array('regex' => '/exec(\s|\+)+(s|x)p\w+/ixs', 'type' => $this->injectionAlertTypes[0]),
		
			array('regex' => '/(`|<\?(php)?).+(`|\?>)/is', 'type' => $this->injectionAlertTypes[1]),
			array('regex' => '/\{\$+\}/is', 'type' => $this->injectionAlertTypes[1]),
		
			array('regex' => '/<[\s\/]*script.*?>/ixs', 'type' => $this->injectionAlertTypes[2]),
                        array('regex' => '/<[\s\/]*link.*?>/ixs', 'type' => $this->injectionAlertTypes[2]),
                        array('regex' => '/<[\s\/]*style.*?>/ixs', 'type' => $this->injectionAlertTypes[2]),
                        array('regex' => '/<[\s\/]*iframe.*?>/ixs', 'type' => $this->injectionAlertTypes[2]),
			array('regex' => '/<\s*\d+.+javascript:.+>/ixs', 'type' => $this->injectionAlertTypes[2]),
                        array('regex' => '/<\s*img.+\.php.+>/ixs', 'type' => $this->injectionAlertTypes[2])
		
			//array('regex' => '', 'type' => $this->injectionAlertTypes[0]),
			//array('regex' => '', 'type' => $this->injectionAlertTypes[0]),
			//array('regex' => '', 'type' => $this->injectionAlertTypes[0]),
			//array('regex' => '', 'type' => $this->injectionAlertTypes[0])
		);
		
		if($this->enable){
            $this->SendAlerts($this->currentConfig);
        } 
    }
    
    public function Run($force_start = false){
        if(!$this->enable)
            return;
       $command = false;
       if($force_start)
			if(!$this->Check())
				$command ="force_start";
			else
				return;	
       $conveyer = new Conveyers("antivirus", $command);
       $site_url = defined("SITE_URL_WITHOUT_LANGUAGE")?SITE_URL_WITHOUT_LANGUAGE:SITE_URL;
       $conveyer->Run($site_url."cron/conveyers/antivirus/minor.php", (!$force_start)?array($this, "ExecAlertHandlers"):false);
    }
    
    public function Stop(){
        $conveyer = new Conveyers("antivirus", "console");
        $conveyer->ExecCommand("end");
    }
    
    public function ExecAlertHandlers(){
        foreach($this->alertHandlers as $val){
            $this->$val();
        }
    }
    
    public function InternalChecking(){
        if($this->enable and !$this->Check)
        {
            $this->AddAlerts("Сбой в работе антивируса.");
            $this->errorHandlerObject->Push(ERROR_HANDLER_WARNING, 1, "Сбой в работе антивируса");
        }
    }
    
	public function Enable($enabled){
		$this->enable = $enabled;
		if(!$this->currentConfig)
			$this->currentConfig = $this->GetConfig(true);
	}
	
    public function ShowAlerts($config = false){
        if(!$config)
             $config = $this->currentConfig;
		$result = "";
		
		if($config['alerts']){
			$this->tpl->add_var("alerts", $config['alerts']);
			$result =  $this->tpl->fetch("antivirus_show_alerts");
		}
        return $result;
    }
    
    public function AddAlert($string, $time, $file = ""){
        if(!$string)
            return;  
       fclose(fopen($this->configFile, "a+"));
       $fp = fopen($this->configFile, "r+");
	   if(!$fp){
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
	   }
       flock($fp, LOCK_EX);
       $data = "";
       while(!feof($fp))
            $data .= fread($fp, 100000);
       @$data = unserialize($data);
       if(!$data){
           flock($fp, LOCK_UN); 
           $data = $this->GetConfig();
           flock($fp, LOCK_EX);
       }
       
       $data['alerts'][] = array("string" => $string, "time" => $time, "file" => $file);
       
       ftruncate($fp, 0);
       fseek($fp, 0);
       fwrite($fp, serialize($data));
       fflush($fp);
       flock($fp, LOCK_UN); 
       fclose($fp);
    }
  
	public function GetAlerts($newOnly = false)
	{	
		$alerts = $this->antivirus->GetConfig($newOnly);
		$alerts = $alerts['alerts'];
		return $alerts;
	}
	
    public function SendAlerts($config = false, $force = false){
        if(!$config)
             $config = $this->GetConfig(true);
		
        if(((time() - $config['config']['last_sending_time']) < $this->sendingInterval) and !$force)
            return;
        
        $alerts = $config['alerts'];
        if($alerts){
			$string = "";
            $count = 0;
			$fileCount = 0;
			
			$files = array();
			
            foreach($alerts as $val){
				 $count++;
                 $string .= ("[".date("d-m-Y H:i:s", $val['time'])."]".(($val['file'] and file_exists($val['file']))?"[file_".$fileCount."]":"").$val['string']."**del**");
				 if($val['file'] and file_exists($val['file']))
					$files['file_'.($fileCount++)] = $val['file'];		
			}
			$sendInfo = SendInfoToDev("antivirus", array("lastAlerts" => $string), $files);
             
			if(isset($sendInfo['code']) and ($sendInfo['code'] == 500))
				return $sendInfo;
			 
            if(!$this->errorHandlerObject->GetNumErrors() and ($sendInfo['code'] != 500)){
				$config = $this->GetConfig();
				$config['config']['last_old_pos'] += $count;
				$config['config']['last_sending_time'] = time(); 
				
				if(filesize($this->configFile) > $config['config']['max_config_size'])
					$config = serialize(array("config" => $config['config'], "alerts" => array(), "notices" => array()));
				
                 $fp = fopen($this->configFile, "r+");
				 if(!$fp){
					$fileLine = $this->FileLineCalc();
					$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
				 }
                 flock($fp, LOCK_EX);
                 ftruncate($fp, 0);
                 fseek($fp, 0);
                 fwrite($fp, serialize($config));
				 fflush($fp);
                 flock($fp, LOCK_UN);
                 fclose($fp);
				 
				 if($files)
					foreach($files as $val)
						@unlink(preg_replace("/^(@)/", $val));
            }
        }
    }
    
    public function GetNumNotices($new = false){
		$count = 0;
		if($new){
			$count = $this->GetConfig();
			$count = count($count['notices']);
		}
		else
			$count = count($this->currentConfig['notices']);
        return $count;
    }
    
    public function  GetNotices($new = false){
	 
		if(!$this->enable)
			return array();
		if(!$new) 
			$notices = $this->currentConfig['notices'];
		else{
			$notices = $this->GetConfig();
			$notices = $notices['notices'];
		}
		return $notices;
    }
    
    public function AddNotice($string, $action, $add = false){
       if(!$string or !$action)
            return;  
	   $this->DeleteNotice($action);
       fclose(fopen($this->configFile, "a+"));
       $fp = fopen($this->configFile, "r+");
	   if(!$fp){
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
		}
       flock($fp, LOCK_EX);
       $data = "";
       while(!feof($fp))
            $data .= fread($fp, 100000);
       @$data = unserialize($data);
       if(!$data){
           flock($fp, LOCK_UN); 
           $data = $this->GetConfig();
           flock($fp, LOCK_EX);
       }
       
       $data['notices'][] = array("string" => $string, "action" => $action, "add" => $add);
       
       ftruncate($fp, 0);
       fseek($fp, 0);
       fwrite($fp, serialize($data));
       fflush($fp);
       flock($fp, LOCK_UN); 
       fclose($fp);
    }
	
	public function DeleteNotice($action){
		if(!$action)
			return;
	   fclose(fopen($this->configFile, "a+"));
       $fp = fopen($this->configFile, "r+");
	   if(!$fp){
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
	   }
       flock($fp, LOCK_EX);
       $data = "";
       while(!feof($fp))
            $data .= fread($fp, 100000);
       @$data = unserialize($data);
       if(!$data){
           flock($fp, LOCK_UN); 
           $data = $this->GetConfig();
           flock($fp, LOCK_EX);
       }
	   $notices = $data['notices'];
	   $newArr = array();
	   foreach($notices as $notice)
			if($notice['action'] != $action)
				$newArr[] = $notice;
	   $data['notices'] = $newArr;
		ftruncate($fp, 0);
		fseek($fp, 0);
		fwrite($fp, serialize($data));
        fflush($fp);
		flock($fp, LOCK_UN); 
		fclose($fp);
	}
    
    private function Check(){
        $conveyer = new Conveyers("antivirus", "console");
        return $conveyer->ExecCommand("check");
    }
    
    private function GetConfig($newOnly = false){
		if(!$this->enable){
			return array(
                "config" => array("last_old_pos" => 0, "last_sending_time" => time() - $this->sendingInterval - 1, "max_config_size" => 1024*1024),
                "alerts" => array(),
				"notices" => array()
            );
		}
        fclose(fopen($this->configFile, "a+"));
        $fp = fopen($this->configFile, "r+");
		if(!$fp){
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
		}
        flock($fp, LOCK_SH);
        $data = "";
        while(!feof($fp))
            $data .= fread($fp, 100000);
        flock($fp, LOCK_UN);
        @$data = unserialize($data);
        if(!$data)
        {
            $data = array(
                "config" => array("last_old_pos" => 0, "last_sending_time" => time() - $this->sendingInterval - 1, "max_config_size" => 1024*1024),
                "alerts" => array(),
				"notices" => array()
            );
            flock($fp, LOCK_EX);
            ftruncate($fp, 0);
            fseek($fp, 0);
            fwrite($fp, serialize($data));
			fflush($fp);
            flock($fp, LOCK_UN);
        }
        fclose($fp);
            
        $alerts = array();
			foreach($data['alerts'] as $key => $val){
				if($newOnly){
					if($key >= $data['config']['last_old_pos'])
						$alerts[] = $val;
				}
				else{
					$alerts[] = $val;
				}
			}
        
        return array("config" => $data['config'], "alerts" => $alerts, "notices" => $data['notices']);
    }
    
    public function IsEnabled(){
        return $this->enable;
    }
    
	//alertHandlers
	//fileAlert
	public function fileAlert($addAllowed = array()){
		$interval = $this->fileAlertInterval;
		if(!$addAllowed and ((time() - $this->settings->last_file_alert_scan) <= ($interval)))
			return;
		
		//scan
		$data = $this->fileAlertScan(strtr($_SERVER['DOCUMENT_ROOT'], "\\", "/"), array('no_exts' => $this->allowedExtensions));
		//end scan

        $fp = fopen($this->dataOfFileAlert, "a+");
		if(!$fp){
			$fileLine = $this->FileLineCalc();
			$this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 8, "Ошибка открытия файла", $fileLine[0], $fileLine[1]);
		}
        $readData = "";
        while(!feof($fp))
            $readData .= fread($fp, 100000);
        @$readData = unserialize($readData);
		
        if(!$readData or $addAllowed)
        {	
			if($addAllowed)
				if($readData)
					$data = array_merge($readData, $addAllowed);
				else
					$data = array_merge($data, $addAllowed);
            ftruncate($fp, 0);
            fseek($fp, 0);
            fwrite($fp, serialize($data));
        }
		else
		{
			$difference = array();
			foreach($data as $val1)
			{
				$cmpFlag = false;
				foreach($readData as $val2)
					if($val1 == $val2)
					{
						$cmpFlag = true;
						break;
					}
				if(!$cmpFlag)
					$difference[] = $val1;
			}
			if($difference)
			{
				//Alert!!!
				$this->AddNotice("Возможно обнаружена угроза в файловой системе", "file_alert", $difference);
			}
		}
        fclose($fp);
		
		$this->settings->update_settings(array('last_file_alert_scan' => time()));
	}
	
	private function fileAlertScan($dir, $filters = array()){
		$files = array();
		$relRootDir = str_replace($_SERVER['DOCUMENT_ROOT'], "", $dir);
		
		$rpCache = realpath(CACHE_DIR);
		$rpImg = realpath(ROOT_DIR_IMAGES);
		$rpFiles = realpath(ROOT_DIR_FILES);
		$rpService = realpath(ROOT_DIR_SERVICE);
		
		@$dp = opendir($dir);
		if($dp){
			while(($file = readdir($dp)) !== false){
				if(($file == ".") or ($file == ".."))
					continue;
				
				$real_path = realpath($dir."/".$file);
				if(is_dir($dir."/".$file)){
						$newArr = array();
						
						if($real_path == $rpCache){
							$newArr = array("name" => ((file_exists(CACHE_DIR.'.htaccess'))?$relRootDir.'/.htaccess':''), "hash" => (file_exists(CACHE_DIR.'.htaccess'))?md5_file(CACHE_DIR.'.htaccess'):'', "size" => "1");
						}
						else if(($real_path == $rpImg) or
								($real_path == $rpFiles) or
								($real_path == $rpService)){
							$newArr = $this->fileAlertScan($real_path, array_merge($filters, array('exts' => $this->forbiddenExtensions)));
						}
						else{ 
							$newArr = $this->fileAlertScan($dir."/".$file, $filters);
						}
				  
						$files = array_merge($files, $newArr);
				}
				else
				{
					
					if(isset($filters['exts']) and $filters['exts']){
						$ext = pathinfo($dir."/".$file, PATHINFO_EXTENSION);
						if(!in_array($ext, $filters['exts']))
							continue;
					}
					if(isset($filters['no_exts']) and $filters['no_exts']){
						$ext = pathinfo($dir."/".$file, PATHINFO_EXTENSION);
						if(in_array($ext, $filters['no_exts']))
							continue;
					}	
					
					$size = filesize($dir."/".$file);
					$files [] = array("name" => $relRootDir."/".$file, "hash" => ($size < 10485760)?md5_file($dir."/".$file):"", "size" => $size);
				}
			}
			closedir($dp);
		}
		
		return $files;
	}
	
	//endFileAlert
	
	//injectionAlert
	public function add_injection_alert($injection){
		return $this->db->query("INSERT INTO ?_".$this->injectionAlertsTable." (?#) VALUES (?a)", array_keys($injection), array_values($injection));
	}
	
	public function get_injection_alerts($filter = array()){
		$limit = "";
		$where = "";
		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}
		
		if(isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."i.id IN (".implode(",", $filter['in_ids']).")";
		}
		
		return $this->db->select("SELECT i.*
				FROM ?_".$this->injectionAlertsTable." i ".$where." ORDER BY time ASC "
				.$limit);
	}
	
	public function get_num_injection_alerts($filter = array()){
		return $this->db->selectCell("SELECT COUNT(i.id)
				FROM ?_".$this->injectionAlertsTable." i");
	}
	
	public function delete_injection_alerts($ids = array(), $clearFlag = false){
		if($ids)
			$this->db->query("DELETE FROM ?_".$this->injectionAlertsTable." WHERE id IN(?a)", $ids);
		else if($clearFlag){
			$this->db->query("TRUNCATE ?_".$this->injectionAlertsTable);
		}
	}
	
	public function ScanInjectionAlerts(){
		if(!$this->enable)
			return;
		if(!$this->requestData){
			$this->requestData['post'] = $_POST;
			$this->requestData['get'] = $_GET;
			$this->requestData['cookie'] = $_COOKIE;
			return;
		}
		//scan 
		if((defined("ADMINS_HAT") and ADMINS_HAT) or defined("IS_ADMIN"))
			return;
		$url = F::url($_SERVER['HTTP_HOST'].$_SERVER['SCRIPT_NAME'].(($_SERVER['QUERY_STRING'])?"?":"").$_SERVER['QUERY_STRING']);
		//$url2 = (isset($this->requestData['get']['router_page']) and $this->requestData['get']['router_page'])?$this->requestData['get']['router_page']:"";
		$ip = $_SERVER['REMOTE_ADDR'];
		
		foreach($this->requestData as $objectType => $data)
			if(is_array($data))
			foreach($data as $key => $val)
				foreach($this->signsOfInjectionAlerts as $sign)
					if(preg_match($sign['regex'], (string) $val)){
						//alert!!!
						$this->add_injection_alert(array(
								'ip' => $ip,
								'object' => '$_'.strtoupper($objectType)."['".$key."']",
								'type' => $sign['type'],
								'time' => time(),
								'url' => substr($url, 0, 255),
								'content' => addslashes($val),
								'used_regexp' => addslashes($sign['regex'])
							));

						$this->AddNotice("Замечание", 'injection_alert');
						break;
					}
			
	}
	//endinjectionAlert
	//endHandlers
   
    private $enable = false;
    private $configFile;
	private $currentConfig;
    private $alertHandlers = array('fileAlert');
    private $sendingInterval = 1800;
	
	
	//variables of alertHandlers
	//fileAlert
	private $dataOfFileAlert;
	private $fileAlertInterval = 3600; 
	private $forbiddenExtensions = array("php", "js", "bin", "cgi", "csh", "hta", "jar", "plx", "pl", "pyc", "pyo");
	private $allowedExtensions = array("jpg", "png", "gif", "bmp", "xml");
	//injectionAlert
	private $injectionAlertsTable = "injection_alerts";
	private $requestData = false;
	private $injectionAlertTypes = array("SQL инъекция", "PHP внедрение", "через XSS");
	private $signsOfInjectionAlerts;
}
?>