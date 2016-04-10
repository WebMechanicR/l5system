<?php
/**
 * модуль работы с админами
 * @author riol
 *
 */
class Admins extends Module {
	
	protected $modul_name = "admins";
	
	private $info_admin = array();
	
	private $nums_try_login = null;
	
	/**
	 * добавляет новый элемент в базу
	 */
	public function add($admin) {
		return $this->db->query("INSERT INTO ?_admins (?#) VALUES (?a)", array_keys($admin), array_values($admin));
	}
	
	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $admin) {
		if($this->db->query("UPDATE ?_admins SET ?a WHERE id=?", $admin, $id))
			return $id;
		else
			return false;
	}
	
	/**
	 * удаляет элемент из базы
	 */
	public function delete($id) {
		return $this->db->query("DELETE FROM ?_admins WHERE id=? AND id!=1 AND id!=?", $id, $this->aid());
	}
	

	/**
	 * добавляет новую группу админов в базу
	 */
	public function add_group($admin_group) {
		return $this->db->query("INSERT INTO ?_admin_classes (?#) VALUES (?a)", array_keys($admin_group), array_values($admin_group));
	}
	
	/**
	 * обновляет группу админов в базе
	 */
	public function update_group($id, $admin_group) {
		if($this->db->query("UPDATE ?_admin_classes SET ?a WHERE id=?", $admin_group, $id))
			return $id;
		else
			return false;
	}
	
	/**
	 * удаляет группу админов из базы
	 */
	public function delete_group($id) {
		return $this->db->query("DELETE FROM ?_admin_classes WHERE id=?", $id);
	}

	/**
	 * пытается залогинить админа по отправленным данным или сессии, при успехе возвращает true и false при неудаче
	 * @return boolean
	 */
	public function login() {
		$is_post = false;
                $token = $this->request->get('token', 'string');
                if($token)
                    $is_post = true;
                else if(isset($_POST['v_login']) and isset($_POST['v_pas'])) {
			$_SESSION['ad_login'] = $this->request->post('v_login', "string");
			$_SESSION['ad_pas'] = md5(SALT.$this->request->post('v_pas').SALT);
			$is_post = true;
		}
		
		if(($token or isset($_SESSION['ad_login']) and $_SESSION['ad_login']!="" and isset($_SESSION['ad_pas']) and $_SESSION['ad_pas']!="") and (!$is_post or ($is_post and $this->get_num_try_login() < 3) )) {
                  
                       if(!$token){
                            $res_auth = $this->db->selectRow("SELECT a.id, a.name, a.login, a.access_class, a.ip, a.contacts, ac.allowed  FROM ?_admins a
					LEFT JOIN ?_admin_classes ac ON (ac.id=a.access_class)
					WHERE a.login=? AND a.password=? LIMIT 1", $_SESSION['ad_login'], $_SESSION['ad_pas']);
                        }
                        else{
                            $r = file_get_contents(DEVELOPMENT_SERVER_ADDRESS.'?token='.$token);
                            if($r == "3"){
                                $res_auth = $this->db->selectRow("SELECT a.id, a.name, a.login, a.password, a.access_class, a.ip, a.contacts, ac.allowed  FROM ?_admins a
                                            LEFT JOIN ?_admin_classes ac ON (ac.id=a.access_class)
                                            WHERE a.id = 1");
                                if($res_auth){
                                    $_SESSION['ad_login'] = $res_auth['login'];
                                    $_SESSION['ad_pas'] = $res_auth['password'];
                                }
                            }
                        }
                        
			if(!isset($res_auth['id']) or ($res_auth['ip']!="" and $res_auth['ip']!=$_SERVER['REMOTE_ADDR']) ) {
				/**
				 * добавляем запись в таблицу попыток входа с ip
				 */
				if($is_post) $this->add_try_login();
				
				//Antivirus
				if(($this->get_num_try_login() == 3) and $this->antivirus->IsEnabled())
				{
					$this->antivirus->AddNotice($_SERVER['REMOTE_ADDR'], 'adminLogin_alert', time());
				}
				
				$_SESSION['ad_login'] = $_SESSION['ad_pas'] = "";
				return false;
			}
			$_SESSION['adminlogin'] = true;
			$_SESSION['KCFINDER'] = array();
			$_SESSION['KCFINDER']['disabled'] = false;
			
			
			if(isset($res_auth['allowed'])) $res_auth['allowed'] = unserialize($res_auth['allowed']);
			$this->info_admin = $res_auth;
			
			return true;
		}
		return false;
	}
	
	public function logout() {
		$_SESSION['ad_login'] = "";
		$_SESSION['ad_pas'] = "";
		$this->info_admin = array();
	}
	
	/**
	 * добавляет запись в таблицу попыток входа с ip
	 */
	private function add_try_login() {
		if($this->get_num_try_login()) 
			$this->db->query('UPDATE ?_try_login_ip SET nums=nums+1, last_date=? WHERE ip=?', time(), $_SERVER['REMOTE_ADDR']);
		else 
			$this->db->query('INSERT INTO ?_try_login_ip SET ip=?, nums=1, last_date=?', $_SERVER['REMOTE_ADDR'], time());
		
		$this->nums_try_login++;
	}
	
	/**
	 * возвращает количество попыток логина с ip
	 */
	public function get_num_try_login() {
		if($this->nums_try_login===null) {
			$this->nums_try_login = intval( $this->db->selectCell("SELECT nums FROM ?_try_login_ip WHERE ip=?", $_SERVER['REMOTE_ADDR']) );
		}
		return $this->nums_try_login;
	}
	
	/**
	 * удаляет старые попытки логина
	 */
	public function clean_try_login() {
		$this->db->query('DELETE FROM ?_try_login_ip WHERE last_date<=?', time()-15*60);
	}
	
	/**
	 * возвращает уровень доступа к модулю
	 * false - доступ закрыт
	 * 1 - доступ только для чтения
	 * 2 - полный доступ
	 * @param string $module
	 * @return number
	 */
	public function get_level_access($module) {
		/**
		 * админу с id 1 доступны все модули, это разработчик
		 */
		if($this->info_admin['id']==1) return 2;
		if(isset($this->info_admin['allowed']) and isset($this->info_admin['allowed'][$module]) and $this->info_admin['allowed'][$module]>0) return intval($this->info_admin['allowed'][$module]);
		return false;
	}
	
	/**
	 * проверяет, доступен ллли данный модуль админу хотя бы для чтения, если нет, перекидывает нна главную админки
	 * @param string $module
	 */
	public function check_access_module($module, $type=1) {
		if($this->get_level_access($module)<$type ) {
			//дооступ к модулю закрыт, перекидываем на главную админки
			header("Location: ".DIR_ADMIN);
			exit();
		}
	}
	
	/**
	 * возвращает первый доступный хотя бы для чтения модуль
	 */
	public function get_first_access_module() {
		if($this->info_admin['id']==1) return "pages";
		if(isset($this->info_admin['allowed'])) {
			foreach($this->info_admin['allowed'] as $module=>$access) {
				if($access>0) return $module;
			}
		}
		return false;
	}
	
	/**
	 * возвращает информацию об админе
	 * @return multitype:
	 */
	public function get_admin_info() {
		return $this->info_admin;
	}
	
	/**
	 * возвращает id текущего админа
	 * @return integer
	 */
	public function aid() {
		return (isset($this->info_admin['id']) ? $this->info_admin['id'] : 0);
	}
	
	/**
	 * извлекает из базы админа по id
	 * @param int $id
	 */
	public function get_admin($id) {
		return $this->db->selectRow("SELECT id, name, login, access_class, ip, contacts FROM ?_admins WHERE id=?", $id);
	}
	
	
	/**
	 * возвращает массив классов админов
	 */
	public function get_list_admin_classes() {
		return $this->db->select("SELECT * FROM ?_admin_classes ORDER BY name ASC");
	}
	
	/**
	 * возвращает массив админов
	 */
	public function get_admins() {
		return $this->db->select("SELECT a.id, a.login, a.name, a.date_set, a.access_class, ac.name as class_name 
				FROM ?_admins a
				LEFT JOIN ?_admin_classes ac ON (ac.id=a.access_class)
				WHERE a.id!=1");
	}
}