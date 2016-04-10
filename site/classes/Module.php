<?php
/**
 * абстрактный класс модуля, все модули его наследуют
 * @author riol
 *
 */
abstract class Module extends System {
	
	/**
	 * хранит название модуля
	 */
	protected $modul_name;
	
	public function __construct() {
		parent::__construct();
	}
	
	/**
	 * возвращает имя модуля
	 */
	public function get_modul_name() {
		return $this->modul_name;
	}
}