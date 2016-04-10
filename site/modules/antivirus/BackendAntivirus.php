<?php
/**
 * класс отображения интерфейса антивируса в административной части сайта
 * @author tim
 *
 */

class BackendAntivirus extends View {
	public function index() {
		if($this->admins->get_level_access('antivirus') != 2) return;
		
		$enabled = $this->settings->antivirus_enabled;
		$tab_active = "status";
		$may_noupdate_form = true;
		$sendInfo = array();
		
		if($this->request->method('get') and $this->request->get("flag", "integer"))
		{	
			$tab_active =  $this->request->post("tab_active", "string");
			
			$enabled = $this->request->get("enabled", "integer");
			$send = $this->request->get("send", "integer");
			$this->settings->update_settings(array("antivirus_enabled" => $enabled));
			$this->antivirus->Enable($enabled);
			if($enabled and $this->request->get("flag", "integer")){
				$this->antivirus->Run(true);
			}
			else if($this->request->get("flag", "integer"))
				$this->antivirus->Stop();
			
			if($send){
				$sendInfo = $this->antivirus->SendAlerts(false, true);
			}
		}
		
		
		$this->tpl->add_var('sendInfo', $sendInfo);
		$this->tpl->add_var('alerts', $this->antivirus->GetAlerts(true));
		$this->tpl->add_var('enabled', $enabled);
		$this->tpl->add_var('tab_active', $tab_active);
		return $this->tpl->fetch('antivirus_status');
	}
	
	public function file_alert($sendInfo = array()){
		if($this->admins->get_level_access('antivirus') != 2) return;

		$notices = $this->antivirus->GetNotices(true);
		$tab_active = "main";
		$difference = array();
		if($this->antivirus->IsEnabled())
			foreach($notices as $val){
				if($val['action'] == 'file_alert')
					$difference = $val['add'];
			}	

		$this->tpl->add_var('sendInfo', $sendInfo);
		$this->tpl->add_var('difference', $difference);
		$this->tpl->add_var('tab_active', $tab_active);
		return $this->tpl->fetch('antivirus_handler_fileAlert');
	}
	
	public function injection_alert($sendInfo = array()){
		if($this->admins->get_level_access('antivirus') != 2) return;

		$notices = $this->antivirus->GetNotices(true);
		$tab_active = "main";
		$notice = false;
		if($this->antivirus->IsEnabled())
			foreach($notices as $val){
				if($val['action'] == 'injection_alert'){
					$notice = true;
				}
			}
		
		$paging_added_query = "&action=injection_alert";

		// Постраничная навигация
		$limit = ($tmpVar = 100) ? $tmpVar : 10;
		// Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);
		
		$link_added_query = "&p=".$p;
	
		$filter["limit"] = array($p, $limit);
		$total_pages_num = ceil(intval($this->antivirus->get_num_injection_alerts($filter))/$limit);

		$injections = $this->antivirus->get_injection_alerts($filter);
				
		$this->tpl->add_var('notice', $notice);
		$this->tpl->add_var('sendInfo', $sendInfo);
		$this->tpl->add_var('injections', $injections);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_added_query', $paging_added_query);
		$this->tpl->add_var('link_added_query', $link_added_query);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		return $this->tpl->fetch('antivirus_handler_injectionAlert');
	}
	
	public function adminLogin_alert($sendInfo = array()){
		if($this->admins->get_level_access('antivirus') != 2) return;
		
		$notices = $this->antivirus->GetNotices(true);
		$tab_active = "main";
		$tryings = array();
		if($this->antivirus->IsEnabled())
			foreach($notices as $val){
				if($val['action'] == 'adminLogin_alert')
					$tryings[] = $val;
			}	

		$this->tpl->add_var('sendInfo', $sendInfo);
		$this->tpl->add_var('tryings', $tryings);
		$this->tpl->add_var('tab_active', $tab_active);
		return $this->tpl->fetch('antivirus_handler_adminLoginAlert');
	}
	
