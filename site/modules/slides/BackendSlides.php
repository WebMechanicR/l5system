<?php
/**
 * класс отображения слайд-шоу в административной части сайта
 * @author riol
 *
 */

class BackendSlides extends View {
	public function index() {
		$this->admins->check_access_module('slides');	
			
		/**
		 * действия с группами свойств
		 */
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0 and $this->request->post("group_actions", "integer")) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "hide":
					$this->slides->update($items, array("enabled"=>0));
					break;
				case "show":
					$this->slides->update($items, array("enabled"=>1));
					break;
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->slides->delete($id);
					}
					break;
			}
		}
		
		elseif($this->request->method('post') && !empty($_POST)) {
			$slide_name = $this->request->post('slide_name', "array");
		
			if(is_array($slide_name) and count($slide_name)>0) {
				/**
				 * обновляем список
				 */
				$i=1;
				foreach($slide_name as $up_slide_id=>$up_slide_name) {
					$up_slide_id = intval($up_slide_id);
					if($up_slide_id>0 ) {
						$this->slides->update($up_slide_id, array("sort"=>$i));
					}
					$i++;
				}
			}
		
			/**
			 * если загрузка аяксом и не было добавления возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
			 */
			if($this->request->isAJAX()) return 1;
		}
		
		$list_slides = $this->slides->get_list_slides(  );
		
		$this->tpl->add_var('list_slides', $list_slides);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->slides->setting("dir_images"));
		
		return $this->tpl->fetch('slides');
	}

	/**
	 * редактирование/добавлние новости
	 */
	public function edit() {
		$this->admins->check_access_module('slides', 2);

		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$slide_id = $this->request->$method("id", "integer");
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";
		$from_revision = $this->request->get("from_revision", "integer");
		

		/**
		 * ошибки при заполнении формы
		 */
		$errors = array();

		$slide = array("id"=>$slide_id, "enabled"=>1);

		if($this->request->method('post') && !empty($_POST)) {
			$slide['title'] = $this->request->post('title', 'string');
                        $slide['description'] = $this->request->post('desc', 'string');
			$slide['sort'] = $this->request->post('sort', 'integer');
			
			$slide['enabled'] = $this->request->post('enabled', 'integer');
			$slide['img'] = $this->request->post('img', 'string');
			$slide['url'] = $this->request->post('url', 'url');
					

			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($slide['title'])) {
				$errors['title'] = 'no_title';
				$tab_active = "main";
			}

			if(count($errors)==0) {

				if($slide_id) {
					$this->slides->add_revision($slide_id);
					$this->slides->update($slide_id, $slide);
				}
				else {
					$slide_id = (int)$this->slides->add($slide);
				}

				if($slide_id) {
				// Загрузка изображений
					if($picture = $this->request->files('picture'))
					{
						if(isset($picture['error']) and $picture['error']!=0) {
							$errors['photo'] = 'error_size';
							$tab_active = "main";
						}
						else {
							if ($image_name = $this->image->upload_image($picture, $picture['name'], $this->slides->setting("dir_images")))
							{
								$image_id = $this->slides->add_image($slide_id, $image_name);
								if(!$image_id) {
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
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список страниц
				 */
				if($after_exit and count($errors)==0) {
					header("Location: ".DIR_ADMIN."?module=slides");
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $slide['id'] and $may_noupdate_form) return 1;
			}
		}

		
		if($slide_id) {
			if($from_revision) {
				$slide = $this->slides->get_from_revision($from_revision, $slide_id);
				if(isset($slide['img']) and $slide['img']!='') {
					if(!file_exists(ROOT_DIR_IMAGES.$this->slides->setting("dir_images")."normal/".$slide['img'])) $slide['img'] = "";
				}
			}
			else {
				$slide = $this->slides->get_slide($slide_id);
			}
			if(count($slide)==0) {
				header("Location: ".DIR_ADMIN."?module=slides");
				exit();
			}
			$list_revisions = $this->slides->get_list_revisions($slide_id);
		}
		else {
			$slide['sort'] = $this->slides->get_new_slide_sort();
			$list_revisions = array();
		}
		
		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('slide', $slide);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('list_revisions', $list_revisions);
		$this->tpl->add_var('from_revision', $from_revision);
		$this->tpl->add_var('content_photos_for_id', $slide_id);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->slides->setting("dir_images"));
		return $this->tpl->fetch('slides_add');
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
		$this->admins->check_access_module('slides', 2);
	
		$id = $this->request->get("id", "integer");
		if($id>0) $this->slides->delete($id);
		return $this->index();
	}
	
	/**
	 * создает дубликат страницы
	 * @return string
	 */
	public function duplicate() {
		$this->admins->check_access_module('slides', 2);
		$id = $this->request->get("id", "integer");
		if($id>0) $this->slides->duplicate($id);
		return $this->index();
	}
}