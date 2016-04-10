<?php
/**
 * класс для обработки шаблонов.
 * его задачи - загрузка файлов шаблонов, передача объектов в шаблоны
 * @author riol
 *
 */
class Template extends System {

	/**
	 * счетчик шаблонов
	 */
	private static $num_templates;
	
	/**
	 * переменные шаблона
	 * @var array;
	 */
	private $tpl_vars = array();

	/**
	 * если находимся в админке, будет содержать путь к подпапке шаблонов админки
	 * @var string
	*/
	private $folder_added;

	/**
	 * регистрирует переменную в шаблоне
	 * @param string $obj
	 * @param mixed $obj
	 */
	public function add_var($obj_name, $obj) {
		$this->tpl_vars[$obj_name] = $obj;
	}

	/**
	 * возвращает обработанное содержимое шаблона
	 * @param string $template
	 */
	public function fetch($template) {
		if (!file_exists(TPL_DIRL.$this->folder_added.$template.TPL_EXTD)) {
			$msg = 'Шаблон '.$template.TPL_EXTD.' не найден';
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
		else {
			self::$num_templates++;
			ob_start();
			extract($this->tpl_vars, EXTR_REFS);
			
			/**
			 * Доступ ко всем модулям в шаблонах через переменную $site
			 */
			$site = $this;
			include(TPL_DIRL.$this->folder_added.$template.TPL_EXTD);
			return ob_get_clean();
		}
	}

	/**
	 * выводит шаблон на печать
	 * @param string $template
	 * @param array $args - дополнительные переменные для шаблона
	 */
	public function display($template, $args = array()) {
		if($args) {
			foreach($args as $var=>$value) {
				$this->add_var($var, $value);
			}
		}
		echo $this->fetch($template);
	}

	/**
	 * переключает папку шаблонов на admin
	 */
	public function in_admin() {
		$this->folder_added = "admin/";
	}
	
	public function in_user() {
		$this->folder_added = "";
	}
	
	/**
	 * возвращает количество использованных шаблонов
	 */
	public function get_num_templates() {
		return self::$num_templates;
	}
	
}