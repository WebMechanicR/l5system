<?php
/**
 * класс для работы с кешем, поддерживает разные адаптеры
 * @author riol
 *
 */
class Cache extends System {
	/**
	 * Объект бэкенда кеширования
	 *
	 * @var Zend_Cache_Backend
	 */
	protected $oBackendCache=null;

	/**
	 * Тип кеширования, определяется автоматически изходя из сервера и настройки (для мемкеш)
	 *
	 * @var string
	 */
	protected $sCacheType;
	/**
	 * Статистика кеширования
	 *
	 * @var array
	 */
	protected $aStats=array(
			'time' =>0,
			'count' => 0,
			'count_get' => 0,
			'count_set' => 0,
	);

	public function __construct() {
		if (!defined("USE_CACHE") or !USE_CACHE) {
			return false;
		}
		/**
		 * подключаем необходимые файлы
		 */
		define("DKCACHE_PATH", dirname(__FILE__).'/external/Dklab_Cache/');

		require_once DKCACHE_PATH.'Zend/Cache.php';
		require_once DKCACHE_PATH.'Dklab/Backend/TagEmuWrapper.php';
		if(DEBUG_MODE) require_once DKCACHE_PATH.'Dklab/Backend/Profiler.php';

		$this->set_cachetype();

		/**
		 * Файловый кеш
		*/
		if ($this->sCacheType=="file") {
			require_once DKCACHE_PATH.'Zend/Cache/Backend/File.php';
			$oCahe = new Zend_Cache_Backend_File(
					array(
							'cache_dir' => CACHE_DIR,
							'file_name_prefix'	=> CACHE_PREFIX,
							'read_control_type' => 'crc32',
							'hashed_directory_level' => 2,
							'read_control' => true,
							'file_locking' => true,
					)
			);
			if(DEBUG_MODE) $this->oBackendCache = new Dklab_Cache_Backend_Profiler($oCahe,array($this,'CalcStats'));
			else $this->oBackendCache = $oCahe;
		}
		/**
		 * Кеш на основе Memcached
		 */
		elseif ($this->sCacheType=="memcache") {
			require_once DKCACHE_PATH.'Dklab/Backend/MemcachedMultiload.php';

			$oCahe = new Dklab_Cache_Backend_MemcachedMultiload(System::$CONFIG['memcache']);

			if(DEBUG_MODE) $this->oBackendCache = new Dklab_Cache_Backend_TagEmuWrapper(new Dklab_Cache_Backend_Profiler($oCahe,array($this,'CalcStats')));
			else $this->oBackendCache = new Dklab_Cache_Backend_TagEmuWrapper($oCahe);
		}
		/**
		 * Кеш на основе XCache
		 */
		elseif ($this->sCacheType=="xcache") {
			require_once DKCACHE_PATH.'Zend/Cache/Backend/Xcache.php';

			$oCahe = new Zend_Cache_Backend_Xcache( (isset(System::$CONFIG['xcache']) and is_array(System::$CONFIG['xcache'])) ? System::$CONFIG['xcache'] : array());
			if(DEBUG_MODE) $this->oBackendCache = new Dklab_Cache_Backend_TagEmuWrapper(new Dklab_Cache_Backend_Profiler($oCahe,array($this,'CalcStats')));
			else $this->oBackendCache = new Dklab_Cache_Backend_TagEmuWrapper($oCahe);
		} else {
			throw new Exception("Wrong type of caching: ".$this->sCacheType." (file, memcache, xcache)");
		}
	}

	/**
	 * автоматически определяет, какую систему кеширования можно использовать на сервере
	 */
	private function set_cachetype() {
		if(CACHE_TYPE=='auto') {
			if(extension_loaded('memcache') and isset(System::$CONFIG['memcache'])) $this->sCacheType = "memcache";
			elseif(extension_loaded('xcache')) $this->sCacheType = "xcache";
			else $this->sCacheType = "file";
		}
		else $this->sCacheType = CACHE_TYPE;
	}

	/**
	 * Получить значение из кеша
	 *
	 * @param string $key Имя ключа
	 * @return mixed|bool
	 */
	public function get($key) {
		if (!defined("USE_CACHE") or !USE_CACHE) {
			return false;
		}

		if(DEBUG_MODE) Debug_HackerConsole_Main::out($key, "Cache read");
		/**
		 * Т.к. название кеша может быть любым то предварительно хешируем имя кеша
		 */
		$key=md5(CACHE_PREFIX.$key);
		$data=$this->oBackendCache->load($key);
		if ($this->sCacheType=="file" and $data!==false) {
			return unserialize($data);
		} else {
			return $data;
		}

	}

	/**
	 * Записать значение в кеш
	 *
	 * @param  mixed  $data	Данные для хранения в кеше
	 * @param  string $key	Имя ключа
	 * @param  array  $tags	Список тегов, для возможности удалять сразу несколько кешей по тегу
	 * @param  int    $iTimeLife	Время жизни кеша в секундах
	 * @return bool
	 */
	public function set($data,$key,$tags=array(),$iTimeLife=false) {
		if (!USE_CACHE) {
			return false;
		}
		
		if(DEBUG_MODE) Debug_HackerConsole_Main::out($key, "Cache write");
		/**
		 * Т.к. название кеша может быть любым то предварительно хешируем имя кеша
		 */
		$key=md5(CACHE_PREFIX.$key);
		if ($this->sCacheType=="file") {
			$data=serialize($data);
		}

		if (!is_array($tags)) $tags = array((string) $tags);

		return $this->oBackendCache->save($data,$key,$tags,$iTimeLife);
	}

	/**
	 * Удаляет значение из кеша по ключу(имени)
	 *
	 * @param string $key	Имя ключа
	 * @return bool
	 */
	public function delete($key) {
		if (!USE_CACHE) {
			return false;
		}
		/**
		 * Т.к. название кеша может быть любым то предварительно хешируем имя кеша
		 */
		$key=md5(CACHE_PREFIX.$key);
		return $this->oBackendCache->remove($key);
	}

	/**
	 * Чистит кеши

	 * @param   array $tags
	 * @return  bool
	 */
	public function clean($tags = array(), $no_delay=true)
	{
		if (!USE_CACHE) {
			return false;
		}

		$mode = Zend_Cache::CLEANING_MODE_ALL;
		if (!is_array($tags)) $tags = array((string) $tags);
		/**
		 * если есть теги - удаляем только по тегам, иначе чистим все
		*/
		if(count($tags)>0) $mode = Zend_Cache::CLEANING_MODE_MATCHING_TAG;

		return $this->oBackendCache->clean($mode, $tags);
	}

	/**
	 * Подсчет статистики использования кеша
	 *
	 * @param int $iTime	Время выполнения метода
	 * @param string $sMethod	имя метода
	 */
	public function CalcStats($iTime,$sMethod) {
		$this->aStats['time']+=$iTime;
		$this->aStats['count']++;
		if ($sMethod=='Dklab_Cache_Backend_Profiler::load') {
			$this->aStats['count_get']++;
		}
		if ($sMethod=='Dklab_Cache_Backend_Profiler::save') {
			$this->aStats['count_set']++;
		}
	}
	/**
	 * Возвращает статистику использования кеша
	 *
	 * @return array
	 */
	public function GetStats() {
		return $this->aStats;
	}
}