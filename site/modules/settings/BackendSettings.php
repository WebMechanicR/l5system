<?php
/**
 * класс отображения настроек в административной части сайта
 * @author riol
 */

class BackendSettings extends View {
	public function index() {
		$this->admins->check_access_module('settings', 2);
		
		$method = $this->request->method();
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";

		$may_noupdate_form = true;
		$errors = array();

                $admin_info = $this->admins->get_admin_info();
                
		if($this->request->method('post') && !empty($_POST) && $this->request->post('settings_flag', 'integer')) {
			$settings = array();
			$settings['site_title'] = $this->request->post('site_title', 'string');
			$settings['site_brief_description'] = $this->request->post('site_brief_description', 'string');
			$settings['site_description'] = $this->request->post('site_description', 'string');
			$settings['description_on_main'] = $this->request->post('description_on_main');
			$settings['text_sidebar'] = $this->request->post('text_sidebar');
			$settings['meta_title'] = $this->request->post('meta_title', 'string');
			$settings['meta_description'] = $this->request->post('meta_description');
			$settings['meta_keywords'] = $this->request->post('meta_keywords');
			$settings['counters_code'] = $this->request->post('counters_code');
			$settings['site_email'] = $this->request->post('site_email', 'string');
			$settings['site_phone'] = $this->request->post('site_phone', 'string');
			$settings['vk_link'] = F::url($this->request->post('vk_link', 'string'));
			$settings['facebook_link'] = F::url($this->request->post('facebook_link', 'string'));
			$settings['google_link'] = F::url($this->request->post('google_link', 'string'));
			$settings['twitter_link'] = F::url($this->request->post('twitter_link', 'string'));
			$settings['name_of_mainpage_block1'] = $this->request->post('name_of_mainpage_block1', 'string');
			$settings['name_of_mainpage_block2'] = $this->request->post('name_of_mainpage_block2', 'string');
			$settings['name_of_related_products'] = $this->request->post('name_of_related_products', 'string');
			$settings['name_of_other_products'] = $this->request->post('name_of_other_products', 'string');
			$settings['limit_num'] = $this->request->post('limit_num', 'integer');
			$settings['limit_admin_num'] = $this->request->post('limit_admin_num', 'integer');
			$settings['admin_num_links'] = $this->request->post('admin_num_links', 'integer');
			$settings['num_links'] = $this->request->post('num_links', 'integer');
			
			$settings['slide_delay'] = $this->request->post('slide_delay', 'integer');
			$settings['bg_type_size'] = $this->request->post('bg_type_size', 'integer');
			$settings['bg_type_scroll'] = $this->request->post('bg_type_scroll', 'integer');
			$settings['off_news'] = $this->request->post('off_news', 'integer');
			
			$settings['head_code'] = $this->request->post('head_code');
			$settings['body_top_code'] = $this->request->post('body_top_code');
			$settings['widget_code1'] = $this->request->post('widget_code1');
			$settings['widget_code2'] = $this->request->post('widget_code2');
			$settings['widget_code3'] = $this->request->post('widget_code3');

			$settings['color_theme'] = $this->request->post('color_theme', 'string');
			
			//Watermark
			if($picture = $this->request->files('picture'))
			{
				if(isset($picture['error']) and $picture['error']!=0) {
					$errors['watermark'] = 'error_size';
					$tab_active = "images";
				}
				else {
					if($image_name = $this->image->upload_image($picture, 'watermark.'.pathinfo($picture['name'], PATHINFO_EXTENSION), 'img/'))
					{
						$errFlag = false;
						if(!$this->image->create_image(ROOT_DIR_IMAGES.'img/original/'.$image_name, ROOT_DIR_IMAGES."img/big/".$image_name, array(300, 1000, false, false))) $errFlag = true;

						if($errFlag) {
							$errors['watermark'] = 'error_internal';
							$tab_active = "images";
						}
						else{
							if($this->settings->site_watermark) {
								@unlink(ROOT_DIR_IMAGES."img/original/".$this->settings->site_watermark);
								@unlink(ROOT_DIR_IMAGES."img/big/".$this->settings->site_watermark);
							}
							$settings['site_watermark'] = $image_name;
						}
					}
					else
					{
						if($image_name===false) $errors['watermark'] = 'error_type';
						else $errors['watermark'] = 'error_upload';
						$tab_active = "images";
					}
				}
				$may_noupdate_form = false;
			}

			//Background
			if($picture = $this->request->files('picture_background'))
			{
				if(isset($picture['error']) and $picture['error']!=0) {
					$errors['background'] = 'error_size';
					$tab_active = "images";
				}
				else {
					if($image_name = $this->image->upload_image($picture, $picture['name'], 'img/'))
					{
						$errFlag = false;
						if(!$this->image->create_image(ROOT_DIR_IMAGES.'img/original/'.$image_name, ROOT_DIR_IMAGES."img/big/".$image_name, array(10000, 10000, false, false))) $errFlag = true;
						@unlink(ROOT_DIR_IMAGES."img/original/".$image_name);

						if($errFlag){
							$errors['background'] = 'error_internal';
							$tab_active = "images";
						}
						else{
							if($this->settings->site_background) @unlink(ROOT_DIR_IMAGES."img/original/".$this->settings->site_background);
							$settings['site_background'] = $image_name;
						}
					}
					else
					{
						if($image_name===false) $errors['background'] = 'error_type';
						else $errors['background'] = 'error_upload';
						$tab_active = "images";
					}
				}
				$may_noupdate_form = false;
			}
			
			//Logo
			if($picture = $this->request->files('picture_logo'))
			{
				if(isset($picture['error']) and $picture['error']!=0) {
					$errors['logo'] = 'error_size';
					$tab_active = "images";
				}
				else {
					if($image_name = $this->image->upload_image($picture, $picture['name'], 'img/'))
					{
						$errFlag = false;
						if(!$this->image->create_image(ROOT_DIR_IMAGES.'img/original/'.$image_name, ROOT_DIR_IMAGES."img/big/".$image_name, array(303, 100, false, false))) $errFlag = true;
						@unlink(ROOT_DIR_IMAGES."img/original/".$image_name);
			
						if($errFlag){
							$errors['logo'] = 'error_internal';
							$tab_active = "images";
						}
						else{
							if($this->settings->site_logo) @unlink(ROOT_DIR_IMAGES."img/original/".$this->settings->site_logo);
							$settings['site_logo'] = $image_name;
						}
					}
					else
					{
						if($image_name===false) $errors['logo'] = 'error_type';
						else $errors['logo'] = 'error_upload';
						$tab_active = "images";
					}
				}
				$may_noupdate_form = false;
			}
			
			// Favicon
			if($file = $this->request->files('favicon'))
			{
				if(isset($file['error']) and $file['error']!=0) {
					$errors['favicon'] = 'error_size';
					$tab_active = "images";
				}
				elseif(pathinfo($file['name'], PATHINFO_EXTENSION)!='ico') {
					$errors['favicon'] = 'error_type';
				}
				else {
					if($this->settings->favicon!='') {
						@unlink(ROOT_DIR_FILES.$this->settings->favicon);
					}
					if ($file_name = $this->file->upload_file($file, "favicon.ico", ""))
					{
						$settings['favicon'] = "favicon.ico";
					}
					else
					{
						if($file_name===false) $errors['favicon'] = 'error_type';
						else $errors['favicon'] = 'error_upload';
						$tab_active = "images";
					}
				}
				$may_noupdate_form = false;
			}

			//при изменении количества записей на странице очищаем кеш у списковых данных
			if($settings['limit_num']!=$this->settings->limit_num) {
				$this->cache->clean(array("list_news", "list_products"));
			}

			$this->settings->update_settings($settings);

			/**
			 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
			*/
			if($this->request->isAJAX() and $may_noupdate_form) return 1;
		}
                
                $this->tpl->add_var('admin_info', $admin_info);
		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('tab_active', $tab_active);
		return $this->tpl->fetch('settings');
	}
}