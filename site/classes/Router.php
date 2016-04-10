<?php
/**
 * класс для работы с адресами - роутер
 * @author riol
 *
 */
class Router extends System {
	
	public function write_records($module, $page_url) {
		if($this->isset_module($module)) {
			$records = $this->$module->get_router_records();
			
			//удаляем старые записи
			$this->delete_records($module);
			foreach($records as $record) {
				$this->db->query("INSERT INTO ?_router (module, record_rule, record_vars) VALUES (?, ?, ?)", 
						$module, str_replace("{url_page}", $page_url, $record[0]), str_replace("{url_page}", $page_url, $record[1]));
			}
			$this->cache->delete("router_records");
		}
	}
	
	public function delete_records($module) {
		$this->cache->delete("router_records");
		$this->cache->delete("full_links_array");
		return $this->db->query("DELETE FROM ?_router WHERE module=?", $module);
	}
	
	/**
	 * возвращает все записи роутера
	 * @return multitype:
	 */
	private function get_records() {
		$cache_key = "router_records";
		if (false === ($router_records = $this->cache->get($cache_key))) {
			$router_records = $this->db->select("SELECT record_rule, record_vars FROM ?_router ORDER BY id ASC");
			$this->cache->set($router_records, $cache_key);
		}
		return $router_records;
	}
	
	/**
	 * парсит урл, если находит совпадения, фвозвращает true и записывает их в $_GET. иначе возвращает false
	 * @param unknown_type $router_page
	 */
	public function parse_url($router_page) {
		if($router_records = $this->get_records() and is_array($router_records)) {
			foreach($router_records as $router_record) {
				if(preg_match('#^'.$router_record['record_rule'].'$#i', $router_page)) {
					parse_str( preg_replace('#^'.$router_record['record_rule'].'$#i', $router_record['record_vars'], $router_page), $request_arr);
					$_GET = array_merge($_GET, $this->request->stripslashes_recursive($request_arr));
					return true;
				}
			}
		}
		return false;
	}
}