<?php

/**
 * Класс-обертка для обращения к переменным _GET, _POST, _FILES

 *
 */

class Request extends System {

	/**
	 * Конструктор, чистка слешей
	 */
	public function __construct()
	{		
		parent::__construct();
                if(!defined("SETUP_MODE") or !SETUP_MODE)
                    $this->antivirus->ScanInjectionAlerts();
		$_POST = $this->stripslashes_recursive($_POST);
		$_GET = $this->stripslashes_recursive($_GET);	
	}

	/**
	* Определение request-метода обращения к странице (GET, POST)
	* Если задан аргумент функции (название метода, в любом регистре), возвращает true или false
	* Если аргумент не задан, возвращает имя метода
	* 
	*/
    public function method($method = null)
    {
    	if(!empty($method))
    		return strtolower($_SERVER['REQUEST_METHOD']) == strtolower($method);
	    return strtolower($_SERVER['REQUEST_METHOD']);
    }

	/**
	* Возвращает переменную _GET, отфильтрованную по заданному типу, если во втором параметре указан тип фильтра
	* Второй параметр $type может иметь такие значения: integer, float, string, boolean, url, array
	* Если $type не задан, возвращает переменную в чистом виде
	*/
    public function get($name, $type = null)
    {
    	$val = null;
    	if(isset($_GET[$name])) $val = $_GET[$name];
    		
    	if(!empty($type) and $type!="array" and is_array($val)) $val = reset($val);
    	
    	if(!empty($type)) $val = $this->get_str($val, $type);
    		
    	return $val;
    }

	/**
	* Возвращает переменную _POST, отфильтрованную по заданному типу, если во втором параметре указан тип фильтра
	* Второй параметр $type может иметь такие значения: integer, float, string, boolean, url
	* Если $type не задан, возвращает переменную в чистом виде
	*/
    public function post($name = null, $type = null)
    {
    	$val = null;
    	if(!empty($name) && isset($_POST[$name])) $val = $_POST[$name];
    	elseif(empty($name)) $val = file_get_contents('php://input');
    	
    	if(!empty($type) and $type!="array" and is_array($val)) $val = reset($val);
    		
    	if(!empty($type)) $val = $this->get_str($val, $type);

    	return $val;
    }
    
    /**
     * обрабатывает строку с помощью указанного фильтра
     * @param string $str 
     * integer - целое число
     * float
     * string - строка без html 
     * boolean
     * url - url адрес
     * @param string $filter 
     */
    public function get_str($str, $filter) {
    	switch($filter) {
    		case "integer": $str = intval($str); break;
    		case "float": $str = floatval($str); break;
    		case "boolean": $str = intval($str)>0; break;
    		case "string": $str = F::clean($str); break;
    		case "url": $str = F::url($str); break;
    	}
    	return $str;
    }

	/**
	* Возвращает переменную _FILES
	* Обычно переменные _FILES являются двухмерными массивами, поэтому можно указать второй параметр,
	* например, чтобы получить имя загруженного файла
	*/
    public function files($name, $name2 = null)
    {
    	if(!empty($name2) && !empty($_FILES[$name][$name2]))
    		return $_FILES[$name][$name2];
    	elseif(empty($name2) && !empty($_FILES[$name]))
    		return $_FILES[$name];
    	else
    		return null;
    }

	/**
	 * Рекурсивная чистка магических слешей
	 */
	public function stripslashes_recursive($var)
	{
		if(get_magic_quotes_gpc())
		{
			$res = null;
			if(is_array($var))
				foreach($var as $k=>$v)
					$res[stripslashes($k)] = $this->stripslashes_recursive($v);
				else
					$res = stripslashes($var);
		}
		else
		{
			$res = $var;
		}
		return $res;
	}
    
	/**
	 * проверяет, был ли отправлен запрос на сервер аяксом
	 * @return boolean
	 */
	public function isAJAX() {
		return (isset($_SERVER['HTTP_X_REQUESTED_WITH']) and $_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest');
	}
}


