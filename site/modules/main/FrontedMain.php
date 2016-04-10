<?php
/**
 * класс отображения главной страницы сайта
 * @author riol
 *
 */

class FrontedMain extends View {
	public function index() {
		$cache_key = "list_slides";
		if(false === ($list_slides = $this->cache->get($cache_key))){
			$list_slides = $this->slides->get_list_slides(array('enabled' => 1));
			$this->cache->set($list_slides, $cache_key);
		}
		 
		$cache_key = "block1_on_main_page";
		$cache_tags = array('products', 'list_products');
		$block1 = array();
		if($this->settings->name_of_mainpage_block1)
			if(false === ($block1 = $this->cache->get($cache_key))){
			$block1 = $this->catalog->get_list_products(array('enabled' => 1, 'show_in_block1' => 1, 'limit' => array(1, 15)));
			if($block1)
				foreach($block1 as $item)
				$cache_tags[] = 'productid_'.$item['id'];
			$this->cache->set($block1, $cache_key, $cache_tags);
		}
		
		$cache_key = "block2_on_main_page";
		$cache_tags = array('products', 'list_products');
		$block2 = array();
		if($this->settings->name_of_mainpage_block2)
			if(false === ($block2 = $this->cache->get($cache_key))){
			$block2 = $this->catalog->get_list_products(array('enabled' => 1, 'show_in_block2' => 1, 'limit' => array(1, 15)));
			if($block2)
				foreach($block2 as $item)
				$cache_tags[] = 'productid_'.$item['id'];
			$this->cache->set($block2, $cache_key, $cache_tags);
		}


		$this->tpl->add_var('block1', $block1);
		$this->tpl->add_var('block2', $block2);
		$this->tpl->add_var('list_slides', $list_slides);

		return $this->tpl->fetch('main');
	}
}