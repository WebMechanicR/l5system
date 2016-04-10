<?php
/**
 * класс отображения текстовых страниц в административной части сайта
 * @author riol
 *
 */

class BackendPages extends View {
	public function index() {
		$this->admins->check_access_module('pages');

		$tree_pages = $this->pages->get_tree_pages();
		$this->tpl->add_var('tree_pages', $tree_pages);

		return $this->tpl->fetch('pages');
	}

	/**
	 * обновление порядка и вложенности страниц
	 */
	public function update_sort() {
		$this->admins->check_access_module('pages', 2);

		$update_page_id = $this->request->post("update_page_id", "integer");
		$items = $this->request->post("items", "array");

		if($update_page_id>0 and count($items)>0 and isset($items[$update_page_id]) and $update_page = $this->pages->get_page_info($update_page_id)) {

			$i = 1;
			foreach($items as $item_id=>$item_parent) {
				if($item_parent==$items[$update_page_id]) {
					if($item_id==$update_page_id and $item_parent!=$update_page['parent']) {
						//если у страницы поменялся родитель, нужно обновить полную ссылку и записи роутера для модуля, если он подключен
						if($item_parent>0) {
							$new_full_link = $this->pages->get_page_full_link(intval($item_parent)).'/';
						}
						else $new_full_link = '';
						$new_full_link .= $update_page['url'];

						$this->pages->update(intval($item_id), array("sort"=>$i, "parent"=>intval($item_parent), "full_link"=>$new_full_link));
					}
					else $this->pages->update(intval($item_id), array("sort"=>$i));
					$i++;
				}
			}
		}
		return null;
	}

