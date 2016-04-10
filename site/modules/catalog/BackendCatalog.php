<?php
/**
 * класс отображения каталога в административной части сайта
 * @author riol
 *
 */

class BackendCatalog extends View {
	public function index() {
		$this->admins->check_access_module('catalog');

		$tree_categories = $this->catalog->get_tree_categories();
		$this->tpl->add_var('tree_categories', $tree_categories);
		return $this->tpl->fetch('catalog_categories');
	}

	/**
	 * обновление порядка и вложенности категорий
	 */
	public function update_sort_category() {
		$this->admins->check_access_module('catalog', 2);

		$update_category_id = $this->request->post("update_category_id", "integer");
		$items = $this->request->post("items", "array");

		if($update_category_id>0 and count($items)>0 and isset($items[$update_category_id]) and $update_category = $this->catalog->get_category_info($update_category_id)) {

			$i = 1;
			foreach($items as $item_id=>$item_parent) {
				if($item_parent==$items[$update_category_id]) {
					if($item_id==$update_category_id and $item_parent!=$update_category['parent']) {
						//если у категории поменялся родитель, нужно обновить полную ссылку
						if($item_parent>0) {
							$new_full_link = $this->catalog->get_category_full_link(intval($item_parent)).'/';
						}
						else $new_full_link = '';
						$new_full_link .= $update_category['url'];

						$this->catalog->update_category(intval($item_id), array("sort"=>$i, "parent"=>intval($item_parent), "full_link"=>$new_full_link));
					}
					else $this->catalog->update_category(intval($item_id), array("sort"=>$i));
					$i++;
				}
			}
		}
		return null;
	}

