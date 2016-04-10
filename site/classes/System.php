<?php
/**
 * основной класс, все остальные классы его наследуют
 */

 
//Handling of errors
require_once("Errors.php");
 
class System {
	public $version = 0.01;

	private static $system_classes = array(
			"db" => "DB",
			"cache" => "Cache",
			"tpl" => "Template",
                        "errors" => "Errors",
			"settings" => "Settings",
                        "captcha" => "Captcha",
			"request" => "Request",
			"image" => "Image",
			"file" => "File",
			"revision" => "Revision",
			"router" => "Router",
			"mail" => "Mail"
	);



	/**
	 * уже созданные объекты
	*/
	private static $objects = array();

	public static $num_includs;

        public $errorHandlerObject = false;
        
	/**
	 * массив концигураций
	 */
	public static $CONFIG;

	/**
	 * Создан ли объект класса
	 * @var System
	 */
	private static $instance = false;

	public static $db, $tpl, $request;

	public function __construct() {
                global $errorHandlerObject;
                $this->errorHandlerObject = $errorHandlerObject;
               
		/**
		 * если объект создается первый раз,
		 */
		if(!self::$instance) {
			self::$instance = $this;
			global $CONFIG;
			self::$CONFIG = $CONFIG;
			/**
			 * основные php настройки
			 */

			setlocale(LC_ALL, 'ru_RU.UTF-8');
			setlocale(LC_NUMERIC, "C");

			if (is_callable('mb_internal_encoding')) {
				mb_internal_encoding('UTF-8');
			}

			/**
			 * определяем site_url и root_dir
			 */
			$localpath=getenv("SCRIPT_NAME");
			$absolutepath=getenv("SCRIPT_FILENAME");
			$_SERVER['DOCUMENT_ROOT']=substr($absolutepath,0, strpos($absolutepath,$localpath));

			$script_dir1 = realpath(dirname(dirname(__FILE__)));
			$script_dir2 = realpath($_SERVER['DOCUMENT_ROOT']);
			$subdir = trim(substr($script_dir1, strlen($script_dir2)), "/\\");
                        $subdir = str_replace('\\', '/',  $subdir);

			@$protocol = strtolower(substr($_SERVER["SERVER_PROTOCOL"],0,5))=='https'? 'https' : 'http';
			@$root_url = $protocol.'://'.rtrim($_SERVER['HTTP_HOST']);
			if(!empty($subdir)) $root_url .= '/'.$subdir;

			define ("ROOT_DIR", dirname(dirname(__FILE__)).'/');
			define ("SITE_URL", $root_url.'/');
			define ("TPL_DIRL", ROOT_DIR.'templates/');
			define ("TPL_EXTD", '.tpl.php');

			spl_autoload_register(array(self::$instance, "autoload"));

			if(DEBUG_MODE) {
				require_once dirname(__FILE__)."/external/HackerConsole/Main.php";
				new Debug_HackerConsole_Main(!(isset($_SERVER['HTTP_X_REQUESTED_WITH']) and $_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'));
			}

		}
	}

	public function __get($name) {
		//почистим на всякий случай
		$name = preg_replace("/[^-A-Za-z0-9_\.]+/", "", $name);

		// Если такой модуль-объект уже существует, возвращаем его
		if(isset(self::$objects[$name]))
		{
			return(self::$objects[$name]);
		}

		/*
		 * если класс имеется в системных - подключаем оттуда
		*/
		if(isset(self::$system_classes[$name])) {
			$class = self::$system_classes[$name];
			return self::$objects[$name] = new $class();
		}

		/*
		 * иначе подключаем как модуль
		*/
		$class = ucfirst($name);
		// Подключаем его
		if (!file_exists(ROOT_DIR.'modules/'.$name.'/'.$class.'.php')) {
                        $msg = sprintf('Not found file [%1$s] for class [%2$s]', ROOT_DIR.'modules/'.$name.'/'.$class.'.php', $class);
                        if($this->errorHandlerObject)
                        {
                             $trace = debug_backtrace();
                             $file = $trace[0]['file'];
                             $line = $trace[0]['line'];
                             $this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 1, $msg, $file, $line);
                        }
                        else{
                           die( $msg );
                        }
			
		}
		include_once(ROOT_DIR.'modules/'.$name.'/'.$class.'.php');

		if(DEBUG_MODE) {
			Debug_HackerConsole_Main::out('modules/'.$name.'/'.$class.'.php', "Hidden includes");
			self::$num_includs++;
		}
		if (!class_exists($class, false)) {
			$msg = sprintf('Not found class [%2$s] at file [%1$s]', ROOT_DIR.'modules/'.$name.'/'.$class.'.php', $class);
                        if($this->errorHandlerObject)
                        {
                             $trace = debug_backtrace();
                             $file = $trace[0]['file'];
                             $line = $trace[0]['line'];
                             $this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 1, $msg, $file, $line);
                        }
                        else{
                           die( $msg );
                        }
		}
		// Сохраняем для будущих обращений к нему
		self::$objects[$name] = new $class();

		// Возвращаем созданный объект
		return self::$objects[$name];
	}

