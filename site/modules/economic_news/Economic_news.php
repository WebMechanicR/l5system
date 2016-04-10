<?php

include dirname(dirname(dirname(__FILE__))).'/classes/external/simple_html_dom.php';
include dirname(dirname(dirname(__FILE__))).'/classes/external/RollingCurl.class.php';

class Economic_news extends Module {

	protected $module_name = "economic_news";
	public $module_table = "calendar_news";
        public $module_table_countries = "countries";
        private $module_table_events = "economic_calendar_events";
        
	private $module_nesting = false; //возиожность владывать подстраницы в модуль
	private $curl;
        private $agent;
        private $cookie;
        
        public function __construct(){
            
            parent::__construct();
            
            $this->curl = new RollingCurl(null);
            $agents = $this->load_agents_from_file(dirname(dirname(dirname(__FILE__))).'/classes/external/useragent_list.txt');
            if($agents){
                $count = 0;
                do{
                    shuffle($agents);
                    $this->agent = $agents[0];
                    $count++;
                }while(!$this->agent && $count < 10);
            }
            $cookieName = strtr(ROOT_DIR_SERVICE . "/cookie.txt", "\\", "/");
            if(!file_exists($cookieName))
                fclose(fopen($cookieName, 'a+'));
            $this->cookie = $cookieName;
        }
        
