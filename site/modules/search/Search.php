<?php
class Search extends Module {

	protected $module_name = "search";
	private $module_table = "search_stat";
	private $module_nesting = false; //возможность владывать подстраницы в модуль

	private $module_settings = array(
	);


	/**
	 * добавляет новый элемент в базу
	*/
	public function add($order) {
		return $this->db->query("INSERT INTO ?_".$this->module_table." (?#) VALUES (?a)", array_keys($order), array_values($order));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $order) {

		if($this->db->query("UPDATE ?_".$this->module_table." SET ?a WHERE id IN (?a)", $order, (array)$id))
			return $id;
		else
			return false;
	}


	/**
	 * возвращает настройку модуля
	 * @param string $id
	 * @return Ambigous <NULL, multitype:string >
	 */
	public function setting($id) {
		return (isset($this->module_settings[$id]) ? $this->module_settings[$id] : null);
	}

	/**
	 * @return boolean
	 */
	public function is_nesting() {
		return $this->module_nesting;
	}


	/**
	 * возвращает записи роутера для модуля
	 * {url_page} - подстановка адреса (full_link) страницы
	 */
	public function get_router_records() {
		return array(
				array('{url_page}(\/?)', 'module=search&page_url={url_page}'),
				array('{url_page}/index_([0-9]+).htm', 'module=search&page_url={url_page}&p=$1'),
				array('{url_page}/quick.htm', 'module=search&action=quick&page_url={url_page}')
		);
	}

	/**
	 * возвращает двумерный массив из поисковых выражений
	 *  первый уровень - альтернативные поисковые запросы (транслит, разное написание)
	 *  	в подмассиве варианта содержатся ключевые его слова
	 * @param string $q
	 */
	public function prepareQuery($q) {
		$queries = $t_queries = array();

		//убираем все символы кроме букв, цифр и дефисов
		$q = preg_replace('/[^0-9a-zа-я-]/uis', " ", $q);
		if($q!="") {
			//отделим латинские буквы от кириллицы пробелами, и цифры от букв пробелами
			$q = preg_replace("#([a-zA-Z])([а-яА-Я])#","$1 $2",$q);
			$q = preg_replace("#([а-яА-Я])([a-zA-Z])#","$1 $2",$q);
			$q = preg_replace("#([0-9])([a-zA-ZА-Яа-я])#","$1 $2",$q);
			$q = preg_replace("#([a-zA-ZА-Яа-я])([0-9])#","$1 $2",$q);
			$q = mb_strtolower($q);

			// Разобрать искомую строку на отдельные слова
			preg_match_all('/[0-9a-zа-я-]{3,}/uis', $q, $matches);
			$t_queries[] = array_unique($matches[0]);
				
			$puntoQ = $this->puntoSwitch($q);
			if($puntoQ!=$q) {
				preg_match_all('/[0-9a-zа-я-]{3,}/uis', $puntoQ, $matches);
				$t_queries[] = array_unique($matches[0]);
			}
				
			$similarQ = $this->changeSimilarSymbols($q);
			if($similarQ!=$q) {
				preg_match_all('/[0-9a-zа-я-]{3,}/uis', $similarQ, $matches);
				$t_queries[] = array_unique($matches[0]);
			}
			
			$similarQ = $this->changeSimilarSymbols($q, true);
			if($similarQ!=$q) {
				preg_match_all('/[0-9a-zа-я-]{3,}/uis', $similarQ, $matches);
				$t_queries[] = array_unique($matches[0]);
			}
			
			$translitQ= $this->translit($q);
			
			if($translitQ!=$q) {
				preg_match_all('/[0-9a-zа-я-]{3,}/uis', $translitQ, $matches);
				$t_queries[] = array_unique($matches[0]);
			}
			

			foreach($t_queries as $words) {
				$true_words = array();
				if (count($words)) {
					foreach($words as $word) {
						// Обрабатывать только слова длиннее 2 символов
						if (mb_strlen($word)>=3) {
							// От слов длиннее 7 символов отрезать 2 последних буквы
							if (mb_strlen($word)>7 and !is_numeric($word)) {
								$word=mb_substr($word,0,(mb_strlen($word)-2));
							}
							// От слов длиннее 5 символов отрезать последнюю букву
							elseif (mb_strlen($word)>5 and !is_numeric($word)) {
								$word=mb_substr($word,0,(mb_strlen($word)-1));
							}
							$true_words[]=addcslashes(addslashes($word),'%_');
						}
					}
					// Список уникальных поисковых слов
					$true_words=array_unique($true_words);
					if(count($true_words)) $queries[] = $true_words;
				}
			}
		}

		return $queries;
	}
	
	
	/**
	 * записывает статистику поискового запроса в базу
	 * @param запрос $q
	 * @param кол-во найденных $count
	 * @param тип поиска $type_search
	 */
	public function add_stat_query($q, $count, $type_search) {
		if($id_stat = $this->db->selectCell("SELECT id FROM ?_".$this->module_table." WHERE query LIKE ? AND type_search=?", $q, $type_search)) {
			$this->db->selectCell("UPDATE ?_".$this->module_table." SET count=count+1, results=?d, date_add=?d WHERE id=?d", $count, time(), $id_stat);
		}
		else {
			$this->db->selectCell("INSERT INTO ?_".$this->module_table." (query, results, date_add, type_search	) VALUES (?, ?d, ?d, ?)", $q, $count, time(), $type_search);
		}
	}
	
