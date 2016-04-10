<?php

class FrontedSearch extends View {
	public function index() {
                $type_search = "catalog";
		$q = $this->request->get('q', 'string');
		//убираем все символы кроме букв, цифр и дефисов
		$q = preg_replace('/[^0-9a-zа-я-]/uis', " ", $q);
		$q = mb_substr($q, 0, 100); //обрезаем запрос до 100 знаков
                
		if(mb_strlen($q)<3) {//поиск делаем по строке от 3-х знаков
			header("Location: ".SITE_URL);
			exit();
		}
                
		$ar_query = $this->search->prepareQuery($q);
		if(count($ar_query)<1) {
			header("Location: ".SITE_URL);
			exit();
		}

		$page_url = $this->request->get('page_url', 'string');
		$page_t = $this->pages->get_page_withcache($page_url);

		$this->set_meta_title( ($page_t['meta_title']!='' ? $page_t['meta_title'] : $page_t['title']) );
		$this->set_meta_description($page_t['meta_description']);
		$this->set_meta_keywords($page_t['meta_keywords']);

		// Постраничная навигация
		$limit = ($tempVar = intval($this->settings->limit_num))?$tempVar:20;
		// Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);

		$search_full_link = $this->pages->get_full_link_module('search').'/';

		$page_link = $search_full_link."?q=".urlencode($q)."&type_search=".$type_search;
		$paging_url = $search_full_link."?p=%p%&q=".urlencode($q)."&type_search=".$type_search;

		switch($type_search) {
			case "catalog":
				$pr_ids = $this->catalog->searchProducts($q, $ar_query);

				$added_cache_key = "";
				
				$filter = array("enabled"=> 1, "no_modif"=>1, "limit" => array($p, $limit));
				
				$filter["in_ids"] = $pr_ids;

				$products_count = count($pr_ids);

				$total_pages_num = ceil($products_count/$limit);

				$cache_key = "search_products_ids".implode(".", $pr_ids)."_p".$p.$added_cache_key;
				//$this->cache->delete($cache_key);
				if($products_count==0) $list_products = array();
				elseif (false === ($list_products = $this->cache->get($cache_key))) {
					$filter["sort"] = array("find_in_set", "");
					$list_products = $this->catalog->get_list_products( $filter );

					$cache_tags = array("catalog", "list_products");

					if($list_products) {
						foreach($list_products as $product){
							$cache_tags[] = "productid_".$product['id'];
						}
					}
					$this->cache->set($list_products, $cache_key, $cache_tags);
				}

				$this->tpl->add_var('list_products', $list_products);
				$this->tpl->add_var('products_count', $products_count);
                                $this->tpl->add_var('catalog_full_link', $this->pages->get_full_link_module('catalog'));
                                $this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->catalog->setting('dir_images'));
				break;
                }

                $this->tpl->add_var('type_search', $type_search);
		$this->tpl->add_var('page_t', $page_t);
		$this->tpl->add_var('q', $q);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_url', $paging_url);
		$this->tpl->add_var('page_link', $page_link);
		return $this->tpl->fetch('search');
        }
}
?>