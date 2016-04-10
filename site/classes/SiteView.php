<?php
/**
 * Класс ля вывода контента в общей части сайта
 * @author riol
 *
 */
class SiteView extends System {
	
	
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
		
		//передаем в шаблон необходимые везде переменные
		$this->tpl->add_var('dir_js', SITE_URL."templates/js/");
		$this->tpl->add_var('dir_images', SITE_URL."templates/img/");
		$this->tpl->add_var('dir_css', SITE_URL."templates/css/");
		$this->tpl->add_var('site_host', F::get_url_for_text(SITE_URL));
		$this->tpl->add_var('product_statuses', System::$CONFIG['product_statuses']);
		$this->tpl->add_var('isAJAX', $this->request->isAJAX());
		
		$module = $this->request->get('module', 'string');
		$action = $this->request->get('action', 'string');
		$router_page = $this->request->get('router_page', 'string');
		
		//через роутер инициализуем нужный модуль
		if(!$module and $router_page) {
			if($this->router->parse_url($router_page)) {
				$module = $this->request->get('module', 'string');
				$action = $this->request->get('action', 'string');
			}
			else {
				$module = "pages";
				$_GET['page_url'] = trim($router_page, "/");
			}
		}
		
		$module = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $module);
		$action = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $action);
		$page_url = $this->request->get('page_url', 'string');
		
		// Если не задано действие - используем index
		if(empty($action)) $action = 'index';
		
		// Если не запросили модуль - используем доступный модуль
		if(empty($module) or !file_exists(ROOT_DIR.'modules/'.$module.'/Fronted'.ucfirst($module).'.php')) {
			$module = 'main';
		}
		
		require_once ROOT_DIR.'modules/'.$module.'/Fronted'.ucfirst($module).'.php';
		$class_name = 'Fronted'.ucfirst($module);
		$view = new $class_name();
		
		//проверяем есть ли нужное действие в модуле
		if(!method_exists($view, $action))  $action = "index";
		
		//передаем в шаблон необходимые везде переменные
		$tree_pages = $this->pages->get_tree_pages();
		$tree_menus = $this->menus->get_tree_menus();
		$tree_categories = $this->catalog->get_tree_categories();
		$news_full_link = $this->pages->get_full_link_module("news");


		
		$this->tpl->add_var('tree_menus', $tree_menus);
		$this->tpl->add_var('tree_pages', $tree_pages);
		$this->tpl->add_var('tree_categories', $tree_categories);
		$this->tpl->add_var('module', $module);
		$this->tpl->add_var('action', $action);
		$this->tpl->add_var('page_url', $page_url);
		$this->tpl->add_var('news_full_link', $news_full_link);
		
		//выводим содержимое модуля
		if(($content = $view->$action()) === false) {
			$module = "404";
			$action = "index";
			require_once ROOT_DIR.'modules/'.$module.'/Fronted'.ucfirst($module).'.php';
			$class_name = 'Fronted'.ucfirst($module);
			$view = new $class_name();
			$content = $view->$action();
			$this->tpl->add_var('module', $module);
			$this->tpl->add_var('action', $action);
		}
		
		//Admins Hat Functionality
		if($this->admins->login())
		{
			define("ADMINS_HAT", true);
			define("DIR_ADMIN", SITE_URL."admin/");
			//initial of template variables. Neither hat only or site.
			$this->tpl->add_var('admin', $this->admins->get_admin_info());
			$this->tpl->add_var('admin_dir_css', SITE_URL."templates/admin/css/");
			$this->tpl->add_var('admin_dir_js', SITE_URL."templates/admin/js/");
			$this->tpl->add_var('admin_dir_images', SITE_URL."templates/admin/images/");
		}
		else
			define("ADMINS_HAT", false);
		
		$this->tpl->add_var('meta_title', $view->get_meta_title());
		$this->tpl->add_var('meta_description', $view->get_meta_description());
		$this->tpl->add_var('meta_keywords', $view->get_meta_keywords());
		
		//отправляем заголовки с кодировкой и типом документа, тип должен возвращать модуль
		$view->sendHeaders();
		
		if($view->on_wrapper()) {
			$this->tpl->add_var('content', $content);
			return $this->tpl->fetch('index');
		}
		else return $content;
		
	}
	
}