	/**
	 * редактирование/добавлние страницы
	 */
	public function edit() {
		$this->admins->check_access_module('pages', 2);
		$this->pages->GetRussianNamesOfTpl();
		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$page_id = $this->request->$method("id", "integer");
		$parent = $this->request->$method("parent", "integer");
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";
		$from_revision = $this->request->get("from_revision", "integer");

		/**
		 * ошибки при заполнении формы
		 */
		$errors = array();

		$page_t = array("id"=>$page_id, "enabled"=>1, "parent"=>$parent);

		if($this->request->method('post') && !empty($_POST)) {
			$page_t['title'] = $this->request->post('title', 'string');
			$page_t['title_first'] = $this->request->post('title_first', 'string');
			$page_t['enabled'] = $this->request->post('enabled', 'integer');
			$page_t['sort'] = $this->request->post('sort', 'integer');
			$page_t['body'] = $this->request->post('body');
			$page_t['meta_title'] = $this->request->post('meta_title', 'string');
			$page_t['meta_description'] = $this->request->post('meta_description');
			$page_t['meta_keywords'] = $this->request->post('meta_keywords');
			$page_t['url'] = $this->request->post('url', 'string');
			$page_t['template'] = $this->request->post('template', 'string');
			$page_t['topage'] = $this->request->post('topage', 'url');
			$page_t['module'] = $this->request->post('module', 'string');
			$page_t['nomenu'] = $this->request->post('nomenu', 'integer');
			$page_t['nohead'] = $this->request->post('nohead', 'integer');

			$page_t['nesting'] = 1;
			if($page_t['module'] and $this->isset_module($page_t['module'])) {
				$module_page = $page_t['module'];
				$page_t['nesting'] = $this->$module_page->is_nesting();
			}

			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($page_t['url'])) {
				$errors['url'] = 'no_url';
				$tab_active = "other";
			}
			elseif(!preg_match("'^([a-z]|-|_|\.|\d)+$'si",$page_t['url'])) {
				$errors['url'] = 'error_url';
				$tab_active = "other";
			}
			else {

				if($page_t['parent']>0) {
					$parent_link = $this->pages->get_page_full_link($page_t['parent'])."/";
				}
				else $parent_link = "";

				//недопустим одинаковых url страниц
				$page_t['full_link'] = $parent_link.$page_t['url'];
				while(($c = $this->pages->get_page($page_t['full_link'])) and $c['id']!=$page_t['id'])
				{
					if(preg_match('/-([0-9]+)$/', $page_t['full_link'], $parts)) {
						$page_t['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $page_t['url']);
					}
					else {
						$page_t['url'] .= "-2";
					}
					$page_t['full_link'] = $parent_link.$page_t['url'];
				}
			}
			if(empty($page_t['title'])) {
				$errors['title'] = 'no_title';
				$tab_active = "main";
			}

			if(count($errors)==0) {

				if($page_id) {
					$this->pages->add_revision($page_id);
					$this->pages->update($page_id, $page_t);
				}
				else {
					$page_id = (int)$this->pages->add($page_t);
				}

				if($page_id) {
					// Обновление изображений
					if($name_pictures = $this->request->post('name_pictures', "array"))
					{
						$i=1;
						foreach($name_pictures as $id_pic=>$name_picture)
						{
							if(intval($id_pic)>0) $this->pages->update_image($id_pic, array('sort'=>$i, 'name'=>F::clean($name_picture), "for_id"=>$page_id));
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
							if ($image_name = $this->image->upload_image($picture, $picture['name'], $this->pages->setting("dir_images")))
							{
								$image_id = $this->pages->add_image($page_id, $image_name, $this->request->post('new_name_picture', 'string'), $this->request->post('sort_photo_new', 'integer'));
								if(!$image_id) {
									$errors['photo'] = 'error_internal';
									$tab_active = "photo";
								}
								elseif($picture_prev = $this->request->files('picture_prev')) {
									if(!isset($picture_prev['error']) or $picture_prev['error']==0) {
										$this->pages->update_image_preview($image_name, $picture_prev);
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

					// Обновление файлов
					if($name_files = $this->request->post('name_files', "array"))
					{
						$i=1;
						foreach($name_files as $id_file=>$name_file)
						{
							if(intval($id_file)>0) $this->pages->update_file($id_file, array('sort'=>$i, 'name'=>F::clean($name_file), "for_id"=>$page_id));
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
							if ($file_name = $this->file->upload_file($file, $file['name'], $this->pages->setting("dir_files")))
							{
								$file_id = $this->pages->add_file($page_id, $file_name, $this->request->post('new_name_file', 'string'), $this->request->post('sort_file_new', 'integer'));
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
				if($after_exit and count($errors)==0 and $may_noupdate_form) {
					header("Location: ".DIR_ADMIN."?module=pages");
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $page_t['id'] and $may_noupdate_form) return 1;
			}
		}


		if($page_id) {
			if($from_revision) {
				$page_t = $this->pages->get_from_revision($from_revision, $page_id);
			}
			else {
				$page_t = $this->pages->get_page($page_id);
			}
			if(count($page_t)==0) {
				header("Location: ".DIR_ADMIN."?module=pages");
				exit();
			}
			$content_photos = $this->pages->get_images($page_id);
			$content_files = $this->pages->get_files($page_id);
			$list_revisions = $this->pages->get_list_revisions($page_id);
		}
		else {
			$page_t['sort'] = $this->pages->get_new_page_sort($parent);
			$content_photos = $content_files = $list_revisions = array();
		}

		$modules = $this->get_modules(array("is_attach"=>1));

		$tree_pages = $this->pages->get_tree_pages();


		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('page_t', $page_t);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('modules', $modules);
		$this->tpl->add_var('tree_pages', $tree_pages);
		$this->tpl->add_var('list_revisions', $list_revisions);
		$this->tpl->add_var('from_revision', $from_revision);
		$this->tpl->add_var('content_photos', $content_photos);
		$this->tpl->add_var('content_photos_for_id', $page_id);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->pages->setting("dir_images"));
		$this->tpl->add_var('content_files', $content_files);
		$this->tpl->add_var('content_files_for_id', $page_id);
		$this->tpl->add_var('content_files_dir', SITE_URL.URL_FILES.$this->pages->setting("dir_files"));
		return $this->tpl->fetch('pages_add');
	}

	/**
	 * синоним для edit
	 */
	public function add() {
		return $this->edit();
	}

	/**
	 * удаление страницы
	 */
	public function delete() {
		$this->admins->check_access_module('pages', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->pages->delete($id);
		return $this->index();
	}

	/**
	 * действия с группами страниц
	 */
	public function group_actions() {
		$this->admins->check_access_module('pages', 2);
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "hide":
					$this->pages->update($items, array("enabled"=>0));
					break;
				case "show":
					$this->pages->update($items, array("enabled"=>1));
					break;
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->pages->delete($id);
					}
					break;
			}
		}

		return $this->index();
	}

	/**
	 * создает дубликат страницы
	 * @return string
	 */
	public function duplicate() {
		$this->admins->check_access_module('pages', 2);
		$id = $this->request->get("id", "integer");
		if($id>0) $this->pages->duplicate($id);
		return $this->index();
	}
}