	public function add_calendar_news($calendar_news) {
		//чистим кеш
		$this->cache->clean("list_calendar_news");
		return $this->db->query("INSERT INTO ?_".$this->module_table." (?#) VALUES (?a)", array_keys($calendar_news), array_values($calendar_news));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update_calendar_news($id, $calendar_news) {
		
		if(isset($calendar_news['date_add'])) {
			$old_calendar_news = $this->get_calendar_news($id);
			if($calendar_news['date_add']!=$old_calendar_news['date_add'] or $calendar_news['enabled']!=$old_calendar_news['enabled']) $this->cache->clean("list_calendar_news");
		}

		//чистим кеш
		if(is_array($id)) {
			$cache_tags = array();
			foreach($id as $one_id) {
				$cache_tags[] = "calendar_newsid_".$one_id;
			}
			if(isset($calendar_news['enabled'])) $cache_tags[] = "list_calendar_news";
			$this->cache->clean($cache_tags);
		}
		else {
			$this->cache->clean("calendar_newsid_".$id);
		}

		if($this->db->query("UPDATE ?_".$this->module_table." SET ?a WHERE id IN (?a)", $calendar_news, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete_calendar_news($id){
		$calendar_news = $this->get_calendar_news($id);

		$this->db->query("DELETE FROM ?_".$this->module_table." WHERE id=?", $id);

		$this->cache->clean(array("calendar_newsid_".$id, "list_calendar_news"));

	}

        public function get_calendar_news($id) {
		$where_field = "id";
		
		return $this->db->selectRow("SELECT * FROM ?_".$this->module_table." WHERE ".$where_field."=?", $id);
	}
        
        /**
	 * возвращает новости удовлетворяющие фильтрам
	 * @param array $filter
	 */
	public function get_list_calendar_news($filter=array()) {
		$sort_by = " ORDER BY n.matched_with DESC, n.is_approved ASC, n.id ASC";
		$limit = "";
		$where = "";
                
		if(isset($filter['sort']) and count($filter['sort'])==2) {
			if($filter['sort'][0]=='find_in_set' and isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {

				$new_in_ids = array();
				//выбираем id из списка только те, которые попадают на страницу, чтобы не сортировать при запросе лишнее
				for($i=($filter['limit'][0]-1)*$filter['limit'][1]; $i<(($filter['limit'][0]-1)*$filter['limit'][1]+$filter['limit'][1]); $i++) {
					if(!isset($filter['in_ids'][$i])) break;
					$new_in_ids[] = $filter['in_ids'][$i];
				}
				$filter['in_ids'] = $new_in_ids;
				$sort_by = " ORDER BY FIND_IN_SET(n.id, '".implode(",", $new_in_ids)."')";
				$filter['limit'] = array(1, $filter['limit'][1]);
			}
			else if($filter['sort'][0] != 'announcement'){
				if(!in_array($filter['sort'][0], array("name", "date_add", "enabled", "num_events", 'is_approved', 'matched_with'))) $filter['sort'][0] = "date_add";
				if(!in_array($filter['sort'][1], array("asc", "desc")) ) $filter['sort'][1] = "desc";
				$sort_by = " ORDER BY n.".$filter['sort'][0]." ".$filter['sort'][1];
			}
		}
                
		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}

		if(isset($filter['enabled'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.enabled=".intval($filter['enabled']);
		}

		if(isset($filter['notid'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id!=".intval($filter['notid']);
		}
                
                if(isset($filter['name'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.name LIKE'%".$filter['name']."%'";
		}

		if(isset($filter['date_add']) and count($filter['date_add'])==2) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add".($filter['date_add'][0]==0 ? "<" : ">")."=".intval($filter['date_add'][1]);
		}

		return $this->db->select("SELECT n.*
				FROM ?_".$this->module_table." n".$where
				.$sort_by.$limit);
	}

	/**
	 * возвращает количество новостей удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_count_calendar_news($filter=array()) {
		$where = "";

		if(isset($filter['enabled'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.enabled=".intval($filter['enabled']);
		}

		if(isset($filter['notid'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id!=".intval($filter['notid']);
		}

		if(isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id IN (".implode(",", $filter['in_ids']).")";
		}

		if(isset($filter['date_add']) and count($filter['date_add'])==2) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add".($filter['date_add'][0]==0 ? "<" : ">")."=".intval($filter['date_add'][1]);
		}
                
                if(isset($filter['name'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.name LIKE'%".$filter['name']."%'";
		}

		return $this->db->selectCell("SELECT count(n.id)
				FROM ?_".$this->module_table." n".$where);
	}
        
        public function get_full_list_events($filter=array()) {
		$sort_by = " ORDER BY n.moment DESC, n.id DESC";
		$limit = "";
		$where = "";
                
		if(isset($filter['limit']) and count($filter['limit'])==2){
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}

		if(isset($filter['date_from'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.moment >= ".$filter['date_from'];
		}
		
		if(isset($filter['date_to']) and $filter['date_to'] > 0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.moment <= ".$filter['date_to'];
		}
                
                if(isset($filter['unmatched']) and $filter['unmatched']){
                        $where .= (empty($where) ? " WHERE " : " AND ")."(SELECT COUNT(*) FROM ?_".$this->module_table_events." AS n3 WHERE n3.news_id = n.news_id AND "
                                . "((n3.act = 'positive' AND n3.st_act = 'negative') OR (n3.act = 'negative' AND n3.st_act = 'positive'))) > 2";
                }

		return $this->db->select("SELECT n.*, n2.name AS news_name, n2.currency AS news_currency
				FROM ?_".$this->module_table_events." n LEFT JOIN ?_".$this->module_table." n2 ON n2.id = n.news_id ".$where
				.$sort_by.$limit);
	}

	/**
	 * возвращает количество новостей удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_full_count_events($filter=array()) {
		$where = "";

		if(isset($filter['date_from'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.moment >= ".$filter['date_from'];
		}
		
		if(isset($filter['date_to']) and $filter['date_to'] > 0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.moment <= ".$filter['date_to'];
		}
                
                if(isset($filter['unmatched']) and $filter['unmatched']){
                        $where .= (empty($where) ? " WHERE " : " AND ")."(SELECT COUNT(*) FROM ?_".$this->module_table_events." AS n3 WHERE n3.news_id = n.news_id AND "
                                . "((n3.act = 'positive' AND n3.st_act = 'negative') OR (n3.act = 'negative' AND n3.st_act = 'positive'))) > 2";
                }

		return $this->db->selectCell("SELECT count(n.id)
				FROM ?_".$this->module_table_events." n".$where);
	}
        
	public function is_nesting() {
		return $this->module_nesting;
	}
        
        protected function load_agents_from_file($filename, $delim = "\n")
        {
            $data;
            $fp = @fopen($filename, "r");

            if(!$fp)
            {
                return array();
            }

            $data = @fread($fp, filesize($filename) );
            fclose($fp);

            if(strlen($data)<1)
            {
                return array();
            }

            $array = explode($delim, $data);

            if(is_array($array) && count($array)>0)
            {
                foreach($array as $k => $v)
                {
                    if(strlen( trim($v) ) > 0)
                        $array[$k] = trim($v);
                }
                return $array;
            }
            else
            {
                return array();
            }
        }
        
        public function get_news_by_news($news){
            return $this->db->selectRow("SELECT * FROM ?_".$this->module_table." WHERE (name = ? OR alternative_names LIKE '%||".addslashes($news['name'])."||%') AND "
                    . "country = ? AND currency = ?",$news['name'], $news['country'], $news['currency']);
        }
        
        public function get_event($news_id, $timestamp){
            return $this->db->selectRow("SELECT * FROM ?_".$this->module_table_events. " WHERE news_id = ? AND moment = ?", $news_id, $timestamp);
        }
        
        public function get_event_by_id($id){
           return $this->db->selectRow("SELECT * FROM ?_".$this->module_table_events. " WHERE id = ?", $id); 
        }
        
        public function add_event($event) {
                $this->cache->clean(array("events_list"));
                if(isset($event['news_id'])){
                    $this->db->query("UPDATE ?_".$this->module_table." SET num_events = num_events + 1 WHERE id = ?", $event['news_id']);
                }
		return $this->db->query("INSERT INTO ?_".$this->module_table_events." (?#) VALUES (?a)", array_keys($event), array_values($event));
	}
        
        public function update_event($id, $event){
            $this->cache->clean(array("eventid_".$id));
            if($old = $this->get_event_by_id($id) and isset($event['news_id']) and $event['news_id'] != $old['news_id']){
                    $this->db->query("UPDATE ?_".$this->module_table." SET num_events = num_events - 1 WHERE id = ?", $old['news_id']);
                    $this->db->query("UPDATE ?_".$this->module_table." SET num_events = num_events + 1 WHERE id = ?", $event['news_id']);
            }
            $this->db->query("UPDATE ?_".$this->module_table_events." SET ?a WHERE id = ?", $event, $id);
        }
        
        public function get_list_events($filter=array()) {
		$where = "";
                
		if(isset($filter['news_id']) and $filter['news_id']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."news_id=".intval($filter['news_id']);
		}
                
                if(isset($filter['moment']) and $filter['moment']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."moment=".intval($filter['moment']);
		}
                
                if(isset($filter['for_statistic']) and $filter['for_statistic']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."happened=1 AND ".(isset($filter['curtime'])?$filter['curtime']:time())." - moment >= 3600 * 2";
		}

		return $this->db->select("SELECT *
				FROM ?_".$this->module_table_events.$where. " ORDER BY moment DESC");
	}
        
        public function delete_event($id){
                $this->cache->clean(array("eventid_".$id));
                if($old = $this->get_event_by_id($id)){
                    $this->db->query("UPDATE ?_".$this->module_table." SET num_events = num_events - 1 WHERE id = ?", $old['news_id']);
                }
		$this->db->query("DELETE FROM ?_".$this->module_table_events." WHERE id=?", $id);
	}
        
        public function get_current_events($acurtime = 0){
            $curtime = $acurtime?$acurtime:time();
            return $this->db->query("SELECT * FROM ?_".$this->module_table_events." WHERE (ABS(".$curtime." - moment) < 1600 OR (happened = 0 AND ABS(".$curtime." - moment) < 1800)) ".($acurtime?" AND moment < $curtime":'')." ORDER BY moment DESC");
        }
        
        public function get_nearest_event_moment(){
            return $this->db->selectCell("SELECT MIN(moment - ".time().") FROM ?_".$this->module_table_events." WHERE moment - ".time()." >= 0");
        }
        
        public function parse_calendar(){
            $recommended_query_time = intval($this->settings->recommended_query_time_for_calendar_news);
            $curtime = time();
            
            if($curtime - $recommended_query_time >= 0 and $curtime - $this->settings->last_time_of_request_of_calendar_news >= 4){
                $recommended_query_time = 0;
                //refreshing
                list($result, $time_of_day_end) = $this->get_calendar_news_list_for_current_day();
                $this->settings->update_settings(array('num_requests_of_calendar_news' => (int) $this->settings->num_requests_of_calendar_news + 1));
                $this->settings->update_settings(array('last_time_of_request_of_calendar_news' => (int) $curtime));
                
                if($result){
                    $control_name = "";
                    foreach($result as $news){
                        if($news['is_delayed'] and $curtime - $news['time'] > 1800)
                            $news['is_delayed'] = false;
                        
                        if(!$recommended_query_time){
                            if($curtime - $news['time'] < 0 || $news['is_delayed']){
                                $recommended_query_time = $news['time'] - 33;
                            }
                        }
                        $control_name .= ($news['name'].' '.$news['currency']);
                    }
                    $control_name = md5($control_name);
                    
                    if($time_of_day_end < $recommended_query_time or !$recommended_query_time){
                        $recommended_query_time = $time_of_day_end - 120;
                        if($this->settings->num_requests_of_calendar_news % 7 == 0){
                            $recommended_query_time = $curtime + 180;
                        }
                    }
                   
                    if($this->settings->control_name_of_calendar_news != $control_name){
                        $economic_calendar_news = $this->get_list_calendar_news();
                        $added_news = 0;
                        
                        foreach($result as $news){
                            $max_ = 0;
                            $suitable_i = -1;
                            foreach($economic_calendar_news as $i => $existing_news){
                                 if($existing_news['currency'] != $news['currency'] or $existing_news['country'] != $news['country'])
                                     continue;
                                 $names = (array) explode("||", preg_replace('(^\|\||\|\|$)', "", $existing_news['alternative_names']));
                                 $names[] = $existing_news['name'];
                                 $m = 0;
                                 foreach($names as $n){
                                    similar_text(mb_strtolower($n), mb_strtolower($news['name']), $l);
                                    if($l > $m)
                                        $m = $l;
                                 }
                                    
                                 if($max_ < $m){
                                     $max_ = $m;
                                     $suitable_i = $i;
                                 }
                            } 
                            
                            $match = false;
                            $news_id = 0;
                            if($max_ == 100){
                                $match = true;
                                $news_id = $economic_calendar_news[$suitable_i]['id'];
                            }
                            else if($max_ > 85){
                                $news['matched_with'] = $economic_calendar_news[$suitable_i]['id'];
                            }
                            
                            if(!$match){
                                //adding
                                $new_news = array(
                                    'name' => $news['name'],
                                    'name_in_source' => $news['name_in_source'],
                                    'source' => $news['source'],
                                    'act_applying_method' => 'such',
                                    'matched_with' => isset($news['matched_with'])?$news['matched_with']:0,
                                    'currency' => $news['currency'],
                                    'country' => $news['country'],
                                    'date_add' => time(),
                                    'last_theoretical_strong' => $news['theoretical_strong'],
                                    'last_event_moment' => $news['time']
                                );
                                $news_id = $this->add_calendar_news($new_news);
                                $added_news++;
                            }
                            else{
                                $this->update_calendar_news($news_id, array('last_theoretical_strong' => $news['theoretical_strong'], 'last_event_moment' => $news['time']));
                            }
                        }
                        
                        if($added_news){
                                $this->tpl->add_var('added_news', $added_news);
				$this->tpl->in_user();
				$html_mail_user = $this->tpl->fetch("mail/economic_news_new_calendar_news");
				$this->mail->send_mail(array($this->settings->site_email, "Администратору"), "Новые экономические новости - ".$this->settings->site_title, $html_mail_user);
				$this->tpl->in_admin();
                        }
                        
                        $this->rebuild_forecast();
                        $this->settings->update_settings(array('control_name_of_calendar_news' => $control_name));
                    }
                    
                    //register events
                    foreach($result as $news){
                        if(abs($curtime - $news['time']) <= 60 || $news['is_delayed']){
                            $db_news = $this->get_news_by_news($news);
                            if(!$db_news){
                                $this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 0, "News is not found in registration of event of ".$news['name']);
                                continue;
                            }
                            $old_event = $this->get_event($db_news['id'], $news['time']);
                            if($old_event and $old_event['happened'])
                                continue;
                            
                            $event = array('moment' => $news['time'], 'news_id' => $db_news['id'], 'currency' => $news['currency']);
                            $event['strength'] = intval($news['theoretical_strong']);
                            if((!$news['is_delayed'] or ($news['is_delayed'] and $curtime - $news['time'] > 1800)) and $curtime - $news['time'] >= 0)
                                $event['happened'] = 1;
                            /*
                             * Catches too early
                             * TO DO
                             */
                            $event['act'] = $news['theoretical_act'];
                            if($news['act_defining_method'] != 'with_forecast_strict_defined'){
                                if($db_news['act_applying_method'] == 'against'){
                                    if($event['act'] == 'positive')
                                        $event['act'] == 'negative';
                                    else if($event['act'] == 'negative')
                                        $event['act'] = 'positive';
                                }
                                else if($db_news['act_applying_method'] == 'indefinite'){
                                    $event['act'] = 'neutral';
                                }
                                else if($db_news['act_applying_method'] == 'more_indefinite'){
                                    $event['act'] = 'unknown';
                                }
                            }
                            
                            if(!$old_event)
                                $this->add_event($event);
                            else 
                                $this->update_event($old_event['id'], $event);
                        }
                    }
                }
                else if($this->settings->num_requests_of_calendar_news % 7 == 0)
                    $recommended_query_time = $curtime + 7 * 60;
                
                if($recommended_query_time - $curtime >= 3600)
                    $recommended_query_time = $curtime + 3600;
                
                $this->settings->update_settings(array('recommended_query_time_for_calendar_news' => $recommended_query_time));
            }
        } 
        
        public function get_forecast(){
            @$forecast = unserialize($this->settings->events_schedule);
            return $forecast;
        }
        
        public function rebuild_forecast($is_for_testing = false, $curtime){
            $this->cache->clean("forecast");
            
            if(!$is_for_testing)
                $curtime = time();
            
            $scedule = array();
            $news_list = array();
            if(!$is_for_testing)
                $news_list = $this->db->select("SELECT * FROM ?_".$this->module_table." WHERE ".$curtime." - last_event_moment <= 70000");
            else {
                $news_list = $this->db->select("SELECT n.*, m.moment AS last_event_moment FROM ?_".$this->module_table." n, ?_".$this->module_table_events." m"
                        . " WHERE ".$curtime." - m.moment <= 70000 AND n.id = m.news_id");
            }
            if ($news_list) {
                foreach($news_list as $news){
                    $news_id = $news['id'];
                    $filter = array('news_id' => $news_id, 'for_statistic' => 1);
                    if($is_for_testing)
                        $filter['curtime'] = $curtime;
                    $events_statistic = $this->get_list_events($filter);
                    $currencies = array();
                    $strength = 0;
                    $strength_count = 0;
                    $st_act = "";
                    $last_moment = 0;
                    if ($events_statistic) {
                        foreach ($events_statistic as $ev) {
                            if ($ev['st_currency'] and !in_array($ev['st_currency'], $currencies))
                                $currencies[] = $ev['st_currency'];
                            $strength += $ev['st_strength'];
                            $strength_count++;
                            if ($ev['st_act'] and (!$last_moment or $last_moment < $ev['moment']))
                            {    
                                $st_act = $ev['st_act'];
                                $last_moment = $ev['moment'];
                            }
                        }
                    }
                    $strength = $strength_count == 0 ? 0 : $strength / $strength_count;
                    
                    $currency = "";
                    if ($currencies) {
                        $currencies = array_count_values($currencies);
                        $max = 0;
                        foreach ($currencies as $cur => $num) {
                            if ($max < $num) {
                                $max = $num;
                                $currency = $cur;
                            }
                        }
                    }
                    
                    $scedule[] = array('news_id' => $news_id, 'moment' => $news['last_event_moment'], 'st_currency' => $currency,
                        'base_currency' => $news['currency'], 'strength' => intval($news['last_theoretical_strong']), 'st_strength' => $strength, 'st_act' => $st_act);
                }
            }
            $this->settings->update_settings(array('events_schedule' => serialize($scedule)));
        }
        
        /*
         * Gets list of news for current day
         * Returns array of events grouping by source
         * @array(name => string, source => string, name_in_source => string, 
         * time => gmttimestamp, country => array(codes), currency => array(codes), theoretical_act => string(positive, negative, neutral, sleep, unknown), theoretical_strong => int percent,
         * act_defining_method => common|with_forecast, is_delayed => true|false)
         */
        public function get_calendar_news_list_for_current_day(){
            $result = array();
            $time_of_last = 2100000000;
            foreach(System::$CONFIG['news_sources'] as $source)
            {
                $source_result = array();
                if($source == 'investing.com'){
                    $url = 'http://investing.com/economic-calendar';

                    $options[CURLOPT_USERAGENT] = $this->agent;
                    $options[CURLOPT_AUTOREFERER] = true;
                    $this->curl->get($url, null, $options);
                    $html = $this->curl->execute();
                    $html = str_get_html($html);
                    if($html){
                        $table = $html->find('table[id=ecEventsTable]', 0);
                        if($table){
                            $rows = $table->find('tr');
                            if($rows)
                                foreach($rows as $row){
                                    if(isset($row->id) and strpos($row->id, 'eventRowId') !== false and isset($row->event_timestamp)){
                                        $is_delayed = false;
                                        $curtime = time() + 3; //time for parsing
                                        $time = strtotime($row->event_timestamp) + (intval(date('Z')));
                                        if(!$time)
                                        {
                                            $this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 0, "Something wrong in parsing of news from ".$source);
                                            continue;
                                        }
                                        
                                        $name_in_source = $this->request->get_str(substr($row->id, strpos($row->id, '_') + 1), 'string');
                                        $currency = $this->request->get_str(mb_strtoupper($this->htmltrim($row->find('td', 1)->plaintext)), 'string');
                                        $country = $this->define_country_code($this->request->get_str($row->find('td', 1)->find('span', 0)->title, 'string'));
                                        if(!$country)
                                        {
                                            $this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 0, "Something wrong in parsing of news from ".$source.". Country ".
                                                    $this->request->get_str($row->find('td', 1)->find('span', 0)->title, 'string')." is not found");
                                            continue;
                                        }
                                        $b = $row->find('td', 2);
                                        $act = 'unknown';
                                        $act_defining_method = 'common';
                                        $strong = 33;
                                        if(stripos($b->plaintext, 'holiday') !== false)
                                        {
                                            $act = 'sleep';
                                        }
                                        else if($icons = $b->find('i.grayFullBullishIcon')){
                                            $strong = 33.333 * count($icons);
                                        }
                                        $name = $row->find('td', 3)->plaintext;
                                        $name = $this->htmltrim(str_replace(array("(Nov)", "(Dec)", "(Jan)", "(Feb)", "(Mar)", "(Apr)", "(May)", "(Jun)", "(Jul)", "(Aug)", "(Sep)", "(Oct)"), "", $name));
                                        $name = $this->htmltrim(str_replace(array("(Q1)", "(Q2)", "(Q3)", "(Q4)"), "", $name));
                                        if(!$name)
                                        {
                                            $this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 0, "Something wrong in parsing of news from ".$source);
                                            continue;
                                        }
                                        $current = $row->find('td', $act=='sleep'?3:4);
                                        if(!$current){
                                            $this->errorHandlerObject->Push(ERROR_HANDLER_NOTICE, 0, "Something wrong in parsing of news");
                                            continue;
                                        }
                                        
                                        $forecast = $this->htmltrim($row->find('td', 5)->plaintext);
                                        $previous = $this->htmltrim($row->find('td', 6)->plaintext);
                                        $revised_from = $this->htmltrim($row->find('td', 7)->plaintext);
                                        $v = "";
                                            if($current->find('span.sandClock'))
                                                $v = "";
                                            else
                                                $v = $this->htmltrim($current->plaintext);
                                            
                                            if($v){
                                                $act_defining_method = 'with_forecast';
                                                if(isset($current->class) and stripos($current->class, 'redFont') !== false){
                                                    $act = 'negative';
                                                    $act_defining_method = 'with_forecast_strict_defined';
                                                }
                                                else if(isset($current->class) and stripos($current->class, 'greenFont') !== false){
                                                    $act = 'positive';
                                                    $act_defining_method = 'with_forecast_strict_defined';
                                                }
                                                else{
                                                    $act = 'neutral';
                                                    $v = floatval(preg_replace('/[^0-9.-]/', '', $v));
                                                    if(!$forecast && $previous){
                                                        $previous = floatval(preg_replace('/[^0-9.-]/', '', $previous));
                                                        $strong /= 6;
                                                        if($previous < $v)
                                                            $act = 'positive';
                                                        else if($previous > $v)
                                                            $act = 'negative';
                                                        $act_defining_method = 'without_forecast';
                                                    }
                                                    else if($forecast){
                                                        $forecast = floatval(preg_replace('/[^0-9.-]/', '', $forecast));
                                                        if($forecast < $v){
                                                            $act = 'positive';
                                                        }
                                                        else if($forecast > $v){
                                                            $act = 'negative';
                                                        }
                                                        else if($previous){
                                                            $previous = floatval(preg_replace('/[^0-9.-]/', '', $previous));
                                                            $strong /= 4;
                                                            if($previous < $v)
                                                                $act = 'positive';
                                                            else if($previous > $v)
                                                                $act = 'negative';
                                                       }
                                                    }
                                                }
                                            }
                                            else if(($forecast || $previous) &&  ($curtime - $time >= 0))
                                                $is_delayed = true;
                                        
                                        
                                        $source_result[] = array('name' => $name,
                                                                 'name_in_source' => $name_in_source,
                                                                 'country' => $country,
                                                                 'currency' => $currency,
                                                                 'time' => $time,
                                                                 'source' => $source,
                                                                 'theoretical_act' => $act,
                                                                 'theoretical_strong' => $strong,
                                                                 'act_defining_method' => $act_defining_method,
                                                                 'is_delayed' => $is_delayed
                                            );
                                    }
                               }
                         }
                    }
                }
                
                //grouping by source
                
                /*
                 * TO DO
                 */
               $result = array_merge($result, $source_result);
            }
            $len = count($result);
            for($i = 0; $i < $len - 1; $i++)
                for($j = $i + 1; $j < $len; $j++)
                    if($result[$i]['time'] > $result[$j]['time']){
                        $t = $result[$i];
                        $result[$i] = $result[$j];
                        $result[$j] = $t;
                    }
                    
            if($result){
                $time_of_last = $result[count($result) - 1]['time']; 
            }
            else {
                $time_of_last = 0;
            }
            return array($result, $time_of_last);
        }
        
        private function define_country_code($string){
            if(!$string)
                return;
            $code = $this->db->selectCell("SELECT country_code FROM ?_".$this->module_table_countries." WHERE ".(mb_strlen($string) == 2?"country_code LIKE '%".$string."%'":"country_name LIKE '%".$string."%'"));
            return $code;
        }
        
        private function htmltrim($arg){
            $arg = preg_replace('/&nbsp;/is', ' ', $arg);
            $arg = trim($arg);
            return $arg;
        }
}
