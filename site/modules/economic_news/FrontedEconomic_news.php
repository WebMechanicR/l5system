<?php

class FrontedEconomic_news extends View {

        public function index($is_for_test = false) {
            
		$this->wraps_off();
                $method = $this->request->method();
                
                $curtime = !$is_for_test?time():$this->request->$method("curtime", "integer");
                $action = $this->request->$method("type", "string");
                $currency = mb_strtoupper($this->request->$method("currency", "string"));

                if($action == "get_news" or $action == "sending_info"){
                    if(!in_array($currency, array("EURUSD", "GBPUSD"))) //supported currencies
                           return "";

                    @$currencies = unserialize($this->settings->influencing_currencies);  //influencing currencies in format:
                                                                                              //array("CURNAME" => array("INFLCUR" => (-1/1) -this is influencing degree))                                                                                                                   
                    if(!$currencies or !isset($currencies[$currency]))
                    {    
                        switch($currency){
                            case "EURUSD": $currencies["EURUSD"] = array("EUR" => 1, "USD" => -1, "GBP" => 0.13, "JPY" => 0.10, "AUD" => 0.07, "CAD" => 0.08, "CHF" => 0.1); break;
                            case "GBPUSD": $currencies["GBPUSD"] = array("GBP" => 1, "USD" => -1, "EUR" => 0.25, "JPY" => 0.10, "AUD" => 0.07, "CAD" => 0.08, "CHF" => 0.1); break;
                        }
                        $this->settings->influencing_currencies = serialize($currencies);
                    }
                    if(!isset($currencies[$currency]))
                         return "";
                }
                
                if($action == "get_news"){
                            $response = "";

                            $cache_key = "forecast_for_".$currency;
                            $cache_tags = array("forecast", "list_calendar_news");
                            $forecast_time = 1800; //sec
                            if (($result = $this->cache->get($cache_key)) === false) {
                                $result = array("mood_buy" => 0, "mood_sell" => 0);
                                
                                if($is_for_test){
                                    @$meta = unserialize($this->settings->event_chain_for_testing_meta_data);
                                    $diff = isset($meta[0])?$curtime - $meta[0]:0;
                                    if($diff % 70000 == 0)
                                        $this->economic_news->rebuild_forecast(true, $curtime);
                                }
                                
                                $forecast = $this->economic_news->get_forecast();
                                if ($forecast) {
                                    $supported_currencies = array_keys($currencies[$currency]);
                                    $prev_b = 0;
                                    $prev_s = 0;
                                    $next_b = 0;
                                    $next_s = 0;

                                    foreach ($forecast as $item) {
                                        if($item['st_act']  == "sleep")
                                            continue;

                                        $cur = "";
                                        $is_st_cur = false;
                                        if(in_array($item['base_currency'], $supported_currencies))
                                                $cur = $item['base_currency'];
                                        else if(in_array($item['st_currency'], $supported_currencies))
                                        {
                                            $cur = $item['st_currency'];
                                            $is_st_cur = true;
                                        }

                                        if($cur){
                                            $t = $curtime - $item['moment'];

                                            $cache_tags[] = ("calendar_newsid_".$item['news_id']);

                                            if($t >= $forecast_time) {
                                                $act = 0;
                                                switch($item['st_act']){
                                                   case "positive": $act = 1; break;
                                                   case "negative": $act = -1; break;
                                                }

                                                if($act)
                                                {
                                                    $act *= $currencies[$currency][$cur];
                                                }
                                                $s = $item['strength'];
                                                $s /= ($t / 900 * 4 > 1?$t / 900 * 4:1); //the strength is reduced in twice every fifteen minutes

                                                if($is_st_cur){
                                                    $s /= 1.5;
                                                }

                                                if($act < 0)
                                                    $prev_b += ((abs($act) * $s) * (1 - $prev_b / 100));
                                                else if($act > 0)
                                                    $prev_s += ((abs($act) * $s) * (1 - $prev_s / 100));
                                                else
                                                {
                                                    $s *= abs($currencies[$currency][$cur]);
                                                    $prev_b += ($s * (1 - $prev_b / 100));
                                                    $prev_s += ($s * (1 - $prev_s / 100));
                                                }
                                            }
                                            else if($t < $forecast_time){
                                                $t = abs($t);
                                                $s = $item['strength'];
                                                $s /= ($t / 900 * 2 > 1?$t / 900 * 2:1);
                                                $s *= abs($currencies[$currency][$cur]);

                                                if($is_st_cur){
                                                    $s /= 1.5;
                                                }
                                                $next_b += ($s * (1 - $next_b / 100));
                                                $next_s += ($s * (1 - $next_s / 100));
                                            }
                                        }
                                    }
                                    $result['mood_buy'] = $next_b + $prev_b * (1 - $next_b / 100);
                                    $result['mood_sell'] = $next_s + $prev_s * (1 - $next_s / 100);
                                }
                                if(!$is_for_test)
                                    $this->cache->set($result, $cache_key, $cache_tags, 120);
                            }

                            $response = (round($result['mood_buy'], 2)."|".round($result['mood_sell'], 2));

                            $cache_key = "fundamental_reality_for_".$currency;
                            $cache_tags = array("fundamental_reality", "events_list");

                            if(($result = $this->cache->get($cache_key)) === false) {
                                $result = array("remaining_power_sell" => 0, "remaining_power_buy" => 0, "last_event_moment" => 0);
                                $events = $this->economic_news->get_current_events($is_for_test?$curtime:0); 
                                if($events){
                                    $supported_currencies = array_keys($currencies[$currency]);
                                    $accounted_evs_sell = array();
                                    $accounted_evs_buy = array();
                                    foreach($events as $event){
                                        if($event['act']  == "sleep")
                                            continue;
                                        
                                        //remaining power
                                        $cur = "";
                                        $is_st_cur = false;
                                        if(in_array($event['currency'], $supported_currencies))
                                            $cur = $event['currency'];
                                        else if(in_array($event['st_currency'], $supported_currencies))
                                        {
                                            $cur = $event['st_currency'];
                                            $is_st_cur = true;
                                        }

                                        if($cur){
                                            $t = $curtime - $event['moment'];
                                            if(!$result['last_event_moment'])
                                                $result['last_event_moment'] = $event['moment'];
                                            
                                            $act = 0;
                                            switch($event['act']){
                                               case "positive": $act = 1; break;
                                               case "negative": $act = -1; break;
                                            }

                                            $cache_tags[] = 'eventid_'.$event['id'];

                                            if($act)
                                            {
                                               $act *= $currencies[$currency][$cur];
                                            }
                                            
                                            $s = $event['strength'];
                                            if($is_st_cur)
                                                $s /= 1.5;
                                            $st_s_factor =  1; //(1 + (($event['st_strength'] and $event['happened']) ? $event['strength'] - $event['st_strength'] : 0) / (3 * $event['strength']));
                                            if(!$event['happened'])
                                                $s /= 1.5;

                                            if($act < 0){
                                                $accounted_evs_sell[] = array(abs($act) * $s, $t, $st_s_factor);
                                            }
                                            else if($act > 0){
                                                $accounted_evs_buy[] = array($act * $s, $t, $st_s_factor);
                                            }
                                            else{
                                                $accounted_evs_sell[] = array(abs($currencies[$currency][$cur]) * $s, $t, $st_s_factor);
                                                $accounted_evs_buy[] = array(abs($currencies[$currency][$cur]) * $s, $t, $st_s_factor);
                                            }
                                        }
                                    }
                                    for($i = 0; $i < count($accounted_evs_sell) - 1; $i++)
                                        for($j = $i + 1; $j < count($accounted_evs_sell); $j++)
                                            if(abs($accounted_evs_sell[$i][1]) > abs($accounted_evs_sell[$j][1])){
                                                $t = $accounted_evs_sell[$i];
                                                $accounted_evs_sell[$i] = $accounted_evs_sell[$j];
                                                $accounted_evs_sell[$j] = $t;
                                            }
                                   for($i = 0; $i < count($accounted_evs_buy) - 1; $i++)
                                        for($j = $i + 1; $j < count($accounted_evs_buy); $j++)
                                            if(abs($accounted_evs_buy[$i][1]) > abs($accounted_evs_buy[$j][1])){
                                                $t = $accounted_evs_buy[$i];
                                                $accounted_evs_buy[$i] = $accounted_evs_buy[$j];
                                                $accounted_evs_buy[$j] = $t;
                                            } 
                                    foreach($accounted_evs_buy as $bi){

                                        $t = (1800 * ($bi[0] + count($accounted_evs_buy))/ 100); 

                                        $s = $bi[0] * ($t <= abs($bi[1])?0:(1 - abs($bi[1]) / ($t))) * $bi[2]; 
                                        $result['remaining_power_buy'] += ($s * (1 - $result['remaining_power_buy'] / 100));
                                    }
                                    
                                    foreach($accounted_evs_sell as $si){
                                        $t = (1800 * ($si[0] + count($accounted_evs_sell))/ 100);
                                        $s = $si[0] * ($t <= abs($si[1])?0:(1 - abs($si[1]) / ($t))) * $si[2]; 
                                        $result['remaining_power_sell'] += ($s * (1 - $result['remaining_power_sell'] / 100));
                                    }
                                    
                                    if(!$result['remaining_power_sell'] and !$result['remaining_power_buy'])
                                        $result['last_event_moment'] = 0;
                                }
                                
                                if(!$is_for_test)
                                    $this->cache->set($result, $cache_key, $cache_tags, 80);
                            }
                            
                            $response .=  ("|".round($result['remaining_power_buy'], 2)."|".round($result['remaining_power_sell'], 2)."|".$result['last_event_moment']);

                            return $response;
               }
               else if($action == "sending_info"){
                   if(!in_array($currency, array("EURUSD", "GBPUSD"))) //supported currencies
                        $currency = "";

                   if($currency){
                       $event_moment = $this->request->$method("event_moment", "integer");
                       if($event_moment){
                            $st_act = $this->request->$method("st_act", "integer");
                            $st_strength = min(max(0, $this->request->$method("st_strength", "integer")), 100);
                            if(!in_array($st_act, array(0, 1, -1)))
                                    $st_act = 0;
                            $events = $this->economic_news->get_list_events(array('moment' => $event_moment));
                            if($events){
                                $count = 0;
                                $event_count = count($events);
                                $average_theoretical_strength = 0;
                                foreach($events as $event)
                                    $average_theoretical_strength += $event['strength'];
                                $average_theoretical_strength /= $event_count;
                                
                                foreach($currencies[$currency] as $c => $v){
                                    $act = $v * $st_act;
                                    $sact = "neutral";
                                    if($act == 1)
                                        $sact = "positive";
                                    else if($act == -1)
                                       $sact = "negative";
                                    foreach($events as $event){
                                        if($event['currency'] == $c){
                                            $arr['st_strength'] = round($st_strength * ($average_theoretical_strength / $event['strength'] < 1?$average_theoretical_strength / $event['strength']:$event['strength'] / $average_theoretical_strength));
                                            $arr['st_act'] = $sact;
                                            $this->economic_news->update_event($event['id'], $arr);
                                        }
                                    }
                                    
                                    $count++;
                                    if($count >= 2)
                                        break;
                                }  
                            }
                       }
                   }
              }
              else if($action == "getting_levels"){
                  $strategy = $this->request->$method("strategy", "integer");
                  $result = array(); //sl, tp, ts, risk
                  if($strategy == 1){      //common strategy
                      switch($currency){
                          case "EURUSD": $result = array(18, 72, 30, 1.5); break;
                          case "GBPUSD": $result = array(18, 72, 30, 1.5); break;
                      }
                  }
                  else if($strategy == 2){  //low risk strategy
                      switch($currency){
                          case "EURUSD": $result = array(7, 10, 20, 0.1); break;
                          case "GBPUSD": $result = array(7, 10, 20, 0.1); break;
                      }
                  }
                  
                  return implode('|', $result);
              }
	}
        
