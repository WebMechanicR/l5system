<?php
/**
 * Класс для вывода контента в административной части сайта
 * @author riol
 *
 */
class AdminView extends System {


	public function __construct() {
		parent::__construct();
	}

	/**
	 * выводит контент
	 */
	public function display() {
		/**
		 * запускаем сессию
		 */
		session_start();
		
		//очищаем бан ip логина
		$this->admins->clean_try_login();

		//переключаем папку шаблонов на admin
		$this->tpl->in_admin();

		//url админки
		define("DIR_ADMIN",  SITE_URL."admin/");

		//передаем в шаблон необходимые везде переменные
		$this->tpl->add_var('dir_js', SITE_URL."templates/admin/js/");
		$this->tpl->add_var('dir_images', SITE_URL."templates/admin/images/");
		$this->tpl->add_var('dir_css', SITE_URL."templates/admin/css/");
		$this->tpl->add_var('site_host', F::get_url_for_text(SITE_URL));
		$this->tpl->add_var('product_statuses', System::$CONFIG['product_statuses']);


		if($this->request->get('logout', 'boolean')) $this->admins->logout();

		if($this->admins->login()) {
			define("IS_ADMIN", true);
			$this->tpl->add_var('admin', $this->admins->get_admin_info());
			//инициализуем нужный модуль и выводим его результат на экран
			// Берем название модуля из get-запроса
			$module = $this->request->get('module', 'string');
			$module = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $module);
				
			// Берем название действия из get-запроса
			$action = $this->request->get('action', 'string');
			$action = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $action);
				
			// Если не запросили модуль - используем доступный модуль
			if(empty($module) or !file_exists(ROOT_DIR.'modules/'.$module.'/Backend'.ucfirst($module).'.php')) {
				if(!$module = $this->admins->get_first_access_module()) {
					/**
					 * если нет доступных модулей для данного админа - разлогиниваем его
					 */
					$this->admins->logout();
					header("Location: ".DIR_ADMIN);
					exit();
				}
				$action = 'index';
			}
				
			// Если не задано действие - используем index
			if(empty($action)) $action = 'index';

			require_once ROOT_DIR.'modules/'.$module.'/Backend'.ucfirst($module).'.php';
			$class_name = 'Backend'.ucfirst($module);
			$view = new $class_name();
				
			//проверяем есть ли нужное действие в модуле
			if(!method_exists($view, $action))  $action = "index";
				
			//передаем в шаблон необходимые везде переменные
			$this->tpl->add_var('module', $module);
			$this->tpl->add_var('action', $action);
				
			$menus = $view->menus->get_list_menus();
			$this->tpl->add_var('menus', $menus);
			
			//выводим содержимое модуля
			$content = $view->$action();
		}
		else {//если не залогинен открываем форму входа
			if($this->request->isAJAX()) {//если запрос с аякса, сначала отправляем ява редирект
				return '<script>window.location="'.DIR_ADMIN.'"</script>';
			}
			else {
				require_once ROOT_DIR.'modules/admins/BackendAdmins.php';
				$view = new BackendAdmins();
				$content = $view->login_form();
			}
		}

		//отправляем заголовки с кодировкой и типом документа, тип должен возвращать модуль
		$view->sendHeaders();

		if($view->on_wrapper()) {
			$this->tpl->add_var('content', $content);
			return $this->tpl->fetch('index');
		}
		else return $content;

	}

}