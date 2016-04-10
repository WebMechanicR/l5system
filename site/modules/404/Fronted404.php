<?php
/**
 * класс отображения страницы ошибки 404
 * @author riol
 *
 */

class Fronted404 extends View {
	public function index() {

		$this->add_header('HTTP/1.0 404 Not Found');
		
		$this->set_meta_title("Error 404: page no found");
		

		return $this->tpl->fetch('404');
	}
}