<?php
/**
 * класс для работы с базой
 * @author riol
 *
 */

require_once dirname(__FILE__).'/external/DbSimple/Connect.php';

class DB extends DbSimple_Connect  {
	
	/**
	 * количество запросов к базе
	 */
	public static $num_queries = 0;
	
	/**
	 * соединение с базой
	 */
	public function __construct() {
		parent::__construct("mypdo://".DB_USER.":".DB_PASSWORD."@".DB_HOST."/".DB_NAME."?enc=UTF8");
		parent::setIdentPrefix(DB_PREFIX_);
// 		parent::setErrorHandler();
		if(DEBUG_MODE) parent::setLogger(array($this, "mySqlLogger"));
	} 
	
	public function mySqlLogger($db, $sql) {
		self::$num_queries++;
		Debug_HackerConsole_Main::out($sql, "Queries");
	}
	
	public function get_num_queries() {
		return self::$num_queries/2;
	}
}