	public function __call($name, $arguments) {
		$msg = "вызван несуществующий метод ".$name ;

                if($this->errorHandlerObject)
                {   
                    $trace = debug_backtrace();
                    $file = $trace[0]['file'];
                    $line = $trace[0]['line'];
                    $this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 1, $msg, $file, $line);
                }
                else{
                   die( $msg );
                }    
	}

	/**
	 * подгружает системные классын
	 * @param string $class_name
	 */
	public static function autoload ($class_name) {
		//почистим на всякий случай
		$class_name = preg_replace("/[^-A-Za-z0-9_\.]+/", "", $class_name);
		global $errorHandlerObject;
		/*
		 * проверяем наличие файла
		*/
		if (!file_exists(ROOT_DIR.'classes/'.$class_name.'.php')) {
			$msg = sprintf('Not found file [%1$s] for class [%2$s]', ROOT_DIR.'classes/'.$class_name.'.php', $class_name);

                        if($errorHandlerObject)
                        {   
                            $errorHandlerObject->Push(ERROR_HANDLER_ERROR, 1, $msg);
                        }
                        else{
                            die( $msg );
                        }   
		}

		require_once (ROOT_DIR.'classes/'.$class_name.'.php');
		if(DEBUG_MODE) {
			Debug_HackerConsole_Main::out('classes/'.$class_name.'.php', "Hidden includes");
			self::$num_includs++;
		}
		if (!class_exists($class_name, false) && !interface_exists($class_name, false)) {
			$msg = sprintf('Not found class [%2$s] at file [%1$s]', ROOT_DIR.'classes/'.$class_name.'.php', $class_name);
			if($this->errorHandlerObject)
                        {   
                            $trace = debug_backtrace();
                            $file = $trace[0]['file'];
                            $line = $trace[0]['line'];
                            $this->errorHandlerObject->Push(ERROR_HANDLER_ERROR, 1, $msg, $file, $line);
                        }
                        else{
                             die( $msg );
                        }   
		}
		return true;

	}


	/**
	 * возвращает массив всех модулей сайта
	 *
	 * @param array $filtres - условия выборки
	 */

	public function get_modules($filtres=array()) {
		if(count($filtres)>0) return $this->db->select("SELECT id, name FROM ?_modules WHERE ?a ORDER BY sort ASC", $filtres);
		else return $this->db->select("SELECT id, name FROM ?_modules ORDER BY sort ASC");
	}

	/**
	 * проверка на существование модуля
	 * @param string $module
	 * @return boolean
	 */
	public function isset_module($module) {
		if($this->db->selectCell("SELECT id FROM ?_modules WHERE id=?", $module)) return true;
		else return false;
	}
}