	/**
	 * возвращает запросы удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_list_queries($filter=array()) {
		$sort_by = " ORDER BY n.id DESC";
		$limit = "";
		$where = "";
	
		if(isset($filter['sort']) and count($filter['sort'])==2) {
			if(!in_array($filter['sort'][0], array("id", "query", "date_add", "count", "results"))) $filter['sort'][0] = "id";
			if(!in_array($filter['sort'][1], array("asc", "desc")) ) $filter['sort'][1] = "desc";
			$sort_by = " ORDER BY n.".$filter['sort'][0]." ".$filter['sort'][1];
		}
	
		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}
	
		if(isset($filter['type_search'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.type_search='".$filter['type_search']."'";
		}
	
		if(isset($filter['query']) and $filter['query']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.query LIKE '%".$filter['query']."%'";
		}
		
		if(isset($filter['is_results']) and $filter['is_results']>0) {
			if($filter['is_results']==1) $where .= (empty($where) ? " WHERE " : " AND ")."n.results>0";
			else $where .= (empty($where) ? " WHERE " : " AND ")."n.results=0";
		}
	
		if(isset($filter['date_from']) and $filter['date_from']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add>=".intval($filter['date_from']);
		}
		
		if(isset($filter['date_to']) and $filter['date_to']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add<=".intval($filter['date_to']);
		}
		
		return $this->db->select("SELECT n.*
				FROM ?_".$this->module_table." n".$where
				.$sort_by.$limit);
	}
	
	/**
	 * возвращает количество запросов удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_count_queries($filter=array()) {
		$where = "";
	
		if(isset($filter['type_search'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.type_search='".$filter['type_search']."'";
		}
	
		if(isset($filter['query']) and $filter['query']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.query LIKE '%".$filter['query']."%'";
		}
		
		if(isset($filter['is_results']) and $filter['is_results']>0) {
			if($filter['is_results']==1) $where .= (empty($where) ? " WHERE " : " AND ")."n.results>0";
			else $where .= (empty($where) ? " WHERE " : " AND ")."n.results=0";
		}
		
		if(isset($filter['date_from']) and $filter['date_from']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add>=".intval($filter['date_from']);
		}
		
		if(isset($filter['date_to']) and $filter['date_to']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add<=".intval($filter['date_to']);
		}
	
		return $this->db->selectCell("SELECT count(n.id)
				FROM ?_".$this->module_table." n".$where);
	}

	/**
	 * заменяет символы, набранные в неверной раскладке
	 * @param string $text
	 * @return string
	 */
	public 	function puntoSwitch ($text) {
		$str_search = array(
				'й'=>'q',
				'ц'=>'w',
				'у'=>'e',
				'к'=>'r',
				'е'=>'t',
				'н'=>'y',
				'г'=>'u',
				'ш'=>'i',
				'щ'=>'o',
				'з'=>'p',
				'х'=>'[',
				'ъ'=>']',
				'ф'=>'a',
				'ы'=>'s',
				'в'=>'d',
				'а'=>'f',
				'п'=>'g',
				'р'=>'h',
				'о'=>'j',
				'л'=>'k',
				'д'=>'l',
				'ж'=>';',
				'э'=>"'",
				'я'=>'z',
				'ч'=>'x',
				'с'=>'c',
				'м'=>'v',
				'и'=>'b',
				'т'=>'n',
				'ь'=>'m',
				'б'=>',',
				'ю'=>'.',
				'q'=>'й',
				'w'=>'ц',
				'e'=>'у',
				'r'=>'к',
				't'=>'е',
				'y'=>'н',
				'u'=>'г',
				'i'=>'ш',
				'o'=>'щ',
				'p'=>'з',
				'['=>'х',
				']'=>'ъ',
				'a'=>'ф',
				's'=>'ы',
				'd'=>'в',
				'f'=>'а',
				'g'=>'п',
				'h'=>'р',
				'j'=>'о',
				'k'=>'л',
				'l'=>'д',
				';'=>'ж',
				'\''=>'э',
				'z'=>'я',
				'x'=>'ч',
				'c'=>'с',
				'v'=>'м',
				'b'=>'и',
				'n'=>'т',
				'm'=>'ь',
				','=>'б',
				'.'=>'ю'
		);
		return strtr($text,$str_search);
	}

	/**
	 * заменяет похожие англ буквы на русские
	 * @param string $text
	 * @return string
	 */
	public function changeSimilarSymbols( $text, $flip=false ) {
		$str_search = array(
				'а'=>'a',
				'р'=>'p',
				'н'=>'h',
				'о'=>'o',
				'с'=>'c',
				'м'=>'m',
				'т'=>'t',
				'у'=>'y',
				'е'=>'e',
				'х'=>'x'
		);
		if($flip) $str_search = array_flip($str_search);
		return strtr($text,$str_search);
	}
	
	private function translit($text)
	{
		$ru = explode('-', "А-а-Б-б-В-в-Г-г-Д-д-Е-е-Є-є-Ж-ж-З-з-И-и-Й-й-К-к-Л-л-М-м-Н-н-О-о-П-п-Р-р-С-с-Т-т-У-у-Ф-ф-Х-х-Ц-ц-Ч-ч-Ш-ш-Щ-щ-Ы-ы-Э-э-Ю-ю-Я-я");
		$en = explode('-', "A-a-B-b-V-v-G-g-D-d-E-e-E-e-ZH-zh-Z-z-I-i-J-j-K-k-L-l-M-m-N-n-O-o-P-p-R-r-S-s-T-t-U-u-F-f-H-h-TS-ts-CH-ch-SH-sh-SCH-sch-Y-y-E-e-YU-yu-YA-ya");
	
		$res = str_replace($en, $ru, $text);
		$res = preg_replace("/[\s]+/ui", ' ', $res);
		return $res;
	}
}