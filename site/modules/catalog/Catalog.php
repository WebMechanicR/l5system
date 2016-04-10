<?php
/**
 * модуль работы с каталогом
 * @author riol
 *
 */
class Catalog extends Module {

	protected $module_name = "catalog";
	private $module_table_categories = "categories";
	public $module_table_products = "products";
	private $module_table_deliveries = "deliveries";
	private $module_table_payment_types = "payment_types";
	private $module_table_related_products = "related_products";

	private $module_nesting = false; //возможность владывать подстраницы в модуль

	private $module_settings = array(
			"dir_images" => "products/",
			"dir_files" => "products/",
			"image_sizes"=> array (
					"super"=> array(1400, 3000, false, true),// ширина, высота, crop, watermark
					"big"=> array(380, 380, false, true),// ширина, высота, crop, watermark
					"normal"=> array(156, 156, false, false),
					"small"=> array(73, 73, true, false)
			),
			"images_content_type" => "products",
			"files_content_type" => "products",
			"revisions_content_type" => "products"
	);

	//глобальный массив доступа к основным свойствам категорий
	private $all_categories;

	//дерево страниц
	private $tree_categories;

	//инициализован ли глобальный массив категорий
	private $inited_categories = false;

	/**
	 * добавляет новую категорию в базу
	 */
	public function add_category($category) {
		//чистим кеш
		$this->cache->delete("tree_categories");
		$this->inited_categories = false;
		return $this->db->query("INSERT INTO ?_".$this->module_table_categories." (?#) VALUES (?a)", array_keys($category), array_values($category));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update_category($id, $category) {
		/**
		 * при изменении имени файла перестраиваем пути у вложенных категорий
		 */
		if(isset($category['full_link'])) {
			$this->cache->delete("category_".$category["full_link"]);

			$old_category = $this->get_category_info($id);
			if($category['full_link']!=$old_category['full_link']) {
				$tree_categories = $this->get_tree_categories();
				$this->update_children_full_links($id, $tree_categories, $category['full_link']);
				$this->cache->clean("products_categoryid_".$id);
			}
		}

		//чистим кеш
		$this->cache->delete("tree_categories");
		if(is_array($id)) {
			$cache_tags = array();
			foreach($id as $one_id) {
				$cache_tags[] = "categoryid_".$one_id;
				if(isset($category['enabled'])) {
					$old_category = $this->get_category_info($one_id);
					if($category['enabled']!=$old_category['enabled']) $cache_tags[] = "products_categoryid_".$one_id;
				}
			}
			$this->cache->clean($cache_tags);
		}
		else $this->cache->clean("categoryid_".$id);
		$this->cache->delete("tree_categories");
		$this->inited_categories = false;

		if($this->db->query("UPDATE ?_".$this->module_table_categories." SET ?a WHERE id IN (?a)", $category, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete_category($id, $clear=true) {
		$category = $this->get_category_info($id);

		$this->db->query("DELETE FROM ?_".$this->module_table_categories." WHERE id=?", $id);
		$this->db->query("UPDATE ?_".$this->module_table_products." SET categ=0 WHERE categ=?", $id);

		$this->cache->delete("category_".$category['full_link']);
		$this->cache->clean(array("categoryid_".$id, "products_categoryid_".$id));

		$tree_categories = $this->get_tree_categories();
		//удаляем вложенные категории
		if(isset($tree_categories["tree"][$id]) and is_array($tree_categories["tree"][$id])) {
			foreach($tree_categories["tree"][$id] as $category_id) {
				$this->delete_category($category_id, false);
			}
		}
		if($clear) {
			//чистим кеш
			$this->cache->delete("tree_categories");
			$this->inited_categories = false;
		}
	}

	/**
	 * создает копию элемента
	 */
	public function duplicate_category($id) {
		$new_id = null;
		if($category = $this->get_category($id)) {

			unset($category['id']);
			$category['title'] .= ' (копия)';
			$category['enabled'] = 0;

			if($category['parent']>0) {
				$parent_link = $this->get_category_full_link($category['parent'])."/";
			}
			else $parent_link = "";

			while(($c = $this->get_category($category['full_link'])))
			{
				if(preg_match('/-([0-9]+)$/', $category['full_link'], $parts)) {
					$category['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $category['url']);
				}
				else {
					$category['url'] .= "-2";
				}
				$category['full_link'] = $parent_link.$category['url'];
			}

			// Сдвигаем категории вперед и вставляем копию на соседнюю позицию
			$this->db->query("UPDATE ?_".$this->module_table_categories." SET sort=sort+1 WHERE sort>? AND parent=?", $category['sort'], $category['parent']);
			$category['sort']++;

			$new_id = (int)$this->add_category($category);
		}
		return $new_id;
	}


	/**
	 * возвращает категорию по id или url
	 * @param mixed $id
	 * @return array
	 */
	public function get_category($id) {
		if(is_int($id)) {
			$where_field = "id";
		}
		elseif(is_string($id)) {
			$where_field = "full_link";
			$id = trim($id, "/");
		}
		else return null;

		return $this->db->selectRow("SELECT * FROM ?_".$this->module_table_categories." WHERE ".$where_field."=?", $id);
	}

	/**
	 * возвращает категории удовлетворяющие фильтрам
	 * @param array $filter
	 */
	public function get_categories($filter=array()) {

		return $this->db->select("SELECT p.id, p.title, p.full_link, p.sort, p.parent, p.enabled
				FROM ?_".$this->module_table_categories." p");
	}

	/**
	 * возвращает порядок сортировки для добавляемой категории
	 * @param int $parent
	 */
	public function get_new_category_sort($parent) {
		if($parent) return $this->db->selectCell("SELECT MAX(sort) as sort FROM ?_".$this->module_table_categories." WHERE parent=?", $parent)+1;
		else return $this->db->selectCell("SELECT MAX(sort) as sort FROM ?_".$this->module_table_categories."")+1;
	}

	/**
	 * возвращает полный адрес категории
	 * @param int $id
	 */
	public function get_category_full_link($id) {
		if(!$this->inited_categories) $this->init_categories();
		if(isset($this->all_categories[$id]) and isset($this->all_categories[$id]['full_link']))
			return $this->all_categories[$id]['full_link'];
		else
			return false;
	}

	/**
	 * возвращает основные св-ва категории
	 * @param int $id
	 */

	/**
	 * возвращает массив доставок
	 */
	public function get_list_deliveries() {
		$cache_key = "types_deliveries";
		if (false === ($deliveries = $this->cache->get($cache_key))) {
			$deliveries = $this->db->select("SELECT g.id AS ARRAY_KEY, g.* FROM ?_".$this->module_table_deliveries." g ORDER BY g.sort ASC");
			$this->cache->set($deliveries, $cache_key);
		}
		return $deliveries;
	}

	/**
	 * добавляет новый тип доставки в базу
	 */
	public function add_delivery($delivery) {
		//чистим кеш
		$this->cache->delete("types_deliveries");
		return $this->db->query("INSERT INTO ?_".$this->module_table_deliveries." (?#) VALUES (?a)", array_keys($delivery), array_values($delivery));
	}

	/**
	 * удаляет тип доставки из базы
	 */
	public function delete_delivery($id) {
		//чистим кеш
		$this->cache->delete("types_deliveries");
		return $this->db->query("DELETE FROM ?_".$this->module_table_deliveries." WHERE id=?", $id);
	}

	/**
	 * обновляет тип доставки в базе
	 */
	public function update_delivery($id, $delivery) {
		//чистим кеш
		$this->cache->delete("types_deliveries");
		if($this->db->query("UPDATE ?_".$this->module_table_deliveries." SET ?a WHERE id=?", $delivery, $id))
			return $id;
		else
			return false;
	}

	/**
	 * возвращает массив типов оплаты
	 */
	public function get_list_payment_types() {
		$cache_key = "payment_types";
		if (false === ($payment_types = $this->cache->get($cache_key))) {
			$payment_types = $this->db->select("SELECT g.id AS ARRAY_KEY, g.* FROM ?_".$this->module_table_payment_types." g ORDER BY g.sort ASC");
			$this->cache->set($payment_types, $cache_key);
		}
		return $payment_types;
	}

	/**
	 * добавляет новый тип оплаты в базу
	 */
	public function add_payment_type($payment_type) {
		//чистим кеш
		$this->cache->delete("payment_types");
		return $this->db->query("INSERT INTO ?_".$this->module_table_payment_types." (?#) VALUES (?a)", array_keys($payment_type), array_values($payment_type));
	}

	/**
	 * удаляет тип оплаты из базы
	 */
	public function delete_payment_type($id) {
		//чистим кеш
		$this->cache->delete("payment_types");
		return $this->db->query("DELETE FROM ?_".$this->module_table_payment_types." WHERE id=?", $id);
	}

	/**
	 * обновляет тип оплаты в базе
	 */
	public function update_payment_type($id, $payment_type) {
		//чистим кеш
		$this->cache->delete("payment_types");
		if($this->db->query("UPDATE ?_".$this->module_table_payment_types." SET ?a WHERE id=?", $payment_type, $id))
			return $id;
		else
			return false;
	}



	public function get_minimal_prices(){
		$this->init_categories();
		$result = array();
		 
		if(isset($this->tree_categories[0]) and (is_array($ids = $this->tree_categories[0]))){
			$tpl = "SELECT MIN(price) AS price FROM ?_".$this->module_table_products." WHERE categ IN(?a) AND price>0";
			foreach($this->tree_categories[0] as $item){
				$categs = $this->get_sub_categs($item);
				$categs[] = $item;
				$result[$item] = $this->db->selectCell($tpl, $categs);
			}
		}

		return $result;
	}

	public function get_category_info($id) {
		if(!$this->inited_categories) $this->init_categories();
		if(isset($this->all_categories[$id]))
			return $this->all_categories[$id];
		else
			return false;
	}

	/**
	 * возвращает дерево всех категорий сайта
	 */
	public function get_tree_categories() {
		if(!$this->inited_categories) $this->init_categories();
		return array("all"=>$this->all_categories, "tree"=>$this->tree_categories);
	}


	/**
	 * возвращает настройку модуля
	 * @param string $id
	 * @return Ambigous <NULL, multitype:string >
	 */
	public function setting($id) {
		return (isset($this->module_settings[$id]) ? $this->module_settings[$id] : null);
	}


	private function update_children_full_links($parent_id, $tree_categories, $new_full_link) {
		if(isset($tree_categories["tree"][$parent_id]) and is_array($tree_categories["tree"][$parent_id])) {
			foreach($tree_categories["tree"][$parent_id] as $category_id) {
				$category = $this->get_category_info($category_id);
				$this->update_category($category_id, array("full_link"=>$new_full_link.'/'.$category['url']));
				$this->update_children_full_links($category_id, $tree_categories, $new_full_link.'/'.$category['url']);
			}
		}
	}

	/**
	 * кладет все категории в глобальный массив
	 */
	private function init_categories() {
		if($this->inited_categories) return;
		$cache_key = "tree_categories";
		if (false === ($categories = $this->cache->get($cache_key))) {
			$db_categories = $this->db->select("SELECT id, url, full_link, title, title_full, img, parent, sort, enabled, count FROM ?_".$this->module_table_categories." ORDER BY sort ASC");
			$all_categories = $tree_categories = array();
			foreach($db_categories as $category) {
				$all_categories[ $category['id'] ] = $category;
				$tree_categories[ $category['parent'] ][] = $category['id'];
			}
			$categories = array($all_categories, $tree_categories);
			$this->cache->set($categories, $cache_key);
		}

		$this->all_categories = $categories[0];
		$this->tree_categories = $categories[1];
		$this->inited_categories = true;
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
				array('{url_page}(\/?)', 'module=catalog&page_url={url_page}'),
				array('{url_page}/order.htm', 'module=orders&action=index&page_url={url_page}'),
				array('{url_page}/add_cart.htm', 'module=cart&action=add_cart&page_url={url_page}'),
				array('{url_page}/del_cart_([0-9]+).htm', 'module=cart&action=del_cart&page_url={url_page}&id=$1'),
				array('{url_page}/update_cart_([0-9]+).htm', 'module=cart&action=update_cart&page_url={url_page}&id=$1'),
				array('{url_page}/([-a-zA-Z0-9_\./]+)/index_([0-9]+).htm', 'module=catalog&action=show_category&page_url={url_page}&url=$1&p=$2'),
				array('{url_page}/([-a-zA-Z0-9_\./]+)/([-a-zA-Z0-9_\.]+)_print.htm', 'module=catalog&action=show_product&page_url={url_page}&url_category=$1&url=$2&print=1'),
				array('{url_page}/([-a-zA-Z0-9_\./]+)/([-a-zA-Z0-9_\.]+).htm', 'module=catalog&action=show_product&page_url={url_page}&url_category=$1&url=$2'),
				array('{url_page}/([-a-zA-Z0-9_\./]+)(\/?)', 'module=catalog&action=show_category&page_url={url_page}&url=$1')
		);
	}

	/**
	 * возвращает массив с вложенными категориями
	 * @param unknown_type $parent
	 * @return string
	 */
	public function get_sub_categs($parent=0, $ar_subs=array()) {
		if(isset($this->tree_categories[$parent]) and is_array($this->tree_categories[$parent])) {
			foreach($this->tree_categories[$parent] as $category_id) {
				if($this->all_categories[$category_id]['enabled']) {
					$ar_subs[] = $category_id;
					$ar_subs = $this->get_sub_categs($category_id, $ar_subs);
				}
			}
		}
		return $ar_subs;
	}

	public function add_view_category($id) {
		$this->db->query("UPDATE ?_".$this->module_table_categories." SET viewed=viewed+1 WHERE id=?d", $id);
	}


	/* PRODUCTS */
	/**
	 * добавляет новый элемент в базу
	 */
	public function add_product($product) {
		//чистим кеш
		if($product['enabled']==1) {
			$this->cache->clean(array("search_products", "list_products"));
		}
		$new_id = $this->db->query("INSERT INTO ?_".$this->module_table_products." (?#) VALUES (?a)", array_keys($product), array_values($product));
		if($new_id) $this->db->query('UPDATE ?_'.$this->module_table_products.' SET sort=id WHERE id=?d', $new_id);
		return $new_id;
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update_product($id, $product) {

		if(isset($product['url'])) {
			$this->cache->delete("product_".$product["url"]);
		}

		$cache_tags = array();
		//чистим кеш
		if(is_array($id)) {
			foreach($id as $one_id) {
				$cache_tags[] = "productid_".$one_id;
				$old_product = $this->get_product($one_id);
				if(isset($product['enabled'])) {
					//$cache_tags[] = "list_products";
					if($product['enabled'] and $product['enabled']!=$old_product['enabled']) {
						$this->upcount_product_categories($one_id, array(), false, false);
					}
					elseif($product['enabled']!=$old_product['enabled']) {
						$this->downcount_product_categories($one_id, array(), false);
					}
				}
			}
			if(isset($product['enabled'])) {
				//$cache_tags[] = "list_products";
				//чистим кеш категорий, т.к. поменялось кол-во товаров в них
				$this->cache->delete("tree_categories");
				$this->inited_categories = false;
				$this->cache->clean("search_products");
			}
		}
		else {
			$cache_tags[] = "productid_".$id;
			$old_product = $this->get_product($id);
			if(isset($product['enabled']) and ($product['enabled']!=$old_product['enabled'])) {
				//$cache_tags[] = "list_products";
				if($product['enabled'] ) {
					$this->upcount_product_categories($id);
				}
				else {
					$this->downcount_product_categories($id);
				}
				if($product['enabled']!=$old_product['enabled'])
					$this->cache->clean("search_products");
			}
		}

		$this->cache->clean($cache_tags);

		if($this->db->query("UPDATE ?_".$this->module_table_products." SET ?a WHERE id IN (?a)", $product, (array)$id) !== false) {
			return $id;
		}
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete_product($id) {
		if($product = $this->get_product($id)) {

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

			if($product['enabled']) {
				$this->downcount_product_categories($id);
			}

			$this->db->query("DELETE FROM ?_".$this->module_table_products." WHERE id=?d", $id);
			$this->db->query("DELETE FROM ?_".$this->module_table_related_products." WHERE product_id=?d OR product_id2=?d", $id, $id);
			$this->cache->delete("product_".$product['url']);
			$this->cache->clean(array("productid_".$id, "list_products"));


			$this->clear_revisions($id);
		}
	}

	/**
	 * создает копию элемента
	 */
	public function duplicate_product($id) {
		$new_id = null;
		if($product = $this->get_product($id)) {

			unset($product['id']);
			$product['name'] .= ' (копия)';
			$product['enabled'] = 0;

			while(($c = $this->get_product($product['url'])))
			{
				if(preg_match('/-([0-9]+)$/', $product['url'], $parts)) {
					$product['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $product['url']);
				}
				else {
					$product['url'] .= "-2";
				}
			}

			// Сдвигаем товары вперед и вставляем копию на соседнюю позицию
			$this->db->query('UPDATE ?_'.$this->module_table_products.' SET sort=sort+1 WHERE sort>?', $product['sort']);
			$product['sort']++;
			$new_id = (int)$this->add_product($product);

			// Дублируем изображения
			$images = $this->get_images($id);
			foreach($images as $image)
				$this->add_image_db($new_id, $image['picture'], $image['name'], $image['sort']);

			//Дублируем связанные товары
			$related_products = $this->db->select("SELECT * FROM ?_".$this->module_table_related_products." r_p WHERE r_p.product_id=?d", $id);
			foreach($related_products as $related_product) {
				$related_product['product_id'] = $new_id;
				$this->add_related_product($related_product);
			}

			// Дублируем файлы
			$files = $this->get_files($id);
			foreach($files as $file)
				$this->add_file_db($new_id, $file['file'], $file['name'], $file['sort'], $file['size'], $file['type'], $file['date_add']);

		}
		return $new_id;
	}



	/**
	 * возвращает товар по id или url
	 * @param mixed $id
	 * @return array
	 */
	public function get_product($id) {
		if(is_int($id)) {
			$where_field = "id";
		}
		elseif(is_string($id)) {
			$where_field = "url";
		}
		else return null;

		return $this->db->selectRow("SELECT pr.* FROM ?_".$this->module_table_products." pr
				WHERE pr.".$where_field."=?", $id);
	}

	/**
	 * возвращает краткую информацию о товаре по id
	 * @param mixed $id
	 * @return array
	 */
	public function get_product_info($id) {
		if(is_int($id)) {
			$where_field = "id";
		}
		elseif(is_string($id)) {
			$where_field = "url";
		}
		else return null;
		return $this->db->selectRow("SELECT pr.*  FROM ?_".$this->module_table_products." pr WHERE pr.".$where_field."=?", $id);
	}

	/**
	 * возвращает товары удовлетворяющие фильтрам
	 * @param array $filter
	 */
	public function get_list_products($filter=array()) {
		$sort_by = " ORDER BY pr.sort DESC";
		$limit = "";
		$where = "";
		$group_by = "";
		$join = "";
		$array_key = "";



		if(isset($filter['sort']) and count($filter['sort'])==2) {
			if($filter['sort'][0]=='find_in_set' and isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {
				if(isset($filter['category_id']) and $filter['category_id']) {
					$sort_by = " ORDER BY FIND_IN_SET(pr.id, '".implode(",", $filter['in_ids'])."')";
				}
				else {
					$new_in_ids = array();
					//выбираем id из списка только те, которые попадают на страницу, чтобы не сортировать при запросе лишнее
					for($i=($filter['limit'][0]-1)*$filter['limit'][1]; $i<(($filter['limit'][0]-1)*$filter['limit'][1]+$filter['limit'][1]); $i++) {
						if(!isset($filter['in_ids'][$i])) break;
						$new_in_ids[] = $filter['in_ids'][$i];
					}
					$filter['in_ids'] = $new_in_ids;
					$sort_by = " ORDER BY FIND_IN_SET(pr.id, '".implode(",", $new_in_ids)."')";
					$filter['limit'] = array(1, $filter['limit'][1]);
				}
			}
			else {
				if(!in_array($filter['sort'][0], array("sort", "name", "name_full", "articul", "price", "price_date", "enabled", "viewed"))) $filter['sort'][0] = "sort";
				if(!in_array($filter['sort'][1], array("asc", "desc")) ) $filter['sort'][1] = "asc";
				$sort_by = " ORDER BY pr.".$filter['sort'][0]." ".$filter['sort'][1];
			}
		}

		if(isset($filter['recomenduem_price'])) {
			$sort_by = " ORDER BY ABS(".intval($filter['recomenduem_price'])."-pr.price) asc";
		}

		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}

		if(isset($filter['enabled'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.enabled=".intval($filter['enabled']);
		}

		if(isset($filter['not_id']) and $filter['not_id']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.id!=".intval($filter['not_id']);
		}

		if(isset($filter['short_query']) and $filter['short_query']!="") {
			$where .= (empty($where) ? " WHERE " : " AND ").'pr.name LIKE "%'.$filter['short_query'].'%"';
		}

		if(isset($filter['with_img'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.img!=''";
		}

		if(isset($filter['category_id']) and $filter['category_id']) {
			if(!is_array($filter['category_id'])) $filter['category_id'] = (array)$filter['category_id'];
			$filter['category_id'] = array_map("intval", $filter['category_id']);
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.categ IN (".implode(",", $filter['category_id']).")";
		}

		if(isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.id IN (".implode(",", $filter['in_ids']).")";
		}

		if(isset($filter['ARRAY_KEY']) and $filter['ARRAY_KEY']) {
			$array_key = " ".$filter['ARRAY_KEY']." AS ARRAY_KEY, ";
		}


		if(isset($filter['price_from']) and $filter['price_from']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.price>=".intval($filter['price_from']);
		}

		if(isset($filter['price_to']) and $filter['price_to']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.price<=".intval($filter['price_to']);
		}

		if(isset($filter['name']) and $filter['name']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.name LIKE '%".$filter['name']."%'";
		}

		if(isset($filter['name_full']) and $filter['name_full']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.name_full LIKE '%".$filter['name_full']."%'";
		}

		if(isset($filter['articul']) and $filter['articul']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.articul LIKE '%".$filter['articul']."%'";
		}

		if(isset($filter['show_in_block1'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.show_in_block1=".intval($filter['show_in_block1']);
		}

		if(isset($filter['show_in_block2'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.show_in_block2=".intval($filter['show_in_block2']);
		}

		return $this->db->select("SELECT ".$array_key." pr.id, pr.name, pr.articul, pr.novelty, pr.special,pr.is_hit, pr.last_price, pr.url, pr.enabled, pr.brief_description, pr.img, pr.categ, pr.price, pr.sort
				FROM ?_".$this->module_table_products." pr"
				.$join
				.$where
				.$group_by
				.$sort_by
				.$limit
		);
	}

	/**
	 * возвращает количество товаров удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_count_products($filter=array()) {
		$where = "";
		$group_by = "";
		$join = "";

		if(isset($filter['enabled'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.enabled=".intval($filter['enabled']);
		}

		if(isset($filter['not_id']) and $filter['not_id']) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.id!=".intval($filter['not_id']);
		}

		if(isset($filter['short_query']) and $filter['short_query']!="") {
			$where .= (empty($where) ? " WHERE " : " AND ").'pr.name LIKE "%'.$filter['short_query'].'%"';
		}


		if(isset($filter['with_img'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.img!=''";
		}

		if(isset($filter['category_id']) and $filter['category_id']) {
			if(!is_array($filter['category_id'])) $filter['category_id'] = (array)$filter['category_id'];
			$filter['category_id'] = array_map("intval", $filter['category_id']);
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.categ IN (".implode(",", $filter['category_id']).")";
		}

		if(isset($filter['in_ids']) and is_array($filter['in_ids']) and count($filter['in_ids'])>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.id IN (".implode(",", $filter['in_ids']).")";
		}

		if(isset($filter['price_from']) and $filter['price_from']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.price>=".intval($filter['price_from']);
		}

		if(isset($filter['price_to']) and $filter['price_to']>0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.price<=".intval($filter['price_to']);
		}

		if(isset($filter['name']) and $filter['name']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.name LIKE '%".$filter['name']."%'";
		}

		if(isset($filter['name_full']) and $filter['name_full']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.name_full LIKE '%".$filter['name_full']."%'";
		}

		if(isset($filter['articul']) and $filter['articul']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.articul LIKE '%".$filter['articul']."%'";
		}

		if(isset($filter['show_in_block1'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.show_in_block1=".intval($filter['show_in_block1']);
		}

		if(isset($filter['show_in_block2'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."pr.show_in_block2=".intval($filter['show_in_block2']);
		}

		return $this->db->selectCell("SELECT count(distinct pr.id) FROM ?_".$this->module_table_products." pr"
				.$join
				.$where);
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
		if($content = $this->get_product($for_id)) {
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
	 * добавляет изображение
	 * @param int $page_id
	 * @param string $image
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_image($page_id, $image, $name, $sort) {
		$image_sizes = $this->setting("image_sizes");
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."super/".$image, $image_sizes["super"])) return false;
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
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."super/".$picture);
			}
		}
		return $this->db->query("DELETE FROM ?_attach_fotos WHERE id=? AND content_type=?", $id, $this->setting("images_content_type"));
	}

	public function delete_category_image($id){
		$picture = $this->db->selectCell("SELECT img FROM ?_".$this->module_table_categories." WHERE id =?", $id);
		if($picture){
			@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$picture);
			@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$picture);
			@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$picture);
			$this->db->query("UPDATE ?_".$this->module_table_categories." SET img = '' WHERE id = ?", $id);
		}
		return 1;
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
				$result = $this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image_prev, ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$image, $image_sizes["normal"]);
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


	/**
	 * повышает счетчик товаров у категорий
	 * если задан только товар - извлекаем все его категории
	 * @param int $product_id
	 * @param array $ar_new_categs
	 */
	public function upcount_product_categories($product_id=0, $ar_new_categs=array(), $down=false, $cache_clear=true) {
		if($product_id and count($ar_new_categs)==0) {
			if($product_info = $this->get_product($product_id)) {
				$ar_new_categs = array($product_info['categ']);
			}
		}
		if(count($ar_new_categs)>0) {
			if($down) $this->db->query("UPDATE ?_".$this->module_table_categories." SET count=count-1 WHERE id IN (?a)", (array)$ar_new_categs);
			else $this->db->query("UPDATE ?_".$this->module_table_categories." SET count=count+1 WHERE id IN (?a)", (array)$ar_new_categs);

			$cache_tags = array();
			foreach($ar_new_categs as $categ) {
				$cache_tags[] = "products_categoryid_".$categ;
			}
			$this->cache->clean($cache_tags);
		}
	}


	/**
	 * понижает счетчик товаров у категорий
	 * если задан только товар - извлекаем все его категории
	 * @param int $product_id
	 * @param array $ar_new_categs
	 */
	public function downcount_product_categories($product_id=0, $ar_new_categs=array(), $cache_clear=true) {
		$this->upcount_product_categories($product_id, $ar_new_categs, true, $cache_clear);
	}


	/**
	 * обновляет счетчики товаров у категорий
	 */
	public function update_catalog_count() {
		$count_categs = $this->db->select("SELECT p.categ, count(p.id) as count FROM ?_".$this->module_table_products." p
				WHERE p.enabled=1
				GROUP BY p.categ");
		$this->db->query("UPDATE ?_".$this->module_table_categories." SET count=0");
		foreach($count_categs as $categ) {
			$this->db->query("UPDATE ?_".$this->module_table_categories." SET count=?d WHERE id=?d", $categ['count'], $categ['categ']);
		}
		//чистим кеш
		$this->cache->delete("tree_categories");
		$this->inited_categories = false;
	}

	public function add_view_product($id) {
		$this->db->query("UPDATE ?_".$this->module_table_products." SET viewed=viewed+1 WHERE id=?d", $id);
	}


	public function get_root_parent_category($category_id) {
		if(!$this->inited_categories) $this->init_categories();
		if($this->all_categories[$category_id]['parent']==0) return $category_id;
		return $this->get_root_parent_category($this->all_categories[$category_id]['parent']);
	}

	/**
	 * возвращает массив со связанными товарами
	 * @param int $id
	 * @param int $type - тип связанного товара, 1 - аналог, 2 - допкомплектация, 3 - замена
	 */
	public function get_related_products($id, $type=0, $filter = array()) {
		$where = "";
		if(isset($filter['enabled'])) {
			$where .= " AND pr.enabled=".intval($filter['enabled']);
		}

		if(isset($filter['no_modif'])) {
			$where .= " AND pr.product_parent=0";
		}


		return $this->db->select("SELECT r_p.type as type_related, r_p.sort as sort_related, pr.* FROM ?_".$this->module_table_related_products." r_p
				LEFT JOIN  ?_".$this->module_table_products." pr ON (r_p.product_id2=pr.id)
				WHERE r_p.product_id=?d
				{ AND r_p.type=?d } ".$where.
				" ORDER BY r_p.sort ASC", $id, ($type ? $type : DBSIMPLE_SKIP));
	}

	/**
	 * добавляет новый связанный товар в базу
	 */
	public function add_related_product($related_product) {
		return $this->db->query("INSERT IGNORE INTO ?_".$this->module_table_related_products." (?#) VALUES (?a)", array_keys($related_product), array_values($related_product));
	}

	/**
	 * удаляет связанный товар из базы
	 */
	public function delete_related_product($product_id, $product_id2) {
		return $this->db->query("DELETE FROM ?_".$this->module_table_related_products." WHERE product_id=?d AND product_id2=?d", $product_id, $product_id2);
	}

	/**
	 * удаляет все связанные товары из базы
	 */
	public function delete_related_product_all($product_id, $type=0) {
		return $this->db->query("DELETE FROM ?_".$this->module_table_related_products." WHERE product_id=?d { AND type=?d }", $product_id, ($type ? $type : DBSIMPLE_SKIP));
	}

	/* END PRODUCTS */


	/**
	 * создает файл для экспорта в Яндекс.Маркет и сохраняет его в папку, указанную в настройках
	 */
	public function create_yml() {
		$workingInterval = 86400;
		if((time() - $this->settings->for_yandex_yml_working_interval) < $workingInterval)
			return;

		$yml = '<?xml version="1.0" encoding="UTF-8"?>
				<!DOCTYPE yml_catalog SYSTEM "shops.dtd">
				<yml_catalog date="'.date('Y-m-d H:i').'">
						<shop>
						<name>'.$this->settings->site_title.'</name>
								<company>'.$this->settings->company_name.'</company>
										<url>'.SITE_URL.'</url>
												<currencies>
												<currency id="RUR" rate="1"/>
												</currencies>
												<categories>
												';

		$fp = fopen(YML_FILE,"w");

		$this->get_tree_categories();
		foreach($this->all_categories as $cat_id=>$category) {
			$yml .= '<category id="'.$cat_id.'" parentId="'.$category['parent'].'">'.str_replace("&#39","&apos;",$category['title']).'</category>
					';
		}

		$yml .= '</categories>
				<offers>
				';

		fwrite($fp,$yml);
		unset($yml);

		$this->db->query("SET SQL_BIG_SELECTS=1");
		$products = $this->db->select("SELECT pr.id, pr.name, pr.name_full, pr.url, pr.brief_description, pr.img, pr.categ, pr.price,
				pr.last_price
				FROM ?_".$this->module_table_products." pr
				WHERE pr.enabled=1 AND pr.price>0 AND pr.categ>0");

		$catalog_full_link = $this->pages->get_full_link_module("catalog");
		$content_photos_dir = SITE_URL.URL_IMAGES.$this->setting("dir_images");

		foreach($products as $product) {
			if(isset($this->all_categories[$product['categ']])) {
				$available = "true";
				$type = '';
				if($type=='' and $product['name_full']!='') $product['name'] .= ' &#151; '.$product['name_full'];

				$yml_p = '<offer id="'.$product['id'].'" '.$type.' available="'.$available.'">
						<url>'.SITE_URL.$catalog_full_link.'/'.$this->all_categories[$product['categ']]['full_link'].'/'.$product['url'].'.htm</url>
								<price>'.$product['price'].'</price>
										<currencyId>RUR</currencyId>
										<categoryId>'.$product['categ'].'</categoryId>';
				$yaml = "";
				if($product['img']!='') $yaml .= '<picture>'.$content_photos_dir.'normal/'.$product['img'].'</picture>';
				$yml_p .= '<delivery>false</delivery>';
				if($type) {
					$yml_p .= '<model>'.str_replace("&#39","&apos;",$product['name']).'</model>

							<description>'.($product['name_full']!='' ? F::ucfirst($product['name_full']).'. ' : '').htmlspecialchars(strip_tags($product['brief_description'])).'</description>';
				}
				else {
					$yml_p .= '<name>'.str_replace("&#39","&apos;",$product['name']).'</name>

							<description>'.str_replace("&#039","&apos;",htmlspecialchars(strip_tags($product['brief_description']), ENT_QUOTES)).'</description>';
				}
				$yml_p .= '</offer>
						';
				fwrite($fp,$yml_p);
			}
		}
		unset($products);
		$yaml = '</offers>
				</shop></yml_catalog>';
		fwrite($fp,$yaml);
		fclose($fp);
		$this->settings->update_settings(array("for_yandex_yml_working_interval" => time()));
	}

	/**
	 * возвращает ссылки в виде массива для sitemap
	 */
	public function get_sitemap_links() {
		$links = array();
		$catalog_full_link = SITE_URL.$this->pages->get_full_link_module("catalog");
		$this->get_tree_categories();
		foreach($this->all_categories as $cat_id=>$category) {
			if($category['enabled']) $links[] = $catalog_full_link."/".$category['full_link']."/";
		}

		$this->db->query("SET SQL_BIG_SELECTS=1");
		$products = $this->db->select("SELECT pr.url, pr.categ FROM ?_".$this->module_table_products." pr WHERE pr.enabled=1 AND pr.categ>0");
		foreach($products as $product) {
			if(isset($this->all_categories[$product['categ']])) {
				$links[] = $catalog_full_link.'/'.$this->all_categories[$product['categ']]['full_link'].'/'.$product['url'].'.htm';
			}
		}
		unset($products);

		return $links;
	}

	/**
	 * ищет товары по определенному запросу, возвращает массив id найденных товаров
	 * @param string $q - первоначальная строка запроса, она для ключа кеша
	 * @param array $ar_q - двумерный массив с ключевыми словами
	 */
	public function searchProducts($q, $ar_q, $noenabled=false) {
		$cache_key = "search_productsids_".$q;
		if($noenabled) $cache_key .= "_noenabled";
		if (false === ($pr_ids = $this->cache->get($cache_key))) {
			// Вес отдельных слов в названии, полном названии и альтернативных названиях
			$coeff_title=round((20/count($ar_q[0])),3);
			$coeff_title_full=round((10/count($ar_q[0])),3);
			$coeff_alt_title=round((10/count($ar_q[0])),3);
			$sql = "SELECT pr.id, ( IF (pr.name LIKE ?, 30, 0) ";
			$placeholders = array("%".$q."%");

			$words = array();//массив уникальных слов из всего массива
			foreach($ar_q as $t_words) {
				foreach($t_words as $word) {
					if(!in_array($word, $words)) $words[] = $word;
				}
			}

			// Условия для каждого из слов
			foreach($words as $word) {
				$sql .= "+ IF (pr.name LIKE ?, ".$coeff_title.", 0)";
				$placeholders[] = "%".$word."%";
			}
			$sql.=") AS relevant FROM ?_".$this->module_table_products." pr";

			// Условие выборки - вхождение фразы в названия
			$sql .= " WHERE ".(!$noenabled ? "pr.enabled=1 AND " : "")."(";
			$sql .= " pr.name LIKE ?";
			$placeholders[] = "%".$q."%";

			// дополнительные условия выборки - вхождение отдельных слов фразы в названия, слова одного словосочетания ищутся как "И"
			foreach($ar_q as $t_words) {
				$t_sql = "";
				foreach($t_words as $word) {
					$t_sql .= ($t_sql!="" ? " AND " : "")."(pr.name LIKE ?)";
					$placeholders[] = "%".$word."%";
				}
				if($t_sql!="") $sql .= " OR ( ".$t_sql." )";
			}
			$sql .= ") ORDER BY relevant DESC";
			array_unshift($placeholders, $sql);

			$pr_ids = array();
			$t_pr_ids = call_user_func_array(array(&$this->db, 'select'), $placeholders);
			$cache_tags = array("catalog", "list_products", "search_products");
			if($t_pr_ids) {
				foreach($t_pr_ids as $pr) {
					$pr_ids[] = $pr['id'];
					$cache_tags[] = "productid_".$pr['id'];
				}
			}
			$this->cache->set($pr_ids, $cache_key, $cache_tags, 2*24*60*60);
		}
		return $pr_ids;
	}
}