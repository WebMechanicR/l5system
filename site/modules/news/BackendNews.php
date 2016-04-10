<?php
/**
 * класс отображения новостей в административной части сайта
 * @author riol
 *
 */

class BackendNews extends View {
	public function index() {
		$this->admins->check_access_module('news');

		$sort_by = $this->request->get("sort_by", "string");
		$sort_dir = $this->request->get("sort_dir", "string");

		if(!$sort_by or !in_array($sort_by, array("title", "date_add", "enabled")) ) $sort_by = "date_add";
		if(!$sort_dir or !in_array($sort_dir, array("asc", "desc")) ) $sort_dir = "desc";

		$paging_added_query = "&action=index&sort_by=".$sort_by."&sort_dir=".$sort_dir;
		$link_added_query = "&sort_by=".$sort_by."&sort_dir=".$sort_dir;


		// Постраничная навигация
		$limit = ($tmpVar = intval($this->settings->limit_admin_num)) ? $tmpVar : 10;
		// Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);
		$link_added_query .= "&p=".$p;

		$filter = array("sort"=> array($sort_by, $sort_dir));

		$filter["limit"] = array($p, $limit);

		// Вычисляем количество страниц
		$news_count = intval($this->news->get_count_news($filter));
		$total_pages_num = ceil($news_count/$limit);

		$news_full_link = $this->pages->get_full_link_module("news");

		$list_news = $this->news->get_list_news( $filter );

		$this->tpl->add_var('list_news', $list_news);
		$this->tpl->add_var('sort_by', $sort_by);
		$this->tpl->add_var('sort_dir', $sort_dir);
		$this->tpl->add_var('news_count', $news_count);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_added_query', $paging_added_query);
		$this->tpl->add_var('link_added_query', $link_added_query);
		$this->tpl->add_var('news_full_link', $news_full_link);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->news->setting("dir_images"));

		return $this->tpl->fetch('news');
	}

	/**
	 * редактирование/добавлние новости
	 */
	public function edit() {
		$this->admins->check_access_module('news', 2);

		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$news_id = $this->request->$method("id", "integer");
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";
		$from_revision = $this->request->get("from_revision", "integer");

		/**
		 * ошибки при заполнении формы
		 */
		$errors = array();

		$news = array("id"=>$news_id, "enabled"=>1, "date_add"=>time());

		if($this->request->method('post') && !empty($_POST)) {
			$news['title'] = $this->request->post('title', 'string');
			$date = $this->request->post('date', 'string');
			$h = $this->request->post('h', 'integer');
			$m = $this->request->post('m', 'integer');

			if($date=="") $date=date("d.m.Y");
			list($news['day'], $news['month'], $news['year']) = explode(".",$date);
			$news['date_add'] = mktime($h, $m, 0, $news['month'], $news['day'], $news['year']);
			$news['enabled'] = $this->request->post('enabled', 'integer');
			$news['brief_description'] = $this->request->post('brief_description');
			$news['body'] = $this->request->post('body');
			$news['meta_title'] = $this->request->post('meta_title', 'string');
			$news['meta_description'] = $this->request->post('meta_description');
			$news['meta_keywords'] = $this->request->post('meta_keywords');
			$news['url'] = $this->request->post('url', 'string');


			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($news['url'])) {
				$errors['url'] = 'no_url';
				$tab_active = "other";
			}
			elseif(!preg_match("'^([a-z]|-|_|\.|\d)+$'si",$news['url'])) {
				$errors['url'] = 'error_url';
				$tab_active = "other";
			}
			else {

				//недопустим одинаковых url страниц
				while(($c = $this->news->get_news($news['url'])) and $c['id']!=$news['id'])
				{
					if(preg_match('/-([0-9]+)$/', $news['url'], $parts)) {
						$news['url'] = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $news['url']);
					}
					else {
						$news['url'] .= "-2";
					}
				}
			}
			if(empty($news['title'])) {
				$errors['title'] = 'no_title';
				$tab_active = "main";
			}

			if(count($errors)==0) {

				if($news_id) {
					$this->news->add_revision($news_id);
					$this->news->update($news_id, $news);
				}
				else {
					$news_id = (int)$this->news->add($news);
				}

				if($news_id) {
					// Обновление изображений
					if($name_pictures = $this->request->post('name_pictures', "array"))
					{
						$i=1;
						foreach($name_pictures as $id_pic=>$name_picture)
						{
							if(intval($id_pic)>0) $this->news->update_image($id_pic, array('sort'=>$i, 'name'=>F::clean($name_picture), "for_id"=>$news_id));
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
							if ($image_name = $this->image->upload_image($picture, $picture['name'], $this->news->setting("dir_images")))
							{
								$image_id = $this->news->add_image($news_id, $image_name, $this->request->post('new_name_picture', 'string'), $this->request->post('sort_photo_new', 'integer'));
								if(!$image_id) {
									$errors['photo'] = 'error_internal';
									$tab_active = "photo";
								}
								elseif($picture_prev = $this->request->files('picture_prev')) {
									if(!isset($picture_prev['error']) or $picture_prev['error']==0) {
										$this->news->update_image_preview($image_name, $picture_prev);
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
					if($content_photos = $this->news->get_images($news_id)) {
						if(isset($content_photos[0]) and isset($content_photos[0]['picture'])) $up_main_image = array("img"=>$content_photos[0]['picture']);
					}
					$this->news->update($news_id, $up_main_image);
				}

				/**
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список страниц
				 */
				if($after_exit and count($errors)==0) {
					header("Location: ".DIR_ADMIN."?module=news");
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $news['id'] and $may_noupdate_form) return 1;
			}
		}


		if($news_id) {
			if($from_revision) {
				$news = $this->news->get_from_revision($from_revision, $news_id);
			}
			else {
				$news = $this->news->get_news($news_id);
			}
			if(count($news)==0) {
				header("Location: ".DIR_ADMIN."?module=news");
				exit();
			}
			$content_photos = $this->news->get_images($news_id);
			$list_revisions = $this->news->get_list_revisions($news_id);
		}
		else {
			$content_photos = $list_revisions = array();
		}

		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('news', $news);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('list_revisions', $list_revisions);
		$this->tpl->add_var('from_revision', $from_revision);
		$this->tpl->add_var('content_photos', $content_photos);
		$this->tpl->add_var('content_photos_for_id', $news_id);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->news->setting("dir_images"));
		return $this->tpl->fetch('news_add');
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
		$this->admins->check_access_module('news', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->news->delete($id);
		return $this->index();
	}

	/**
	 * действия с группами страниц
	 */
	public function group_actions() {
		$this->admins->check_access_module('news', 2);
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "hide":
					$this->news->update($items, array("enabled"=>0));
					break;
				case "show":
					$this->news->update($items, array("enabled"=>1));
					break;
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->news->delete($id);
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
		$this->admins->check_access_module('news', 2);
		$id = $this->request->get("id", "integer");
		if($id>0) $this->news->duplicate($id);
		return $this->index();
	}
}