        public function build_events_chain(){
            $start_date = strtotime($this->request->get('start_date', 'string'));
            $end_date = strtotime($this->request->get('end_date', 'string'));
            $currency = $this->request->get('currency', 'string');
            
            $this->settings->update_settings(array('event_chain_for_testing_meta_data' => serialize(array($start_date, $end_date, $currency))));
            
            $this->GetEventsChainForTesting($currency, $start_date, $end_date);
        }
        
        private function GetEventsChainForTesting($currency, $start_timestamp, $end_timestamp){
            $this->db->query(
                    " CREATE TABLE IF NOT EXISTS ?_".$currency."_events_chain_for_testing (
                        data varchar(255) NOT NULL,
                        moment int(11) NOT NULL,
                        KEY moment (moment)
                      ) ENGINE=MyISAM DEFAULT CHARSET=cp1251;"
                    );
            $this->db->query("TRUNCATE TABLE ?_".$currency."_events_chain_for_testing");
            $cur_timestamp = $start_timestamp;
            while($cur_timestamp < $end_timestamp){
                        $_GET['curtime'] = $cur_timestamp;
                        $_GET['type'] = 'get_news';
                        $_GET['currency'] = $currency;

                        $res = $this->index(true);
                        $this->db->query("INSERT INTO ?_".$currency."_events_chain_for_testing (data, moment) VALUES(?,?)", $res, $cur_timestamp);
                        $cur_timestamp += 13;
            }
        }
}
