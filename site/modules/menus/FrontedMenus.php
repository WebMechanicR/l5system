<?php
/**
 * класс отображения текстовых страниц в пользовательской части сайта
 * @author riol
 *
 */

class FrontedPages extends View {
	public function index() {
		$page_url = $this->request->get('page_url', 'string');

		if(empty($page_url)) return false;

		$cache_key = "page_".$page_url;
		if (false === ($page_t = $this->cache->get($cache_key))) {
			if($page_t = $this->pages->get_page($page_url) and $page_t['enabled']) {
				$page_t['images'] = $this->pages->get_images($page_t['id']);
			}
			else return false;
			$this->cache->set($page_t, $cache_key, array("page"));
		}

		$this->set_meta_title( ($page_t['meta_title']!='' ? $page_t['meta_title'] : $page_t['title']) );
		$this->set_meta_description($page_t['meta_description']);
		$this->set_meta_keywords($page_t['meta_keywords']);

		if($page_t['topage']!="") {
			header("Location: ".$page_t['topage']);
			exit;
		}
		elseif($page_t['nohead']) {
			$this->wraps_off();
			return $page_t['body'];
		}
		else {
			$this->tpl->add_var('page_t', $page_t);
			$this->tpl->add_var('pages_photos_dir', SITE_URL.URL_IMAGES.$this->pages->setting("dir_images"));
			
			$template = "page";
			if($page_t['template']!="") $template = "page_".$page_t['template'];
			
			return $this->tpl->fetch($template);
		}
	}
}