	/**
	 * редактирование/добавлние категории
	 */
	public function edit_category() {
		$this->admins->check_access_module('catalog', 2);

		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$category_id = $this->request->$method("id", "integer");
		$parent = $this->request->$method("parent", "integer");
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";

		/**
		 * ошибки при заполнении формы
		 */
		$errors = array();

		$category_t = array("id"=>$category_id, "enabled"=>1, "parent"=>$parent);

		if($this->request->method('post') && !empty($_POST)) {
			$category_t['title'] = $this->request->post('title', 'string');
			$category_t['title_full'] = $this->request->post('title_full', 'string');
			$category_t['enabled'] = $this->request->post('enabled', 'integer');
			$category_t['sort'] = $this->request->post('sort', 'integer');
			$category_t['body'] = $this->request->post('body');
			$category_t['meta_title'] = $this->request->post('meta_title', 'string');
			$category_t['meta_description'] = $this->request->post('meta_description');
			$category_t['meta_keywords'] = $this->request->post('meta_keywords');
			$category_t['img'] = $this->request->post('img', 'string');
			$category_t['url'] = $this->request->post('url', 'string');
				
			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($category_t['url'])) {
				$errors['url'] = 'no_url';
				$tab_active = "other";
			}
			elseif(!preg_match("'^([a-z]|-|_|\.|\d)+$'si",$category_t['url'])) {
				$errors['url'] = 'error_url';
				$tab_active = "other";
			}
			else {

				if($category_t['parent']>0) {
					$parent_link = $this->catalog->get_category_full_link($category_t['parent'])."/";
				}
				else $parent_link = "";

				//недопустим одинаковых url категорий
				$category_t['full_link'] = $parent_link.$category_t['url'];
				while(($c = $this->catalog->get_category($category_t['full_link'])) and $c['id']!=$category_t['id'])
				{
					if(preg_match('/-([0-9]+)$/', $category_t['full_link'], $parts)) {
						$category_t['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $category_t['url']);
					}
					else {
						$category_t['url'] .= "-2";
					}
					$category_t['full_link'] = $parent_link.$category_t['url'];
				}
			}
			if(empty($category_t['title'])) {
				$errors['title'] = 'no_title';
				$tab_active = "main";
			}

			if(count($errors)==0) {

				if($category_id) {
					$this->catalog->update_category($category_id, $category_t);
				}
				else {
					$category_id = (int)$this->catalog->add_category($category_t);
				}

				if($category_id) {
					// Загрузка изображений
					if($picture = $this->request->files('picture'))
					{
						if(isset($picture['error']) and $picture['error']!=0) {
							$errors['photo'] = 'error_size';
							$tab_active = "main";
						}
						else {
							if ($image_name = $this->image->upload_image($picture, $picture['name'], $this->catalog->setting("dir_images")))
							{
								$errFlag = false;
								if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->catalog->setting("dir_images")."original/".$image_name, ROOT_DIR_IMAGES.$this->catalog->setting("dir_images")."normal/".$image_name, array(138, 138, false, false))) $errFlag = true;
								if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->catalog->setting("dir_images")."original/".$image_name, ROOT_DIR_IMAGES.$this->catalog->setting("dir_images")."small/".$image_name, array(138, 138, true, false))) $errFlag = true;

								$this->catalog->update_category($category_id, array("img"=>$image_name));

								if($errFlag) {
									$errors['photo'] = 'error_internal';
									$tab_active = "main";
								}
							}
							else
							{
								if($image_name===false) $errors['photo'] = 'error_type';
								else $errors['photo'] = 'error_upload';
								$tab_active = "main";
							}
						}
						$may_noupdate_form = false;
					}
				}
				
				/**
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список категорий
				 */
				if($after_exit and count($errors)==0) {
					header("Location: ".DIR_ADMIN."?module=catalog");
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $category_t['id'] and $may_noupdate_form) return 1;
			}
		}


		if($category_id) {
			$category_t = $this->catalog->get_category($category_id);
			if(count($category_t)==0) {
				header("Location: ".DIR_ADMIN."?module=catalog");
				exit();
			}
		}
		else {
			$category_t['sort'] = $this->catalog->get_new_category_sort($parent);
		}

		$tree_categories = $this->catalog->get_tree_categories();
		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('category_t', $category_t);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('tree_categories', $tree_categories);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->catalog->setting("dir_images"));
		return $this->tpl->fetch('catalog_category_add');
	}

	/**
	 * синоним для edit_category
	 */
	public function add_category() {
		return $this->edit_category();
	}

	/**
	 * удаление категории
	 */
	public function delete_category() {
		$this->admins->check_access_module('catalog', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->catalog->delete_category($id);
		return $this->index();
	}

	/**
	 * действия с группами категорий
	 */
	public function group_actions_category() {
		$this->admins->check_access_module('catalog', 2);
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "hide":
					$this->catalog->update_category($items, array("enabled"=>0));
					break;
				case "show":
					$this->catalog->update_category($items, array("enabled"=>1));
					break;
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->catalog->delete_category($id);
					}
					break;
			}
		}

		return $this->index();
	}

	/**
	 * создает дубликат категории
	 * @return string
	 */
	public function duplicate_category() {
		$this->admins->check_access_module('catalog', 2);
		$id = $this->request->get("id", "integer");
		if($id>0) $this->catalog->duplicate_category($id);
		return $this->index();
	}

	public function products() {
		$this->admins->check_access_module('catalog');

		//$this->catalog->update_catalog_count();

		$sort_by = $this->request->get("sort_by", "string");
		$sort_dir = $this->request->get("sort_dir", "string");
		$category_id = $this->request->get("category_id", "integer");
		$name = $this->request->get("name", "string");
		$name_full = $this->request->get("name_full", "string");
		$articul = $this->request->get("articul", "string");

		if(!$sort_by or !in_array($sort_by, array("name", "name_full", "articul", "price", "price_date", "enabled")) ) $sort_by = "sort";
		if(!$sort_dir or !in_array($sort_dir, array("asc", "desc")) ) $sort_dir = "desc";

		$link_added_query = "&sort_by=".$sort_by."&sort_dir=".$sort_dir;
		$filtres_query = "&category_id=".$category_id."&name=".$name."&name_full=".$name_full."&articul=".$articul;
		$paging_added_query = "&action=products&sort_by=".$sort_by."&sort_dir=".$sort_dir.$filtres_query;

		// Постраничная навигация
		$limit = intval($this->settings->limit_admin_num);
		// Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);
		$link_added_query .= "&p=".$p;

		$filter = array("sort"=> array($sort_by, $sort_dir));

		$filter["limit"] = array($p, $limit);

		if($category_id) $filter["category_id"] = $category_id;
		if($articul!='') $filter["articul"] = $articul;
		if($name!='') $filter["name"] = $name;
		if($name_full!='') $filter["name_full"] = $name_full;

		// Вычисляем количество страниц
		$products_count = intval($this->catalog->get_count_products($filter));
		$total_pages_num = ceil($products_count/$limit);

		$catalog_full_link = $this->pages->get_full_link_module("catalog");
		$tree_categories = $this->catalog->get_tree_categories();

		$list_products = $this->catalog->get_list_products( $filter );
		$this->tpl->add_var('list_products', $list_products);
		$this->tpl->add_var('articul', $articul);
		$this->tpl->add_var('name', $name);
		$this->tpl->add_var('name_full', $name_full);
		$this->tpl->add_var('sort_by', $sort_by);
		$this->tpl->add_var('sort_dir', $sort_dir);
		$this->tpl->add_var('category_id', $category_id);
		$this->tpl->add_var('products_count', $products_count);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_added_query', $paging_added_query);
		$this->tpl->add_var('link_added_query', $link_added_query);
		$this->tpl->add_var('filtres_query', $filtres_query);
		$this->tpl->add_var('tree_categories', $tree_categories);
		$this->tpl->add_var('catalog_full_link', $catalog_full_link);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->catalog->setting("dir_images"));

		return $this->tpl->fetch('catalog_products');
	}

	/**
	 * редактирование/добавлние товара
	 */
	public function edit_product() {
		$this->admins->check_access_module('catalog', 2);

		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$product_id = $this->request->$method("id", "integer");
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";
		$from_revision = $this->request->get("from_revision", "integer");
		$category_id = $this->request->get("category_id", "string");

		/**
		 * ошибки при заполнении формы
		*/
		$errors = array();

		$product = array("id"=>$product_id, "enabled"=>1, "categ"=>$category_id);

		if($this->request->method('post') && !empty($_POST)) {
			$product['name'] = $this->request->post('name', 'string');
			$product['name_full'] = $this->request->post('name_full', 'string');
			$product['articul'] = $this->request->post('articul', 'string');
			$product['enabled'] = $this->request->post('enabled', 'integer');
			$product['categ'] = $this->request->post('categ', 'integer');
			$product['viewed'] = $this->request->post('viewed', 'integer');
			$product['brief_description'] = $this->request->post('brief_description');
			$product['url'] = $this->request->post('url', 'string');
			$complect_products = $this->request->post('complect_products', "array");
			$product['novelty'] = $this->request->post('novelty', 'integer');
			$product['special'] = $this->request->post('special', 'integer');
				
			$product['price'] = $this->request->post('price', 'float');
			$product['last_price'] = $this->request->post('last_price', 'float');

			$product['meta_title'] = $this->request->post('meta_title', 'string');
			$product['meta_description'] = $this->request->post('meta_description');
			$product['meta_keywords'] = $this->request->post('meta_keywords');
			$product['description'] = $this->request->post('description');
				
                        $product['show_in_block1'] = $this->request->post('show_in_block1', 'integer');
                        $product['show_in_block2'] = $this->request->post('show_in_block2', 'integer');
                        $product['is_hit'] = $this->request->post('is_hit', 'integer');
                        
			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($product['url'])) {
				$errors['url'] = 'no_url';
				$tab_active = "other";
			}
			elseif(!preg_match("'^([a-z]|-|_|\.|\d)+$'si",$product['url'])) {
				$errors['url'] = 'error_url';
				$tab_active = "other";
			}
			else {
				//недопустим одинаковых url страниц
				while(($c = $this->catalog->get_product($product['url'])) and $c['id']!=$product['id'])
				{
					if(preg_match('/-([0-9]+)$/', $product['url'], $parts)) {
						$product['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $product['url']);
					}
					else {
						$product['url'] .= "-2";
					}
				}
			}
			if(empty($product['name'])) {
				$errors['name'] = 'no_title';
				$tab_active = "main";
			}
				
			//если не выбрана основная категория, сделаем первую из списка основной.
			if($product['categ']==0) {
				$errors['categories'] = 'no_category';
				$tab_active = "main";
			}

			if(count($errors)==0) {

				if($product_id) {
					$old_product = $this->catalog->get_product_info($product_id);
					if($old_product['price']!=$product['price']) {
						//если новая цена стала меньше на 2 и более процента6 и "старая" цена не задана - в поле старая цена записываем предыдущюю цену
						if($product['last_price']==0 and $old_product['price']>$product['price'] and ($old_product['price']-$product['price'])/$old_product['price'] > 0.02) {
							$product['last_price'] = $old_product['price'];
						}
					}
                                        if($old_product['show_in_block1'] != $product['show_in_block1'])
                                            $this->cache->delete('block1_on_main_page');
                                        if($old_product['show_in_block2'] != $product['show_in_block2'])
                                            $this->cache->delete('block2_on_main_page');
                                        
					$this->catalog->add_revision($product_id);
					$this->catalog->update_product($product_id, $product);
				}
				else {
					$product_id = (int)$this->catalog->add_product($product);
					if($product['enabled'] ) {
						//повышаем счетчик товаров у категории товара
						$this->catalog->upcount_product_categories(0, array($product['categ']));
					}
				}

				if($product_id) {

					//удаляем старые связанные товары и добавляем новые
					$this->catalog->delete_related_product_all($product_id);
						
					if(is_array($complect_products) and count($complect_products)>0) {
						$complect_products = array_unique($complect_products);
						foreach($complect_products as $i => $complect_product) {
							if(intval($complect_product)>0)
							{
								$this->catalog->add_related_product(array("product_id"=>$product_id, "product_id2"=>intval($complect_product), "type"=>0, "sort" => ($i + 1)));
							}
						}
					}
						
						
					// Обновление изображений
					if($name_pictures = $this->request->post('name_pictures', "array"))
					{
						$i=1;
						foreach($name_pictures as $id_pic=>$name_picture)
						{
							if(intval($id_pic)>0) $this->catalog->update_image($id_pic, array('sort'=>$i, 'name'=>F::clean($name_picture), "for_id"=>$product_id));
							$i++;
						}
					}

					// Загрузка изображений
					if($picture = $this->request->files('picture'))
					{
						if(isset($picture['error']) and $picture['error']!=0) {
							$errors['photo'] = 'error_size';
							$tab_active = "photo";
						}
						else {
							if ($image_name = $this->image->upload_image($picture, $picture['name'], $this->catalog->setting("dir_images")))
							{
								$image_id = $this->catalog->add_image($product_id, $image_name, $this->request->post('new_name_picture', 'string'), $this->request->post('sort_photo_new', 'integer'));
								if(!$image_id) {
									$errors['photo'] = 'error_internal';
									$tab_active = "photo";
								}
								elseif($picture_prev = $this->request->files('picture_prev')) {
									if(!isset($picture_prev['error']) or $picture_prev['error']==0) {
										$this->catalog->update_image_preview($image_name, $picture_prev);
									}
								}
							}
							else
							{
								if($image_name===false) $errors['photo'] = 'error_type';
								else $errors['photo'] = 'error_upload';
								$tab_active = "photo";
							}
						}
						$may_noupdate_form = false;
					}

					//сохраняем главное изображение
					$up_main_image = array("img"=>"");
					if($content_photos = $this->catalog->get_images($product_id)) {
						if(isset($content_photos[0]) and isset($content_photos[0]['picture'])) $up_main_image = array("img"=>$content_photos[0]['picture']);
					}
					$this->catalog->update_product($product_id, $up_main_image);

					// Обновление файлов
					if($name_files = $this->request->post('name_files', "array"))
					{
						$i=1;
						foreach($name_files as $id_file=>$name_file)
						{
							if(intval($id_file)>0) $this->catalog->update_file($id_file, array('sort'=>$i, 'name'=>F::clean($name_file), "for_id"=>$product_id));
							$i++;
						}
					}

					// Загрузка файлов
					if($file = $this->request->files('file'))
					{
						if(isset($file['error']) and $file['error']!=0) {
							$errors['file'] = 'error_size';
							$tab_active = "files";
						}
						else {
							if ($file_name = $this->file->upload_file($file, $file['name'], $this->catalog->setting("dir_files")))
							{
								$file_id = $this->catalog->add_file($product_id, $file_name, $this->request->post('new_name_file', 'string'), $this->request->post('sort_file_new', 'integer'));
								if(!$file_id) {
									$errors['file'] = 'error_internal';
									$tab_active = "files";
								}
							}
							else
							{
								if($file_name===false) $errors['file'] = 'error_type';
								else $errors['file'] = 'error_upload';
								$tab_active = "files";
							}
						}
						$may_noupdate_form = false;
					}

				}

				/**
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список страниц
				 */
				if($after_exit and count($errors)==0) {
					header("Location: ".DIR_ADMIN."?module=catalog&action=products&category_id=".$product['categ']);
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $product['id'] and $may_noupdate_form) return 1;

			}
		}

                $complect_products = array();
		if($product_id) {
			if($from_revision) {
				$product = $this->catalog->get_from_revision($from_revision, $product_id);
			}
			else {
				$product = $this->catalog->get_product($product_id);
			}
			if(count($product)==0) {
				header("Location: ".DIR_ADMIN."?module=catalog&action=products");
				exit();
			}
			$content_photos = $this->catalog->get_images($product_id);
			$content_files = $this->catalog->get_files($product_id);
			$list_revisions = $this->catalog->get_list_revisions($product_id);
                        $related_products = $this->catalog->get_related_products($product_id);
                        $complect_products = array();
                        foreach($related_products as $related_product) {
                                if($related_product['type_related']==0) $complect_products[] = $related_product;
                        }
		}
		else {
			$content_photos = $content_files = $list_revisions = $complect_products = array();
		}
		$tree_categories = $this->catalog->get_tree_categories();
		$this->tpl->add_var('complect_products', $complect_products);
		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('product', $product);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('list_revisions', $list_revisions);
		$this->tpl->add_var('from_revision', $from_revision);
		$this->tpl->add_var('tree_categories', $tree_categories);
		$this->tpl->add_var('content_photos', $content_photos);
		$this->tpl->add_var('content_photos_for_id', $product_id);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->catalog->setting("dir_images"));
		$this->tpl->add_var('content_files', $content_files);
		$this->tpl->add_var('content_files_for_id', $product_id);
		$this->tpl->add_var('content_files_dir', SITE_URL.URL_FILES.$this->catalog->setting("dir_files"));
		return $this->tpl->fetch('catalog_product_add');
	}

	/**
	 * синоним для edit_product
	 */
	public function add_product() {
		return $this->edit_product();
	}

	/**
	 * создает дубликат категории
	 * @return string
	 */
	public function duplicate_product() {
		$this->admins->check_access_module('catalog', 2);
		$id = $this->request->get("id", "integer");
		if($id>0) $this->catalog->duplicate_product($id);
		return $this->products();
	}

	/**
	 * удаление товара
	 */
	public function delete_product() {
		$this->admins->check_access_module('catalog', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->catalog->delete_product($id);
		return $this->products();
	}


	/**
	 * обновление полей товара аяксом
	 */
	public function update_product_field() {
		$this->admins->check_access_module('catalog', 2);
		$field = $this->request->get("field", "string");

		switch($field) {
			case "price":
				$products_price = $this->request->post("products_price", "array");
				if(is_array($products_price)) {
					foreach($products_price as $product_id=>$price) {
						$price = floatval($price);
						if($product = $this->catalog->get_product($product_id) and $product['price'] != $price) {
							$update_array = array("price"=>$price);
							//если новая цена стала меньше на 2 и более процента6 и "старая" цена не задана - в поле старая цена записываем предыдущюю цену
							if($product['last_price']==0 and $product['price']>$price and ($product['price']-$price)/$product['price'] > 0.02) {
								$update_array['last_price'] = $product['price'];
							}
								
							$this->catalog->update_product($product_id, $update_array);
						}
					}
				}
				break;
		}
		return true;
	}

	/**
	 * действия с группами товаров
	 */
	public function group_actions_product() {
		$this->admins->check_access_module('catalog', 2);
		$items = $this->request->post("check_item", "array");
		$group_actions = $this->request->post("group_actions", "integer");
		if(is_array($items) and count($items)>0 and $group_actions) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "hide":
					$this->catalog->update_product($items, array("enabled"=>0));
					break;
				case "show":
					$this->catalog->update_product($items, array("enabled"=>1));
					break;
				case "movetocateg":
					$category_to = $this->request->post("category_to", "integer");
					$category_id = $this->request->get("category_id", "integer");
					if($category_to) {
						$this->catalog->update_product($items, array("categ"=>$category_to));
						$_GET['category_id'] = $category_to;
						$this->catalog->update_catalog_count();
					}
					break;
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->catalog->delete_product($id);
					}
					break;
			}
		}
		elseif(!$group_actions and $this->request->method('post') and !empty($_POST)) {
			$sort = $this->request->post('sort', "array");

			if(is_array($sort) and count($sort)>0) {
				$ids = array_keys($sort);
				sort($sort);
				$sort = array_reverse($sort);
				foreach($sort as $i=>$position)
					$this->catalog->update_product($ids[$i], array('sort'=>$position));
					
				$this->cache->clean(array("list_products"));
				
				/**
				 * если загрузка аяксом и не было добавления возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				if($this->request->isAJAX()) return 1;
			}
		}

		return $this->products();
	}

	/**
	 * управление видами доставки
	 */
	public function deliveries() {
		$this->admins->check_access_module('catalog', 2);

		$del_id = $this->request->get("del_id", "integer");
		if($del_id>0) $this->catalog->delete_delivery($del_id);

		if($this->request->method('post') && !empty($_POST)) {
			$new_delivery_name = $this->request->post('new_delivery_name', 'string');
			$new_delivery_sort = $this->request->post('new_delivery_sort', 'integer');

			$delivery_name = $this->request->post('delivery_name', "array");

			if(is_array($delivery_name) and count($delivery_name)>0) {
				/**
				 * обновляем список доставок
				 */
				$i=1;
				foreach($delivery_name as $up_delivery_id=>$up_delivery_name) {
					$up_delivery_name = F::clean($up_delivery_name);
					$up_delivery_id = intval($up_delivery_id);
					if($up_delivery_id>0 and !empty($up_delivery_name)) {
						$this->catalog->update_delivery($up_delivery_id, array("name"=>$up_delivery_name, "sort"=>$i));
					}
					$i++;
				}
			}

			if(!empty($new_delivery_name)) {
				/**
				 * добавляем новую доставку
				 */
				$add_delivery = array("name"=>$new_delivery_name, "sort"=>$new_delivery_sort);
				$this->catalog->add_delivery($add_delivery);
			}
			/**
			 * если загрузка аяксом и не было добавления возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
			 */
			elseif($this->request->isAJAX()) return 1;
		}

		$deliveries = $this->catalog->get_list_deliveries();

		$this->tpl->add_var('deliveries', $deliveries);
		return $this->tpl->fetch('catalog_deliveries');
	}
	
		/**
	 * управление видами оплаты
	 */
	public function payment_types() {
		$this->admins->check_access_module('catalog', 2);

		$del_id = $this->request->get("del_id", "integer");
		if($del_id>0) $this->catalog->delete_payment_type($del_id);

		if($this->request->method('post') && !empty($_POST)) {
			$new_payment_type_name = $this->request->post('new_payment_type_name', 'string');
			$new_payment_type_sort = $this->request->post('new_payment_type_sort', 'integer');

			$payment_type_name = $this->request->post('payment_type_name', "array");

			if(is_array($payment_type_name) and count($payment_type_name)>0) {
				/**
				 * обновляем список типов оплаты
				 */
				$i=1;
				foreach($payment_type_name as $up_payment_type_id=>$up_payment_type_name) {
					$up_payment_type_name = F::clean($up_payment_type_name);
					$up_payment_type_id = intval($up_payment_type_id);
					if($up_payment_type_id>0 and !empty($up_payment_type_name)) {
						$this->catalog->update_payment_type($up_payment_type_id, array("name"=>$up_payment_type_name, "sort"=>$i));
					}
					$i++;
				}
			}

			if(!empty($new_payment_type_name)) {
				/**
				 * добавляем новый тип оплаты
				 */
				$add_payment_type = array("name"=>$new_payment_type_name, "sort"=>$new_payment_type_sort);
				$this->catalog->add_payment_type($add_payment_type);
			}
			/**
			 * если загрузка аяксом и не было добавления возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
			 */
			elseif($this->request->isAJAX()) return 1;
		}

		$payment_types = $this->catalog->get_list_payment_types();

		$this->tpl->add_var('payment_types', $payment_types);
		return $this->tpl->fetch('catalog_payment_types');
	}
}