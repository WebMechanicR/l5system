<?php
/**
 * класс, отвечающий за отображение контента
 * @author riol
 *
 */
abstract class View extends System {

	/**
	 * хранит список заголовков, 1 заголовок по умолчанию
	 */
	private static $headers = array('Content-type: text/html; charset=UTF-8');
	
	/**
	 * счетчик заголовков
	 */
	private static $count_headers = 0;
	
	/**
	 * включать или нет шаблона wrapper
	 */
	private $on_wraps = true;
	
	/**
	 * метатеги
	 */
	private static $meta_title;
	private static $meta_description;
	private static $meta_keywords;

	public function __construct() {
		/**
		 * если страницу запросили аяксом, шаблон wrapper отключаем
		 */
		if($this->request->isAJAX()) $this->wraps_off();
		parent::__construct();
	}
	
	/**
	 * выводит основное содержимое
	 */
	abstract public function index();

	/**
	 * добавляет заголовки браузера в массив
	 * @param string $str
	 */
	protected function add_header($str) {
		if(self::$count_headers==0) self::$headers = array();
		array_push(self::$headers, $str);
		self::$count_headers++;
	}
	
	/**
	 * выключает header и footer шаблона
	 */
	public function wraps_off() {
		$this->on_wraps = false;
	}
	
	/**
	 * следующие методы устанавливают метатеги
	 */
	protected function set_meta_title($meta_title) {
		self::$meta_title = $meta_title;
	}
	
	protected function set_meta_description($meta_description) {
		self::$meta_description = $meta_description;
	}
	
	protected function set_meta_keywords($meta_keywords) {
		self::$meta_keywords = $meta_keywords;
	}

	/**
	 * отправляет заголовки в браузер
	 */
	public function sendHeaders() {
		if(count(self::$headers)>0) {
			foreach(self::$headers as $header) {
				header($header);
			}
		}
	}
	
	/**
	 * нужно ли загружать шаблон wrapper 
	 * @return boolean
	 */
	public function on_wrapper() {
		return $this->on_wraps;
	}
	
	/**
	 * следующие методы возвращают метатеги
	 */
	public function get_meta_title() {
		return (self::$meta_title ? self::$meta_title : $this->settings->meta_title);
	}
	
	public function get_meta_description() {
		return (self::$meta_description ? self::$meta_description : $this->settings->meta_description);
	}
	
	public function get_meta_keywords() {
		return (self::$meta_keywords ? self::$meta_keywords : $this->settings->meta_keywords);
	}
}