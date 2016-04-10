<?php
/**
 * класс отображения меню в административной части сайта
 * @author riol
 *
 */

class BackendMenus extends View {

	public function index() {
		$this->admins->check_access_module('menus', 2);

		$del_id = $this->request->get("del_id", "integer");
		if($del_id>0) $this->menus->delete_menu($del_id);

		if($this->request->method('post') && !empty($_POST)) {
			$new_menu_name = $this->request->post('new_menu_name', 'string');
			$new_menu_sort = $this->request->post('new_menu_sort', 'integer');

			$menu_name = $this->request->post('menu_name', "array");

			if(is_array($menu_name) and count($menu_name)>0) {
				/**
				 * обновляем список меню
				 */
				$i=1;
				foreach($menu_name as $up_menu_id=>$up_menu_name) {
					$up_menu_name = F::clean($up_menu_name);
					$up_menu_id = intval($up_menu_id);
					if($up_menu_id>0 and !empty($up_menu_name)) {
						$this->menus->update_menu($up_menu_id, array("name"=>$up_menu_name, "sort"=>$i));
					}
					$i++;
				}
			}

			if(!empty($new_menu_name)) {
				/**
				 * добавляем новое меню
				 */
				$add_menu = array("name"=>$new_menu_name, "sort"=>$new_menu_sort);
				$this->menus->add_menu($add_menu);
			}
			/**
			 * если загрузка аяксом и не было добавления возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
			 */
			elseif($this->request->isAJAX()) return 1;
		}

		$menus = $this->menus->get_list_menus();

		$this->tpl->add_var('menus', $menus);
		return $this->tpl->fetch('menus');
	}


	public function menu_items() {
		$this->admins->check_access_module('menus', 2);
		$menu_id = $this->request->get("menu_id", "integer");

		if($menu_id<1) {
			header("Location: ".DIR_ADMIN."?module=menus");
			exit();
		}
		if($type_menu = $this->menus->get_type_menu($menu_id)) {
			$tree_menus = $this->menus->get_tree_menus();
			$this->tpl->add_var('tree_menus', $tree_menus);
			$this->tpl->add_var('menu_id', $menu_id);
			$this->tpl->add_var('type_menu', $type_menu);
		}
		else {
			header("Location: ".DIR_ADMIN."?module=menus");
			exit();
		}
		return $this->tpl->fetch('menus_items');
	}

	/**
	 * обновление порядка и вложенности страниц
	 */
	public function update_sort() {
		$this->admins->check_access_module('menus', 2);

		$update_menu_item_id = $this->request->post("update_menu_item_id", "integer");
		$items = $this->request->post("items", "array");

		if($update_menu_item_id>0 and count($items)>0 and isset($items[$update_menu_item_id]) and $update_page = $this->menus->get_menu_info($update_menu_item_id)) {

			$i = 1;
			foreach($items as $item_id=>$item_parent) {
				if($item_parent==$items[$update_menu_item_id]) {
					if($item_id==$update_menu_item_id and $item_parent!=$update_page['parent']) {
						$this->menus->update(intval($item_id), array("sort"=>$i, "parent"=>intval($item_parent)));
					}
					else $this->menus->update(intval($item_id), array("sort"=>$i));
					$i++;
				}
			}
		}
		return null;
	}

	/**
	 * редактирование/добавлние пункта меню
	 */
	public function edit() {
		$this->admins->check_access_module('menus', 2);

		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$menu_item_id = $this->request->$method("id", "integer");
		$parent = $this->request->$method("parent", "integer");
		$menu_id = $this->request->$method("menu_id", "integer");
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";
		$from_revision = $this->request->get("from_revision", "integer");

		/**
		 * ошибки при заполнении формы
		*/
		$errors = array();

		$menu = array("id"=>$menu_item_id, "enabled"=>1, "parent"=>$parent, "menu_id"=>$menu_id);

		if($this->request->method('post') && !empty($_POST)) {
			$menu['title'] = $this->request->post('title', 'string');
			$menu['title2'] = $this->request->post('title2', 'string');
			$menu['enabled'] = $this->request->post('enabled', 'integer');
			$menu['sort'] = $this->request->post('sort', 'integer');
			$menu['url'] = $this->request->post('url', 'url');
			$menu['menu_id'] = $this->request->post('menu_id', 'integer');
			$menu['page_id'] = $this->request->post('page_id', 'integer');

			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($menu['url']) and $menu['page_id']<1) {
				$errors['url'] = 'no_url';
				$tab_active = "other";
			}
			if(empty($menu['title'])) {
				$errors['title'] = 'no_title';
				$tab_active = "main";
			}

			if(count($errors)==0) {

				if($menu_item_id) {
					$this->menus->add_revision($menu_item_id);
					$this->menus->update($menu_item_id, $menu);
				}
				else {
					$menu_item_id = (int)$this->menus->add($menu);
				}

				/**
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список страниц
				 */
				if($after_exit and count($errors)==0) {
					header("Location: ".DIR_ADMIN."?module=menus&action=menu_items&menu_id=".$menu['menu_id']);
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $menu['id'] and $may_noupdate_form) return 1;
			}
		}


		if($menu_item_id) {
			if($from_revision) {
				$menu = $this->menus->get_from_revision($from_revision, $menu_item_id);
			}
			else {
				$menu = $this->menus->get_menu($menu_item_id);
			}
			if(count($menu)==0) {
				header("Location: ".DIR_ADMIN."?module=menus");
				exit();
			}
			$list_revisions = $this->menus->get_list_revisions($menu_item_id);
		}
		else {
			$menu['sort'] = $this->menus->get_new_menu_sort($parent);
			$list_revisions = array();
		}

		$modules = $this->get_modules(array("is_attach"=>1));

		$tree_menus = $this->menus->get_tree_menus();
		$tree_pages = $this->pages->get_tree_pages();

		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('menu_item', $menu);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('modules', $modules);
		$this->tpl->add_var('tree_menus', $tree_menus);
		$this->tpl->add_var('tree_pages', $tree_pages);
		$this->tpl->add_var('list_revisions', $list_revisions);
		$this->tpl->add_var('from_revision', $from_revision);
		return $this->tpl->fetch('menus_item_add');
	}

	/**
	 * синоним для edit
	 */
	public function add() {
		return $this->edit();
	}

	/**
	 * удаление пункта меню
	 */
	public function delete() {
		$this->admins->check_access_module('menus', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->menus->delete($id);
		return $this->menu_items();
	}

	/**
	 * действия с группами страниц
	 */
	public function group_actions() {
		$this->admins->check_access_module('menus', 2);
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "hide":
					$this->menus->update($items, array("enabled"=>0));
					break;
				case "show":
					$this->menus->update($items, array("enabled"=>1));
					break;
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->menus->delete($id);
					}
					break;
			}
		}

		return $this->menu_items();
	}

	/**
	 * создает дубликат пункта меню
	 * @return string
	 */
	public function duplicate() {
		$this->admins->check_access_module('menus', 2);
		$id = $this->request->get("id", "integer");
		if($id>0) $this->menus->duplicate($id);
		return $this->menu_items();
	}
}