<?php
/**
 * модуль работы с меню
 * @author riol
 *
 */
class Menus extends Module implements IElement {

	protected $module_name = "menus";

	private $module_settings = array(
			"revisions_content_type" => "menus"
	);

	//глобальный массив доступа к основным свойствам элементов меню
	private $all_menus;

	//дерево меню
	private $tree_menus;

	//инициализован ли глобальный массив меню
	private $inited_menus = false;

	/**
	 * добавляет новый элемент в базу
	 */
	public function add($menu) {
		//чистим кеш
		$this->cache->delete("tree_menus");
		$this->inited_menus = false;
		return $this->db->query("INSERT INTO ?_menu_items (?#) VALUES (?a)", array_keys($menu), array_values($menu));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $menu) {
		//чистим кеш
		$this->cache->delete("tree_menus");
		$this->inited_menus = false;

		if($this->db->query("UPDATE ?_menu_items SET ?a WHERE id IN (?a)", $menu, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete($id, $clear=true) {
		$menu = $this->get_menu_info($id);
		$this->db->query("DELETE FROM ?_menu_items WHERE id=?", $id);

		$this->clear_revisions($id);

		$tree_menus = $this->get_tree_menus();
		//удаляем вложенные меню
		if(isset($tree_menus["tree"][ $menu['menu_id'] ][$id]) and is_array($tree_menus["tree"][ $menu['menu_id'] ][$id])) {
			foreach($tree_menus["tree"][ $menu['menu_id'] ][$id] as $menu_id) {
				$this->delete($menu_id, false);
				$this->clear_revisions($menu_id);
			}
		}
		if($clear) {
			//чистим кеш
			$this->cache->delete("tree_menus");
			$this->inited_menus = false;
		}
	}

	/**
	 * создает копию элемента
	 */
	public function duplicate($id) {
		$new_id = null;
		if($menu = $this->get_menu($id)) {

			unset($menu['id']);
			$menu['title'] .= ' (копия)';
			$menu['enabled'] = 0;
				
			// Сдвигаем пункта меню вперед и вставляем копию на соседнюю позицию
			$this->db->query('UPDATE ?_menu_items SET sort=sort+1 WHERE sort>? AND parent=?', $menu['sort'], $menu['parent']);
			$menu['sort']++;

			$new_id = (int)$this->add($menu);
		}
		return $new_id;
	}

	/**
	 * возвращает историю версий элемента
	 */
	public function get_list_revisions($for_id) {
		return $this->revision->get_list_revisions($for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * добавляет версию элемента в историю
	 */
	public function add_revision($for_id) {
		if($content = $this->get_menu($for_id)) {
			return $this->revision->add_revision($for_id, $this->setting("revisions_content_type"), $content);
		}
		return null;
	}

	/**
	 * возвращает данные элемента из определенной ревизии
	 */
	public function get_from_revision($id, $for_id) {
		return $this->revision->get_from_revision($id, $for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * удаляет все ревизии элемента
	 */
	public function clear_revisions($for_id) {
		return $this->revision->clear_revisions($for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * возвращает пункты меню по id
	 * @param mixed $id
	 * @return array
	 */
	public function get_menu($id) {
		return $this->db->selectRow("SELECT * FROM ?_menu_items WHERE id=?d", $id);
	}

	/**
	 * возвращает пункты меню удовлетворяющие фильтрам
	 * @param array $filter
	 */
	public function get_menus($filter=array()) {
		return $this->db->select("SELECT p.id, p.title, p.sort, p.parent, p.enabled
				FROM ?_menu_items p");
	}

	/**
	 * возвращает порядок сортировки для добавляемого пункта меню
	 * @param int $parent
	 */
	public function get_new_menu_sort($parent) {
		if($parent) return $this->db->selectCell("SELECT MAX(sort) as sort FROM ?_menu_items WHERE parent=?", $parent)+1;
		else return $this->db->selectCell("SELECT MAX(sort) as sort FROM ?_menu_items")+1;
	}


	/**
	 * возвращает основные св-ва пункта меню
	 * @param int $id
	 */
	public function get_menu_info($id) {
		if(!$this->inited_menus) $this->init_menus();
		if(isset($this->all_menus[$id]))
			return $this->all_menus[$id];
		else
			return false;
	}

	/**
	 * возвращает дерево всех пунктов меню
	 */
	public function get_tree_menus() {
		if(!$this->inited_menus) $this->init_menus();
		return array("all"=>$this->all_menus, "tree"=>$this->tree_menus);
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
	 * кладет все пункты меню в глобальный массив
	 */
	private function init_menus() {
		$cache_key = "tree_menus";
		if (false === ($menus = $this->cache->get($cache_key))) {
			$db_menus = $this->db->select("SELECT * FROM ?_menu_items ORDER BY sort ASC");
			$all_menus = $tree_menus = array();
			foreach($db_menus as $menu) {
				$all_menus[ $menu['id'] ] = $menu;
				$tree_menus[ $menu['menu_id'] ][ $menu['parent'] ][] = $menu['id'];
			}
			$menus = array($all_menus, $tree_menus);
			$this->cache->set($menus, $cache_key);
		}

		$this->all_menus = $menus[0];
		$this->tree_menus = $menus[1];
		$this->inited_menus = true;
	}

	/**
	 * возвращает массив меню
	 */
	public function get_list_menus() {
		return $this->db->select("SELECT * FROM ?_menus ORDER BY sort ASC");
	}

	/**
	 * добавляет новый тип меню в базу
	 */
	public function add_menu($menu) {
		return $this->db->query("INSERT INTO ?_menus (?#) VALUES (?a)", array_keys($menu), array_values($menu));
	}

	/**
	 * удаляет тип меню из базы
	 */
	public function delete_menu($id) {
		//чистим кеш
		$this->cache->delete("tree_menus");
		$this->inited_menus = false;
		$this->db->query("DELETE FROM ?_menu_items WHERE menu_id=?d", $id);
		return $this->db->query("DELETE FROM ?_menus WHERE id=?d", $id);
	}

	/**
	 * обновляет тип меню в базе
	 */
	public function update_menu($id, $menu) {
		if($this->db->query("UPDATE ?_menus SET ?a WHERE id=?", $menu, $id))
			return $id;
		else
			return false;
	}

	/**
	 * обновляет тип меню в базе
	 */
	public function get_type_menu($id) {
		return $this->db->selectRow("SELECT * FROM ?_menus WHERE id=?d", $id);
	}
}