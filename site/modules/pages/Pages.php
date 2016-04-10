<?php
/**
 * модуль работы с текстовыми страницами, каждая тсраница является элементом контента
 * @author riol
 *
 */
class Pages extends Module implements IElement {

	protected $module_name = "pages";

	private $module_settings = array(
			"dir_images" => "img/",
			"dir_files" => "",
			"image_sizes"=> array (
					"big"=> array(1400, 1000, false, true),// ширина, высота, crop, watermark
					"normal"=> array(600, 500, false, false),
					"small"=> array(156, 157, true, true, false)
			),
			"images_content_type" => "pages",
			"files_content_type" => "pages",
			"revisions_content_type" => "pages"

	);

	//глобальный массив доступа к основным свойствам страниц
	private $all_pages;

	//дерево страниц
	private $tree_pages;

	//инициализован ли глобальный массив страниц
	private $inited_pages = false;

        //массив с адресами страниц всех модулей
	private $full_links_array = false;
        
	/**
	 * добавляет новый элемент в базу
	 */
	public function add($page) {
		if($page['module']!='') {
			$this->router->write_records($page['module'], $page['full_link']);
		}

		//чистим кеш
		$this->cache->delete("tree_pages");
		$this->inited_pages = false;
		return $this->db->query("INSERT INTO ?_pages (?#) VALUES (?a)", array_keys($page), array_values($page));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $page) {
		/**
		 * при изменении имени файла перестраиваем пути у вложенных страниц
		 */
		if(isset($page['full_link'])) {
			$this->cache->delete("page_".$page["full_link"]);

			$old_page = $this->get_page_info($id);
			if($page['full_link']!=$old_page['full_link']) {
				$tree_pages = $this->get_tree_pages();
				$this->update_children_full_links($id, $tree_pages, $page['full_link']);
			}

			if(isset($page['module'])) {
				if($page['module']!='' and $page['module']!=$old_page['module']) {
					if($old_page['module']!='') $this->router->delete_records($old_page['module']);
					$this->router->write_records($page['module'], $page['full_link']);
				}
				elseif($page['module']=='' and $old_page['module']!='') {
					$this->router->delete_records($old_page['module']);
				}
				elseif($page['full_link']!=$old_page['full_link'] and $old_page['module']!='') {
					$this->router->write_records($old_page['module'], $page['full_link']);
				}
			}
			
		}

		//чистим кеш
		$this->cache->delete("tree_pages");
		if(is_array($id)) {
			$cache_tags = array();
			foreach($id as $one_id) {
				$cache_tags[] = "pageid_".$one_id;
			}
			$this->cache->clean($cache_tags);
		}
		else $this->cache->clean("pageid_".$id);
		$this->inited_pages = false;

		if($this->db->query("UPDATE ?_pages SET ?a WHERE id IN (?a)", $page, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete($id, $clear=true) {
		$page = $this->get_page_info($id);

		//удаляем изображения
		$content_photos = $this->get_images($id);
		foreach($content_photos as $photo) {
			$this->delete_image($photo['id']);
		}

		//удаляем файлы
		$content_files = $this->get_files($id);
		foreach($content_files as $file) {
			$this->delete_file($file['id']);
		}

		if($page['module']!='') {
			$this->router->delete_records($page['module']);
		}
		$this->db->query("DELETE FROM ?_pages WHERE id=?", $id);

		$this->cache->delete("page_".$page['full_link']);
		$this->cache->clean("pageid_".$id);

		$this->clear_revisions($id);

		$tree_pages = $this->get_tree_pages();
		//удаляем вложенные страницы
		if(isset($tree_pages["tree"][$id]) and is_array($tree_pages["tree"][$id])) {
			foreach($tree_pages["tree"][$id] as $page_id) {
				$this->delete($page_id, false);
				$this->clear_revisions($page_id);
			}
		}
		if($clear) {
			//чистим кеш
			$this->cache->delete("tree_pages");
			$this->inited_pages = false;
		}
	}

	/**
	 * создает копию элемента
	 */
	public function duplicate($id) {
		$new_id = null;
		if($page = $this->get_page($id)) {

			unset($page['id']);
			$page['title'] .= ' (копия)';
			$page['enabled'] = 0;

			if($page['parent']>0) {
				$parent_link = $this->get_page_full_link($page['parent'])."/";
			}
			else $parent_link = "";

			while(($c = $this->get_page($page['full_link'])))
			{
				if(preg_match('/-([0-9]+)$/', $page['full_link'], $parts)) {
					$page['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $page['url']);
				}
				else {
					$page['url'] .= "-2";
				}
				$page['full_link'] = $parent_link.$page['url'];
			}

			// Сдвигаем страницы вперед и вставляем копию на соседнюю позицию
			$this->db->query('UPDATE ?_pages SET sort=sort+1 WHERE sort>? AND parent=?', $page['sort'], $page['parent']);
			$page['sort']++;

			$new_id = (int)$this->add($page);

			// Дублируем изображения
			$images = $this->get_images($id);
			foreach($images as $image)
				$this->add_image_db($new_id, $image['picture'], $image['name'], $image['sort']);

			// Дублируем файлы
			$files = $this->get_files($id);
			foreach($files as $file)
				$this->add_file_db($new_id, $file['file'], $file['name'], $file['sort'], $file['size'], $file['type'], $file['date_add']);
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
		if($content = $this->get_page($for_id)) {
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
	 * возвращает страницу по id или url
	 * @param mixed $id
	 * @return array
	 */
	public function get_page($id) {
		if(is_int($id)) {
			$where_field = "id";
		}
		elseif(is_string($id)) {
			$where_field = "full_link";
			$id = trim($id, "/");
		}
		else return null;

		return $this->db->selectRow("SELECT * FROM ?_pages WHERE ".$where_field."=?", $id);
	}

	public function get_page_withcache($page_url) {
		$page_url = trim($page_url, "/");
		$cache_key_page = "page_".$page_url;
		if (false === ($page_t = $this->cache->get($cache_key_page))) {
			if($page_t = $this->get_page($page_url) and $page_t['enabled']) {
				$page_t['images'] = $this->get_images($page_t['id']);
				$page_t['files'] = $this->get_files($page_t['id']);
			}
			else return false;
			$this->cache->set($page_t, $cache_key_page, array("page"));
		}
		return $page_t;
	}

	/**
	 * возвращает страницы удовлетворяющие фильтрам
	 * @param array $filter
	 */
	public function get_pages($filter=array()) {

		return $this->db->select("SELECT p.id, p.title, p.full_link, p.sort, p.parent, p.enabled
				FROM ?_pages p");
	}

	/**
	 * возвращает порядок сортировки для добавляемой страницы
	 * @param int $parent
	 */
	public function get_new_page_sort($parent) {
		if($parent) return $this->db->selectCell("SELECT MAX(sort) as sort FROM ?_pages WHERE parent=?", $parent)+1;
		else return $this->db->selectCell("SELECT MAX(sort) as sort FROM ?_pages")+1;
	}

	/**
	 * возвращает полный адрес страницы
	 * @param int $id
	 */
	public function get_page_full_link($id) {
		if(!$this->inited_pages) $this->init_pages();
		if(isset($this->all_pages[$id]) and isset($this->all_pages[$id]['full_link']))
			return $this->all_pages[$id]['full_link'];
		else
			return false;
	}

	/**
	 * возвращает основные св-ва страницы
	 * @param int $id
	 */
	public function get_page_info($id) {
		if(!$this->inited_pages) $this->init_pages();
		if(isset($this->all_pages[$id]))
			return $this->all_pages[$id];
		else
			return false;
	}

	/**
	 * возвращает дерево всех страниц сайта
	 */
	public function get_tree_pages() {
		if(!$this->inited_pages) $this->init_pages();
		return array("all"=>$this->all_pages, "tree"=>$this->tree_pages);
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
	 * @param int $page_id
	 * @param string $image
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_image($page_id, $image, $name, $sort) {
		$image_sizes = $this->setting("image_sizes");
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."big/".$image, $image_sizes["big"])) return false;
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$image, $image_sizes["normal"])) return false;
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$image, $image_sizes["small"])) return false;
		$image_id = $this->add_image_db($page_id, $image, $name, $sort);
		if($sort==-1 and $image_id) {
			$this->db->query("UPDATE ?_attach_fotos SET sort=? WHERE id=?",$image_id, $image_id);
		}
		return $image_id;
	}

	/**
	 * добавляет запись об изображении в базу
	 * @param int $page_id
	 * @param string $image
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_image_db($page_id, $image, $name, $sort) {
		return $this->db->query("INSERT INTO ?_attach_fotos (for_id, picture, sort, name, content_type) VALUES (?, ?, ?, ?, ?)", $page_id, $image, $sort, $name, $this->setting("images_content_type"));
	}


	public function update_image($id, $image) {
		if($this->db->query("UPDATE ?_attach_fotos SET ?a WHERE id=?", $image, $id))
			return $id;
		else
			return false;
	}

	public function delete_image($id) {
		$picture = $this->db->selectCell("SELECT picture FROM ?_attach_fotos WHERE id=? AND content_type=?", $id, $this->setting("images_content_type"));
		if($picture) {
			//проверяем, не используется ли это изображение где-то еще
			$count = $this->db->selectCell("SELECT count(*) FROM ?_attach_fotos WHERE picture=?", $picture);
			if($count==1) {
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$picture);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."big/".$picture);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$picture);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$picture);
			}
		}
		return $this->db->query("DELETE FROM ?_attach_fotos WHERE id=? AND content_type=?", $id, $this->setting("images_content_type"));
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
				$result = $this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image_prev, ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$image, $image_sizes["small"]);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image_prev);
			}
		}
		else return $result;
	}

	public function get_images($id) {
		return $this->db->select("SELECT * FROM ?_attach_fotos WHERE for_id=? AND content_type=? ORDER BY sort ASC", intval($id), $this->setting("images_content_type"));
	}


	public function update_file($id, $file) {
		if($this->db->query("UPDATE ?_attach_files SET ?a WHERE id=?", $file, $id))
			return $id;
		else
			return false;
	}

	/**
	 * добавляет файл
	 * @param int $page_id
	 * @param string $file
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_file($page_id, $file, $name, $sort) {
		$size = $this->file->filesize($file, $this->setting("dir_files"));
		$type = pathinfo($file, PATHINFO_EXTENSION);
		$file_id = $this->add_file_db($page_id, $file, $name, $sort, $size, $type, time());
		if($sort==-1 and $file_id) {
			$this->db->query("UPDATE ?_attach_files SET sort=? WHERE id=?",$file_id, $file_id);
		}
		return $file_id;
	}

	/**
	 * добавляет запись о файле в базу
	 * @param int $page_id
	 * @param string $file
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_file_db($page_id, $file, $name, $sort, $size, $type, $date_add) {
		return $this->db->query("INSERT INTO ?_attach_files (for_id, file, sort, name, content_type, date_add, size, type) VALUES (?d, ?, ?d, ?, ?, ?d, ?d, ?)", $page_id, $file, $sort, $name, $this->setting("files_content_type"), $date_add, $size, $type);
	}

	public function delete_file($id) {
		$file = $this->db->selectCell("SELECT file FROM ?_attach_files WHERE id=? AND content_type=?", $id, $this->setting("files_content_type"));
		if($file) {
			//проверяем, не используется ли этот файл где-то еще
			$count = $this->db->selectCell("SELECT count(*) FROM ?_attach_files WHERE file=?", $file);
			if($count==1) {
				@unlink(ROOT_DIR_FILES.$this->setting("dir_files").$file);
			}
		}
		return $this->db->query("DELETE FROM ?_attach_files WHERE id=? AND content_type=?", $id, $this->setting("files_content_type"));
	}

	public function get_files($id) {
		return $this->db->select("SELECT * FROM ?_attach_files WHERE for_id=? AND content_type=? ORDER BY sort ASC", intval($id), $this->setting("files_content_type"));
	}

	private function update_children_full_links($parent_id, $tree_pages, $new_full_link) {
		if(isset($tree_pages["tree"][$parent_id]) and is_array($tree_pages["tree"][$parent_id])) {
			foreach($tree_pages["tree"][$parent_id] as $page_id) {
				$page = $this->get_page_info($page_id);
				$this->update($page_id, array("full_link"=>$new_full_link.'/'.$page['url']));
				if($page['module']!='') {
					$this->router->write_records($page['module'], $new_full_link.'/'.$page['url']);
				}
				$this->update_children_full_links($page_id, $tree_pages, $new_full_link.'/'.$page['url']);
			}
		}
	}

	/**
	 * кладет все страницы в глобальный массив
	 */
	private function init_pages() {
		$cache_key = "tree_pages";
		if (false === ($pages = $this->cache->get($cache_key))) {
			$db_pages = $this->db->select("SELECT id, url, full_link, title, parent, sort, enabled, nesting, topage, module, nomenu FROM ?_pages ORDER BY sort ASC");
			$all_pages = $tree_pages = array();
			foreach($db_pages as $page) {
				$all_pages[ $page['id'] ] = $page;
				$tree_pages[ $page['parent'] ][] = $page['id'];
			}
			$pages = array($all_pages, $tree_pages);
			$this->cache->set($pages, $cache_key);
		}

		$this->all_pages = $pages[0];
		$this->tree_pages = $pages[1];
		$this->inited_pages = true;
	}

	/**
	 * кладет все адреса модулей в глобальный массив
	 */
	private function init_full_links_array() {
		$cache_key = "full_links_array";
		if (false === ($full_links_array = $this->cache->get($cache_key))) {
			$full_links_array = $this->db->select("SELECT module AS ARRAY_KEY, id, full_link FROM ?_pages WHERE module!='' ORDER BY id ASC");
			$this->cache->set($full_links_array, $cache_key);
		}

		$this->full_links_array = $full_links_array;
	}
	
	/**
	 * возвращает url адрес страницы, к которой привязан модуль
	 * @param string $module
	 * @return string or false
	 */
	public function get_full_link_module($module) {
		if($this->full_links_array===false)
			$this->init_full_links_array();
		
		if(is_array($this->full_links_array) and isset($this->full_links_array[$module])) {
			return $this->full_links_array[$module]['full_link'];
		}
		else return false;

	}

	/**
	 * возвращает ссылки в виде массива для sitemap
	 */
	public function get_sitemap_links() {
		$links = array();
		$this->get_tree_pages();
		foreach($this->all_pages as $page) {
			if($page['enabled'] and $page['nomenu']==0) $links[] = SITE_URL.$page['full_link']."/";
		}

		return $links;
	}


	function get_list_menus($tree_menus, $tree_pages, $type, $parent=0) {
		$t_aux_page = "";
		if(isset($tree_menus["tree"][$type][$parent]) and is_array($tree_menus["tree"][$type][$parent])) {

			foreach($tree_menus["tree"][$type][$parent] as $page_id) {
				if($tree_menus["all"][$page_id]['enabled']) {
					if($tree_menus["all"][$page_id]['page_id'] and isset($tree_pages["all"][ $tree_menus["all"][$page_id]['page_id'] ]) and $tree_pages["all"][ $tree_menus["all"][$page_id]['page_id'] ]['enabled']) {
						$tree_menus["all"][$page_id]['url'] = SITE_URL.$tree_pages["all"][ $tree_menus["all"][$page_id]['page_id'] ]['full_link']."/";
					}
					$t_aux_page .= '<li><a href="'.$tree_menus["all"][$page_id]['url'].'" '.($tree_menus["all"][$page_id]['title2'] ? 'title="'.$tree_menus["all"][$page_id]['title2'].'"' : '').'>'.$tree_menus["all"][$page_id]['title'].'</a></li>'."\n";
				}
			}
		}
		return $t_aux_page;
	}
	
	/**
	 * Reads russian names of introduced templates
	 * Any created template must contain single row php comment with string tplName: "NameOfTpl"
	 * @author Tim
	 */
	 public function GetRussianNamesOfTpl(){
		$result = array();
		$files = glob(TPL_DIRL."page_*".TPL_EXTD);
		if($files)
			foreach($files as $val)
				if(is_file($val)){
					$tplName = basename($val);
					$tplName = preg_replace('/^page_|'.preg_quote(TPL_EXTD).'$/i', '', $tplName);
					$fp = fopen($val, "r");
					if(!$fp)
						continue;
					while($line = fgets($fp)){
						if(($pos = strpos($line, "//")) !== false){
							if(preg_match('{^//\s*?tplName\s*?:\s*?"(.+?)"}is', $line, $pockets, null, $pos))
							{	
								$result[] = array("real" => $tplName, "found" => $pockets[1]);
								break;
							}
						}
					}
					fclose($fp);
				}
		return $result;
	 }
	 
}