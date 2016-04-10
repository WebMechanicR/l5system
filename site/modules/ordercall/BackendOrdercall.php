<?php
/**
 * класс отображения заказов в административной части сайта
 * @author riol
 *
 */

class BackendOrdercall extends View {
	public function index() {
		$this->admins->check_access_module('ordercall');

		$paging_added_query = "&action=index";

		// Постраничная навигация
		$limit = intval($this->settings->limit_admin_num);
		// Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);
		$link_added_query = "&p=".$p;

		$filter = array();

		$filter["limit"] = array($p, $limit);

		// Вычисляем количество страниц
		$calls_count = intval($this->ordercall->get_count_calls($filter));
		$total_pages_num = ceil($calls_count/$limit);

		$list_calls = $this->ordercall->get_list_calls( $filter );
		$this->tpl->add_var('list_calls', $list_calls);
		$this->tpl->add_var('calls_count', $calls_count);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_added_query', $paging_added_query);
		$this->tpl->add_var('link_added_query', $link_added_query);

		return $this->tpl->fetch('ordercall');
	}

	/**
	 * удаление страницы
	 */
	public function delete() {
		$this->admins->check_access_module('ordercall', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->ordercall->delete($id);
		return $this->index();
	}

	/**
	 * действия с группами страниц
	 */
	public function group_actions() {
		$this->admins->check_access_module('ordercall', 2);
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->ordercall->delete($id);
					}
					break;
				case "completed":
					foreach($items as $id) {
						if($id>0) $this->ordercall->update($id, array("is_new"=>0, "aid"=>$this->admins->aid()));
					}
					break;
			}
		}

		return $this->index();
	}
}