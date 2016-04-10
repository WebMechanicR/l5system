<?php
/**
 * класс отображения администраторов в административной части сайта
 * @author riol
 *
 */

class BackendAdmins extends View {
	public function index() {
		$this->admins->check_access_module('admins');

		$admins = $this->admins->get_admins();
		$this->tpl->add_var('admins', $admins);

		return $this->tpl->fetch('admins');
	}


	/**
	 * редактирование/добавлние админа
	 */
	public function edit() {
		$this->admins->check_access_module('admins', 2);

		$method = $this->request->method();
		$id = $this->request->$method("id", "integer");

		/**
		 * ошибки при заполнении формы
		*/
		$errors = array();

		
		$admin_t = array("id"=>$id);

		if($this->request->method('post') && !empty($_POST)) {
			$admin_t['login'] = $this->request->post('login', 'string');
			$admin_t['name'] = $this->request->post('name', 'string');
			$admin_t['contacts'] = $this->request->post('contacts');
			$admin_t['access_class'] = $this->request->post('access_class', 'string');
			$admin_t['ip'] = $this->request->post('ip', 'string');
			$npass = $this->request->post('npass');
			$ncpass = $this->request->post('ncpass');
			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($admin_t['name'])) $errors['name'] = 'no_name';

			if(empty($admin_t['login'])) $errors['login'] = 'no_login';
			elseif($admin_t['login'] != $_SESSION['ad_login'] and $this->db->selectCell("SELECT a.id FROM ?_admins a WHERE a.login=? AND a.id!=? LIMIT 1", $admin_t['login'], $id)>0) $errors['login'] = 'exists_login';

			if(!$id and $npass=="") $errors['new_password'] = "no_password";
			elseif($npass!="" and $npass != $ncpass) $errors['new_password'] = "invalid_new";

			if(count($errors)==0) {
				if($npass!="") $admin_t['password'] = md5(SALT.$npass.SALT);

				if($id) {
					$this->admins->update($id, $admin_t);
				}
				else {
					//добавляем админа
					$admin_t['date_set'] = time();
					$new_id = $this->admins->add($admin_t);
				}

				/**
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список админов
				 */
				if($after_exit) {
					header("Location: ".DIR_ADMIN."?module=admins");
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and $id) return 1;
				else $id = $new_id;

			}
		}

		if($id) $admin_t = $this->admins->get_admin($id);

		$admin_classes = $this->admins->get_list_admin_classes();

		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('admin_t', $admin_t);
		$this->tpl->add_var('admin_classes', $admin_classes);
		return $this->tpl->fetch('admins_add');
	}

	/**
	 * синоним для edit
	 */
	public function add() {
		return $this->edit();
	}

	/**
	 * удаление админа
	 */
	public function delete() {
		$this->admins->check_access_module('admins', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->admins->delete($id);
		return $this->index();
	}

	/**
	 * страница с группами администраторов с определенными правами
	 */
	public function groups() {
		$this->admins->check_access_module('admins', 2);

		$del_id = $this->request->get("del_id", "integer");
		if($del_id>0) $this->admins->delete_group($del_id);

		if($this->request->method('post') && !empty($_POST)) {
			$new_class_name = $this->request->post('new_class_name', 'string');
			$new_class_allowed = $this->request->post('new_class_allowed', "array");
				
			$class_name = $this->request->post('class_name', "array");
			$class_allowed = $this->request->post('class_allowed', "array");
				
			if(is_array($class_name) and count($class_name)>0 and is_array($class_allowed) and count($class_allowed)>0) {
				/**
				 * обновляем список классы админов
				 */
				foreach($class_name as $up_class_id=>$up_class_name) {
					$up_class_name = F::clean($up_class_name);
					$up_class_id = intval($up_class_id);
					if($up_class_id>0 and !empty($up_class_name)) {
						$up_class = array("name"=>$up_class_name, "allowed"=>"");
						if(isset($class_allowed[$up_class_id])) {
							$class_allowed[$up_class_id] = array_map("intval", $class_allowed[$up_class_id]);
							$up_class["allowed"] = serialize($class_allowed[$up_class_id]);
						}
						$this->admins->update_group($up_class_id, $up_class);
					}
				}
			}
				
			if(!empty($new_class_name) and $new_class_name!='Добавить новую' and is_array($new_class_allowed) and count($new_class_allowed)>0) {
				/**
				 * добавляем новую группу админов
				 */
				$new_class_allowed = array_map("intval", $new_class_allowed);
				$add_class = array("name"=>$new_class_name, "allowed"=>serialize($new_class_allowed));
				$this->admins->add_group($add_class);
			}
			/**
			 * если загрузка аяксом и не было добавления возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
			 */
			elseif($this->request->isAJAX()) return 1;
		}

		$modules = $this->get_modules();
		$admin_classes = $this->admins->get_list_admin_classes();

		$this->tpl->add_var('admin_classes', $admin_classes);
		$this->tpl->add_var('modules', $modules);
		return $this->tpl->fetch('admins_groups');
	}

	/**
	 * выводит форму входа
	 */
	public function login_form() {

		$this->wraps_off();

		$num_try = $this->admins->get_num_try_login();
		$this->tpl->add_var('num_try', $num_try);

		return $this->tpl->fetch('login_form');
	}

	/**
	 * выводит личные настройки админа
	 */
	public function profile() {
		/**
		 * ошибки при заполнении формы
		 */
		$errors = array();

		$admin = $this->admins->get_admin_info();

		$admin_t['login'] = $admin['login'];
		$admin_t['name'] = $admin['name'];
		$admin_t['contacts'] = $admin['contacts'];
		if($this->request->method('post') && !empty($_POST)) {
			$admin_t['login'] = $this->request->post('login', 'string');
			$admin_t['name'] = $this->request->post('name', 'string');
			$admin_t['contacts'] = $this->request->post('contacts');
			$pass = $this->request->post('pass');
			$npass = $this->request->post('npass');
			$ncpass = $this->request->post('ncpass');
				
			if(empty($admin_t['name'])) $errors['name'] = 'no_name';
				
			if(empty($admin_t['login'])) $errors['login'] = 'no_login';
			elseif($admin_t['login'] != $_SESSION['ad_login'] and $this->db->selectCell("SELECT a.id FROM ?_admins a WHERE a.login=? AND a.id!=? LIMIT 1", $admin_t['login'], $this->admins->aid())>0) $errors['login'] = 'exists_login';
				
			if(md5(SALT.$pass.SALT) != $_SESSION['ad_pas']) $errors['real_password'] = "error_real";
				
			if($npass!="" and $npass != $ncpass) $errors['new_password'] = "invalid_new";
				
			if(count($errors)==0) {
				if($npass == "") $npass = $pass;
				else $_SESSION['ad_pas'] = md5(SALT.$npass.SALT);

				if($admin_t['login'] != $_SESSION['ad_login']) $_SESSION['ad_login'] = $admin_t['login'];

				$admin_t['password'] = md5(SALT.$npass.SALT);
				$this->admins->update($this->admins->aid(), $admin_t);

				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				*/
				if($this->request->isAJAX()) return 1;
			}
		}

		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('admin_t', $admin_t);
		return $this->tpl->fetch('profile');
	}
}