<?php
class Ordercall extends Module {

	protected $module_name = "ordercall";
	private $module_table = "ordercall";
	private $module_nesting = true; //возможность владывать подстраницы в модуль

	/**
	 * добавляет новый элемент в базу
	*/
	public function add($call) {
		return $this->db->query("INSERT INTO ?_".$this->module_table." (?#) VALUES (?a)", array_keys($call), array_values($call));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $call) {

		if($this->db->query("UPDATE ?_".$this->module_table." SET ?a WHERE id IN (?a)", $call, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete($id) {
			$this->db->query("DELETE FROM ?_".$this->module_table." WHERE id=?", $id);
	}

	/**
	 * возвращает заказов удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_list_calls($filter=array()) {
		$sort_by = " ORDER BY n.id DESC";
		$limit = "";
		$where = "";

		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}

		if(isset($filter['is_new'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.is_new=".intval($filter['is_new']);
		}
				
		return $this->db->select("SELECT n.*, a.name as admin_name
				FROM ?_".$this->module_table." n
				LEFT JOIN  ?_admins a ON (n.aid=a.id) "
				.$where
				.$sort_by.$limit);
	}

	/**
	 * возвращает количество заказов удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_count_calls($filter=array()) {
		$where = "";
		
		if(isset($filter['is_new'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.is_new=".intval($filter['is_new']);
		}
		
		return $this->db->selectCell("SELECT count(n.id)
				FROM ?_".$this->module_table." n".$where);
	}

	/**
	 * возвращает настройку модуля
	 * @param string $id
	 * @return Ambigous <NULL, multitype:string >
	 */
	public function setting($id) {
		return (isset($this->module_settings[$id]) ? $this->module_settings[$id] : null);
	}
	
	/**
	 * @return boolean
	 */
	public function is_nesting() {
		return $this->module_nesting;
	}
	
	
	/**
	 * возвращает записи роутера для модуля
	 * {url_page} - подстановка адреса (full_link) страницы
	 */
	public function get_router_records() {
		return array(
				array('{url_page}(\/?)', 'module=ordercall&page_url={url_page}')
		);
	}
}