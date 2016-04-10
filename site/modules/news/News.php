<?php
class News extends Module implements IElement {

	protected $module_name = "news";
	private $module_table = "news";
	private $module_nesting = false; //возможность владывать подстраницы в модуль

	private $module_settings = array(
			"dir_images" => "img/",
			"image_sizes"=> array (
					"big"=> array(1200, 5000, false, true),// ширина, высота, crop, watermark
					"normal"=> array(156, 157, true, false),
					"normal2"=> array(336, 160, true, false),
					"small"=> array(199, 94, true, false)
			),
			"images_content_type" => "news",
			"revisions_content_type" => "news"
	);


	/**
	 * добавляет новый элемент в базу
	*/
	public function add($news) {
		//чистим кеш
		$this->cache->clean("list_news");
		return $this->db->query("INSERT INTO ?_".$this->module_table." (?#) VALUES (?a)", array_keys($news), array_values($news));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $news) {
		/**
		 * при изменении имени файла перестраиваем пути у вложенных страниц
		 */
		if(isset($news['url'])) {
			$this->cache->delete("news_".$news["url"]);
		}

		/**
		 * при изменении даты стираем кеш все списков новостей
		 */
		if(isset($news['date_add'])) {
			$old_news = $this->get_news($id);
			if($news['date_add']!=$old_news['date_add'] or $news['enabled']!=$old_news['enabled']) $this->cache->clean("list_news");
		}

		//чистим кеш
		if(is_array($id)) {
			$cache_tags = array();
			foreach($id as $one_id) {
				$cache_tags[] = "newsid_".$one_id;
			}
			if(isset($news['enabled'])) $cache_tags[] = "list_news";
			$this->cache->clean($cache_tags);
		}
		else {
			$this->cache->clean("newsid_".$id);
		}

		if($this->db->query("UPDATE ?_".$this->module_table." SET ?a WHERE id IN (?a)", $news, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete($id){
		$news = $this->get_news($id);

		//удаляем изображения
		$content_photos = $this->get_images($id);
		foreach($content_photos as $photo) {
			$this->delete_image($photo['id']);
		}

		$this->db->query("DELETE FROM ?_".$this->module_table." WHERE id=?", $id);

		$this->cache->delete("news_".$news['url']);
		$this->cache->clean(array("newsid_".$id, "list_news"));

		$this->clear_revisions($id);
	}

	/**
	 * создает копию элемента
	 */
	public function duplicate($id) {
		$new_id = null;
		if($news = $this->get_news($id)) {

			unset($news['id']);
			$news['title'] .= ' (копия)';
			$news['enabled'] = 0;

			while(($c = $this->get_news($news['url'])))
			{
				if(preg_match('/-([0-9]+)$/', $news['url'], $parts)) {
					$news['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $news['url']);
				}
				else {
					$news['url'] .= "-2";
				}
			}

			$new_id = (int)$this->add($news);

			// Дублируем изображения
			$images = $this->get_images($id);
			foreach($images as $image)
				$this->add_image_db($new_id, $image['picture'], $image['name'], $image['sort']);
		}
		return $new_id;
	}

	/**
	 * возвращает историю версий элемента
	 */
	public function get_list_revisions($for_id) {
		return $this->revision->get_list_revisions($for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * добавляет версию элемента в историю
	 */
	public function add_revision($for_id) {
		if($content = $this->get_news($for_id)) {
			return $this->revision->add_revision($for_id, $this->setting("revisions_content_type"), $content);
		}
		return null;
	}

	/**
	 * возвращает данные элемента из определенной ревизии
	 */
	public function get_from_revision($id, $for_id) {
		return $this->revision->get_from_revision($id, $for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * удаляет все ревизии элемента
	 */
	public function clear_revisions($for_id) {
		return $this->revision->clear_revisions($for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * возвращает новость по id или url
	 * @param mixed $id
	 * @return array
	 */
	public function get_news($id) {
		if(is_int($id)) {
			$where_field = "id";
		}
		elseif(is_string($id)) {
			$where_field = "url";
		}
		else return null;

		return $this->db->selectRow("SELECT * FROM ?_".$this->module_table." WHERE ".$where_field."=?", $id);
	}

	/**
	 * возвращает новости удовлетворяющие фильтрам
	 * @param array $filter
	 */
	public function get_list_news($filter=array()) {
		$sort_by = " ORDER BY n.date_add DESC";
		$limit = "";
		$where = "";
		if(isset($filter['sort']) and count($filter['sort'])==2) {
			if($filter['sort'][0]=='find_in_set' and isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {

				$new_in_ids = array();
				//выбираем id из списка только те, которые попадают на страницу, чтобы не сортировать при запросе лишнее
				for($i=($filter['limit'][0]-1)*$filter['limit'][1]; $i<(($filter['limit'][0]-1)*$filter['limit'][1]+$filter['limit'][1]); $i++) {
					if(!isset($filter['in_ids'][$i])) break;
					$new_in_ids[] = $filter['in_ids'][$i];
				}
				$filter['in_ids'] = $new_in_ids;
				$sort_by = " ORDER BY FIND_IN_SET(n.id, '".implode(",", $new_in_ids)."')";
				$filter['limit'] = array(1, $filter['limit'][1]);
			}
			else {
				if(!in_array($filter['sort'][0], array("title", "date_add", "enabled"))) $filter['sort'][0] = "date_add";
				if(!in_array($filter['sort'][1], array("asc", "desc")) ) $filter['sort'][1] = "desc";
				$sort_by = " ORDER BY n.".$filter['sort'][0]." ".$filter['sort'][1];
			}
		}

		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}

		if(isset($filter['enabled'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.enabled=".intval($filter['enabled']);
		}

		if(isset($filter['notid'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id!=".intval($filter['notid']);
		}

		if(isset($filter['date_add']) and count($filter['date_add'])==2) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add".($filter['date_add'][0]==0 ? "<" : ">")."=".intval($filter['date_add'][1]);
		}

		if(isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id IN (".implode(",", $filter['in_ids']).")";
		}

		if(isset($filter['year']) and $filter['year']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.year=".intval($filter['year']);
		}

		if(isset($filter['month']) and $filter['month']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.month=".intval($filter['month']);
		}

		return $this->db->select("SELECT n.id, n.title, n.url, n.date_add, n.enabled, n.brief_description, n.body, n.img
				FROM ?_".$this->module_table." n".$where
				.$sort_by.$limit);
	}

	/**
	 * возвращает количество новостей удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_count_news($filter=array()) {
		$where = "";

		if(isset($filter['enabled'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.enabled=".intval($filter['enabled']);
		}

		if(isset($filter['notid'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id!=".intval($filter['notid']);
		}

		if(isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id IN (".implode(",", $filter['in_ids']).")";
		}

		if(isset($filter['year']) and $filter['year']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.year=".intval($filter['year']);
		}

		if(isset($filter['month']) and $filter['month']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.month=".intval($filter['month']);
		}

		return $this->db->selectCell("SELECT count(n.id)
				FROM ?_".$this->module_table." n".$where);
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
	 * добавляет изображение
	 * @param int $news_id
	 * @param string $image
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_image($news_id, $image, $name, $sort) {
		$image_sizes = $this->setting("image_sizes");
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."big/".$image, $image_sizes["big"])) return false;
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$image, $image_sizes["normal"])) return false;
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."normal2/".$image, $image_sizes["normal2"])) return false;
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$image, $image_sizes["small"])) return false;
		$image_id = $this->add_image_db($news_id, $image, $name, $sort);
		if($sort==-1 and $image_id) {
			$this->db->query("UPDATE ?_attach_fotos SET sort=? WHERE id=?",$image_id, $image_id);
		}
		return $image_id;
	}

	/**
	 * добавляет запись об изображении в базу
	 * @param int $news_id
	 * @param string $image
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_image_db($news_id, $image, $name, $sort) {
		return $this->db->query("INSERT INTO ?_attach_fotos (for_id, picture, sort, name, content_type) VALUES (?, ?, ?, ?, ?)", $news_id, $image, $sort, $name, $this->setting("images_content_type"));
	}


	public function update_image($id, $image) {
		if($this->db->query("UPDATE ?_attach_fotos SET ?a WHERE id=?", $image, $id))
			return $id;
		else
			return false;
	}

	public function delete_image($id) {
		$picture = $this->db->selectRow("SELECT picture, for_id FROM ?_attach_fotos WHERE id=? AND content_type=?", $id, $this->setting("images_content_type"));
		if($picture and isset($picture['picture'])) {
			//проверяем, не используется ли это изображение где-то еще
			$count = $this->db->selectCell("SELECT count(*) FROM ?_attach_fotos WHERE picture=?", $picture['picture']);
			if($count==1) {
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$picture['picture']);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."big/".$picture['picture']);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$picture['picture']);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."normal2/".$picture['picture']);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$picture['picture']);
			}
		}
		$r = $this->db->query("DELETE FROM ?_attach_fotos WHERE id=? AND content_type=?", $id, $this->setting("images_content_type"));
		if($picture and isset($picture['for_id']) and $picture['for_id']>0) {
			if($content_photos = $this->get_images($picture['for_id'])) {
				if(isset($content_photos[0]) and isset($content_photos[0]['picture'])) $this->update($picture['for_id'], array("img"=>$content_photos[0]['picture']));
			}
		}
		return $r;
	}

	/**
	 * обновляет файл превью изображения
	 * @param string $image - название файла изображения
	 * @param array $picture_prev - файл изображения превью
	 * @param int $id - указывается, если нет названия файла изображения, но есть его id
	 */
	public function update_image_preview($image, $picture_prev, $id=false) {
		$image_sizes = $this->setting("image_sizes");
		$result = false;
		if($id) {
			$image = $this->db->selectCell("SELECT picture FROM ?_attach_fotos WHERE id=? AND content_type=?", $id, $this->setting("images_content_type"));
		}
		if($image) {
			if ($image_prev = $this->image->upload_image($picture_prev, "prev_".$picture_prev['name'], $this->setting("dir_images"))) {
				$result = $this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image_prev, ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$image, $image_sizes["normal"]) &
				//$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image_prev, ROOT_DIR_IMAGES.$this->setting("dir_images")."normal2/".$image, $image_sizes["normal2"]) &
				//$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image_prev, ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$image, $image_sizes["small"]);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image_prev);
			}
		}
		else return $result;
	}

	public function get_images($id) {
		return $this->db->select("SELECT * FROM ?_attach_fotos WHERE for_id=? AND content_type=? ORDER BY sort ASC", intval($id), $this->setting("images_content_type"));
	}

	/**
	 * @return boolean
	 */
	public function is_nesting() {
		return $this->module_nesting;
	}


	public function get_next_news($news) {
		$cache_key = "next_news_id".$news['id'];
		if (false === ($list_news = $this->cache->get($cache_key))) {
			$filter = array("enabled"=> 1, "notid"=>$news['id']);
			$filter["limit"] = array(1,1);
			$filter["date_add"] = array(0, $news['date_add']);
			$list_news = $this->get_list_news( $filter );
			$cache_tags = array("news", "list_news");
			if($list_news) {
				$list_news = $list_news[0];
				$cache_tags[] = "newsid_".$list_news['id'];
			}
			$this->cache->set($list_news, $cache_key, $cache_tags);
		}
		return $list_news;
	}

	public function get_prev_news($news) {
		$cache_key = "next_prev_id".$news['id'];
		if (false === ($list_news = $this->cache->get($cache_key))) {
			$filter = array("enabled"=> 1, "notid"=>$news['id'], "sort"=> array("n.date_add", "asc"));
			$filter["limit"] = array(1,1);
			$filter["date_add"] = array(1, $news['date_add']);
			$list_news = $this->get_list_news( $filter );
			$cache_tags = array("news", "list_news");
			if($list_news) {
				$list_news = $list_news[0];
				$cache_tags[] = "newsid_".$list_news['id'];
			}
			$this->cache->set($list_news, $cache_key, $cache_tags);
		}
		return $list_news;
	}

	/**
	 * возвращает записи роутера для модуля
	 * {url_page} - подстановка адреса (full_link) страницы
	 */
	public function get_router_records() {
		return array(
				array('{url_page}(\/?)', 'module=news&page_url={url_page}'),
				array('{url_page}/index_([0-9]+).htm', 'module=news&page_url={url_page}&p=$1'),
				array('{url_page}/([0-9]{4})/([0-9]{1,2})/index_([0-9]+).htm', 'module=news&page_url={url_page}&year=$1&month=$2&p=$3'),
				array('{url_page}/([0-9]{4})/([0-9]{1,2})(\/?)', 'module=news&page_url={url_page}&year=$1&month=$2'),
				array('{url_page}/([0-9]{4})/index_([0-9]+).htm', 'module=news&page_url={url_page}&year=$1&p=$2'),
				array('{url_page}/([0-9]{4})(\/?)', 'module=news&page_url={url_page}&year=$1'),
				array('{url_page}/([-a-zA-Z0-9_\.]+).htm', 'module=news&action=show_news&page_url={url_page}&url=$1')
		);
	}

	/**
	 * ищет новости по определенному запросу, возвращает массив id найденных товаров
	 * @param string $q - первоначальная строка запроса, она для ключа кеша
	 * @param array $ar_q - двумерный массив с ключевыми словами
	 */
	public function searchNews($q, $ar_q) {
		$cache_key = "search_newsids_".$q;
		if (false === ($news_ids = $this->cache->get($cache_key))) {
			// Вес отдельных слов в названии, описании
			$coeff_title=round((20/count($ar_q[0])),3);
			$coeff_brief=round((10/count($ar_q[0])),3);
			$sql = "SELECT n.id, ( IF (n.title LIKE ?, 30, 0) + IF (n.brief_description LIKE ?, 20, 0) + IF (n.body LIKE ?, 10, 0)";
			$placeholders = array("%".$q."%", "%".$q."%", "%".$q."%");

			$words = array();//массив уникальных слов из всего массива
			foreach($ar_q as $t_words) {
				foreach($t_words as $word) {
					if(!in_array($word, $words)) $words[] = $word;
				}
			}

			// Условия для каждого из слов
			foreach($words as $word) {
				$sql .= "+ IF (n.title LIKE ?, ".$coeff_title.", 0)";
				$sql .= "+ IF (n.brief_description LIKE ?, ".$coeff_brief.", 0)";
				$placeholders[] = "%".$word."%";
				$placeholders[] = "%".$word."%";
			}
			$sql.=") AS `relevant` FROM ?_".$this->module_table." n";

			// Условие выборки - вхождение фразы в названия
			$sql .= " WHERE n.enabled=1 AND (";
			$sql .= " n.title LIKE ? OR n.brief_description LIKE ? OR n.body LIKE ?";
			$placeholders[] = "%".$q."%";
			$placeholders[] = "%".$q."%";
			$placeholders[] = "%".$q."%";

			// дополнительные условия выборки - вхождение отдельных слов фразы в названия, слова одного словосочетания ищутся как "И"
			foreach($ar_q as $t_words) {
				$t_sql = "";
				foreach($t_words as $word) {
					$t_sql .= ($t_sql!="" ? " AND " : "")."(n.title LIKE ? OR n.brief_description LIKE ? OR n.body LIKE ?)";
					$placeholders[] = "%".$word."%";
					$placeholders[] = "%".$word."%";
					$placeholders[] = "%".$word."%";
				}
				if($t_sql!="") $sql .= " OR ( ".$t_sql." )";
			}
			$sql .= ") ORDER BY `relevant` DESC";
			array_unshift($placeholders, $sql);

			$news_ids = array();
			$t_news_ids = call_user_func_array(array(&$this->db, 'select'), $placeholders);
			$cache_tags = array("news", "list_news", "search_news");
			if($t_news_ids) {
				foreach($t_news_ids as $news) {
					$news_ids[] = $news['id'];
					$cache_tags[] = "newsid_".$news['id'];
				}
			}
			$this->cache->set($news_ids, $cache_key, $cache_tags, 2*24*60*60);
		}
		return $news_ids;
	}

	/**
	 * возвращает массив с годами активных новостей
	 */
	public function get_years($filter=array()) {

		return $this->db->selectCol("SELECT DISTINCT n.year FROM ?_".$this->module_table." n WHERE n.enabled=1 ORDER BY year DESC");
	}

	/**
	 * возвращает массив с месяцами активных новостей
	 */
	public function get_monthes($year, $filter=array()) {
		return $this->db->selectCol("SELECT DISTINCT n.month FROM ?_".$this->module_table." n WHERE n.enabled=1 AND n.year=?d ORDER BY month DESC", $year);
	}


	/**
	 * возвращает ссылки в виде массива для sitemap
	 */
	public function get_sitemap_links() {
		$links = array();
		$news_full_link = SITE_URL.$this->pages->get_full_link_module("news");

		$articles = $this->db->select("SELECT url FROM ?_".$this->module_table." WHERE enabled=1");
		foreach($articles as $article) {
			$links[] = $news_full_link.'/'.$article['url'].'.htm';
		}
		unset($articles);

		return $links;
	}

	/**
	 * возвращает кешуруемый список последних новостей
	 * @param unknown_type $limit
	 */
	public function get_list_last_news($limit=6) {
		$cache_key = "list_last_news_".$limit;
		if (false === ($list_news = $this->cache->get($cache_key))) {
			$filter = array("enabled" => 1);
			$filter["limit"] = array(1, $limit);
			$list_news = $this->news->get_list_news($filter);
			$cache_tags = array("news", "list_news");
			if ($list_news) {
				foreach ($list_news as $t_news) {
					$cache_tags[] = "newsid_" . $t_news['id'];
				}
			}
			$this->cache->set($list_news, $cache_key, $cache_tags);
		}
		return $list_news;
	}
}