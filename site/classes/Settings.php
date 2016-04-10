<?php

/**
 * Управление настройками сайта, хранящимися в базе данных
 *
 * @author riol
 *
 */

class Settings extends System {
	private $vars = array();
	private $cache_key = "site_settings";

	public function __construct()
	{
		parent::__construct();
		
		if (false === ($settings = $this->cache->get($this->cache_key))) {
			$settings = $this->db->select('SELECT name, value FROM ?_settings');
			$this->cache->set($settings, $this->cache_key);
		}

		foreach($settings as $setting)
			$this->vars[$setting['name']] = $setting['value'];

	}

	public function __get($name)
	{
		if($name=="db" or $name=="cache") return parent::__get($name);

		if(isset($this->vars[$name]))
			return $this->vars[$name];
		else
			return null;
	}

	public function update_settings($settings)
	{
		foreach($settings as $name=>$value) {
			if(isset($this->vars[$name]))
				$this->db->query('UPDATE ?_settings SET value=? WHERE name=?', $value, $name);
			else
				$this->db->query('INSERT INTO ?_settings SET value=?, name=?', $value, $name);
			$this->vars[$name] = $value;
		}

		$this->cache->delete($this->cache_key);

	}
}