	public function group_actions() {
		$this->admins->check_access_module('antivirus', 2);
		if(!$this->antivirus->IsEnabled())
			return;
		$case = $this->request->post("do_active", "string");
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($case) {
				case "ignore_file_alert": case "tick_files_as_alert":
				$notices = $this->antivirus->GetNotices();
				$notice = $difference = array();
				$sendInfo = array();
				foreach($notices as $val){
					if($val['action'] == 'file_alert'){
						$notice = $val;
						break;
					}
				}
				if(!$notice)
                                   return $this->file_alert($sendInfo);
				$difference = $notice['add'];
					
				$forbidden = array();
				$allowed = array();
				foreach($difference as $key => $val)
					if((($case == "tick_files_as_alert") and in_array($key, $items))){
						$forbidden[] = $val;
					}
					else if((($case == "ignore_file_alert") and in_array($key, $items))){
						$allowed[] = $val;
					}
					
				if($forbidden){
				
					//Alert!!!
					$path = realpath(tempnam(ROOT_DIR_FILES."/tmp/", "an_"));
					$file = "";
					$zip = new zipArchive();
					if(!$zip->open($path, ZIPARCHIVE::CREATE)){
							$this->errorsHandlerObject->Push(ERROR_HANDLER_WARNING, 1, "Не удалось открыть файл для архивации");
					}
					else {
						$count = 0;
						foreach($forbidden as $value){
							if(!file_exists($_SERVER["DOCUMENT_ROOT"]."/".$value['name']))
							continue;
							if(!$zip->addFile($_SERVER["DOCUMENT_ROOT"]."/".$value['name'], './'.$value['name'])){
								$this->errorsHandlerObject->Push(ERROR_HANDLER_WARNING, 2, "Не удалось создать архив.");
								break;
							}
							$count++;
						}
						$zip->close();
						if($count){
							$file = $path;
						}
					}
				
					if(!$this->errorHandlerObject->GetNumErrors()){
						$this->antivirus->AddAlert("Угроза в файловой системе", time(), $path);
						
						$this->antivirus->DeleteNotice('file_alert');
						$arr = array_merge($allowed, $forbidden);
						if(count($arr) < count($difference))
						{
							$newDifference = array();
							foreach($difference as $val1)
							{
								$cmpFlag = false;
								foreach($arr as $val2)
									if($val1 == $val2)
									{
										$cmpFlag = true;
										break;
									}
								if(!$cmpFlag)
									$newDifference[] = $val1;
							}
							$notice['add'] = $newDifference;
							$this->antivirus->AddNotice($notice['string'], $notice['action'], $notice['add']);
						}	
						$this->antivirus->fileAlert($arr);
						
						$sendInfo = $this->antivirus->SendAlerts(false, true);
						if($path and !$this->errorHandlerObject->GetNumErrors() and ($sendInfo['code'] != 500))
							@unlink($path);
					}
				} 
				else if($allowed){
					$this->antivirus->DeleteNotice('file_alert');
					$arr = array_merge($allowed, $forbidden);
					if(count($arr) < count($difference))
					{
						$newDifference = array();
						foreach($difference as $val1)
						{
							$cmpFlag = false;
							foreach($arr as $val2)
								if($val1 == $val2)
								{
									$cmpFlag = true;
									break;
								}
							if(!$cmpFlag)
								$newDifference[] = $val1;
						}
						$notice['add'] = $newDifference;
						$this->antivirus->AddNotice($notice['string'], $notice['action'], $notice['add']);
					}	
					$this->antivirus->fileAlert($arr);
				}

				return $this->file_alert($sendInfo);
				break;
				//next
				case "clearing_of_tryings_into_adminpanel":
					$this->antivirus->DeleteNotice('adminLogin_alert');
					return $this->adminLogin_alert();
				break;
				
				case "ignore_injection_alert": case "tick_injection_as_alert":
					$sendInfo = array();
					if($case == 'ignore_injection_alert'){
						$this->antivirus->delete_injection_alerts($items, false);
					}
					else{
						$injections = $this->antivirus->get_injection_alerts(array('in_ids'=>$items));
						if($injections){
							$text = "//The report has been formated by protection system on ".date("m-d-Y H:i:s")."\n";
							$text .= "//".count($injections)." tryings of injection have been discovered\n\n\n###START REPORT###\n\n";
							
							foreach($injections as $injection){
								$text .= ("###NUMBER OF ITEM: ".$injection['id']."\n
IP: ".$injection['ip']."
Object: ".$injection['object']."
Type: ".$injection['type']."
Time: ".date("m-d-Y H:i:s", $injection['time'])."
Url: ".$injection['url']."
Used regexp: ".$injection['used_regexp']."\n
Content: ".stripslashes($injection['content'])."\n\n"
);
							}
							
							$text .= "\n###END REPORT###";
							
							$file = realpath(tempnam(ROOT_DIR_FILES."/tmp/", "an_"));
							$fp = fopen($file, "wb");
							fwrite($fp, $text);
							fclose($fp);
							$path_archive = realpath(tempnam(ROOT_DIR_FILES."/tmp/", "an_"));
							$zip = new zipArchive();
							if(!$zip->open($path_archive, ZIPARCHIVE::CREATE)){
								$this->errorsHandlerObject->Push(ERROR_HANDLER_WARNING, 1, "Не удалось открыть файл для архивации");
							}
							if(!$zip->addFile($file, './report.txt')){
								$this->errorsHandlerObject->Push(ERROR_HANDLER_WARNING, 2, "Не удалось создать архив.");
							}
							$zip->close();
							@unlink($file);
							
							if(!$this->errorHandlerObject->GetNumErrors()){
								$this->antivirus->AddAlert("Попытка атаки посредством инъекции.", time(), $path_archive);
								
								$this->antivirus->delete_injection_alerts($items, false);
								
								$sendInfo = $this->antivirus->SendAlerts(false, true);
							}
							
							if(!$this->errorHandlerObject->GetNumErrors() and ($sendInfo['code'] != 500)){
								@unlink($path_archive);
							}
						}
					}
					
					if(!$this->antivirus->get_num_injection_alerts())
						$this->antivirus->DeleteNotice('injection_alert');
						
					return $this->injection_alert($sendInfo);
				break;
				
				//next cases
			}
		}
		
		if(($case == 'ignore_injection_alert') or ($case == "tick_injection_as_alert") or ($case == "ignore_injection_all_alert")){
			if($case == "ignore_injection_all_alert"){
				$this->antivirus->delete_injection_alerts(false, true);
				$this->antivirus->DeleteNotice('injection_alert');
			}	
			return $this->injection_alert();
		}
		else
			return $this->file_alert();
	}
}
?>