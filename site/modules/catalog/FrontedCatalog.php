<?php
/**
 * класс отображения каталога в пользовательской части сайта
 * @author riol
 *
 */

class FrontedCatalog extends View {
	public function index() {
		$page_url = $this->request->get('page_url', 'string');
		$page_t = $this->pages->get_page_withcache($page_url);

		$url = trim($this->request->get('url', 'string'), "/");

		$tree_categories = $this->catalog->get_tree_categories();
		$catalog_full_link = $this->pages->get_full_link_module("catalog");

		$filter = array("enabled"=> 1);
		$page_link = $catalog_full_link."/";

		$added_cache_key = "";
		$catalog_page = false;
		if($url!=''){
			$cache_key = "category_".$url;
			if (false === ($category = $this->cache->get($cache_key))) {
				if($category = $this->catalog->get_category($url) and $category['enabled']);
				else return false;

				$cache_tags = array("catalog", "categoryid_".$category['id']);
				$this->cache->set($category, $cache_key, $cache_tags);
			}

			$this->set_meta_title(($category['meta_title']!='' ? $category['meta_title'] : $category['title']));
			$this->set_meta_description($category['meta_description']);
			$this->set_meta_keywords($category['meta_keywords']);
				
			if(!isset($_SESSION['categories_viewed']) or in_array($category['id'], $_SESSION['categories_viewed']) === false) {
				$this->catalog->add_view_category($category['id']);
				$_SESSION['categories_viewed'][] = $category['id'];
			}
				
			$ar_categs = $this->catalog->get_sub_categs($category['id']);
			$ar_categs[] = $category['id'];
				
			$filter["category_id"] = $ar_categs;
				
			$page_link .= $category['full_link']."/";
				
			$added_cache_key .= "_categoryid_".$category['id'];
			$catalog_page = true;
			$this->tpl->add_var('category', $category);
		}
		else {
			$this->set_meta_title( ($page_t['meta_title']!='' ? $page_t['meta_title'] : $page_t['title']) );
			$this->set_meta_description($page_t['meta_description']);
			$this->set_meta_keywords($page_t['meta_keywords']);
		}


		if($catalog_page){
			// Постраничная навигация
			$limit = intval($this->settings->limit_num);
			// Текущая страница в постраничном выводе
			$p = $this->request->get('p', 'integer');
			// Если не задана, то равна 1
			$p = max(1, $p);

			$filter["limit"] = array($p, $limit);

			$paging_url = $page_link."index_%p%.htm";

			$cache_key = "count_categ_products".$added_cache_key;
			if (false === ($products_count = $this->cache->get($cache_key))) {
				// Вычисляем количество страниц
				$products_count = intval($this->catalog->get_count_products($filter));
				$cache_tags = array("catalog", "list_products");
				if(isset($category)) $cache_tags[] = "products_categoryid_".$category['id'];
				if(isset($pr_ids) and is_array($pr_ids)) {
					foreach($pr_ids as $id) $cache_tags[] = "productid_".$id;
				}
				$this->cache->set($products_count, $cache_key, $cache_tags);
			}
			$total_pages_num = ceil($products_count/$limit);

			$cache_key = "categ_products".$added_cache_key."_p".$p;
			if (false === ($list_categ_products = $this->cache->get($cache_key))) {
				$list_categ_products = $this->catalog->get_list_products($filter);

				$cache_tags = array("catalog", "list_products");
				if(isset($category)) $cache_tags[] = "products_categoryid_".$category['id'];

				if($list_categ_products){
					$ar_products = array();
					foreach($list_categ_products as $product){
						$cache_tags[] = "productid_".$product['id'];
					}
				}
				$this->cache->set($list_categ_products, $cache_key, $cache_tags);
			}


			$this->tpl->add_var('list_categ_products', $list_categ_products);
			$this->tpl->add_var('products_count', $products_count);
			$this->tpl->add_var('total_pages_num', $total_pages_num);
			$this->tpl->add_var('p', $p);
			$this->tpl->add_var('page_link', $page_link);
			$this->tpl->add_var('paging_url', $paging_url);
		}
		else{
			$prices = array();
			$cache_key = 'minimal_prices';
			$cache_tags = array('products', 'list_products');
			if(false === ($prices = $this->cache->get($cache_key))){
				$prices = $this->catalog->get_minimal_prices();
				if($prices)
					foreach($prices as $item)
					$cache_tags[] = 'productid_'.$item['id'];
				$this->cache->set($prices, $cache_key, $cache_tags);
			}
			 
			$this->tpl->add_var('prices', $prices);
		}
		$this->tpl->add_var('content_photos_dir', SITE_URL . URL_IMAGES . $this->catalog->setting("dir_images"));
		$this->tpl->add_var('catalog_full_link', $catalog_full_link);
		return $this->tpl->fetch("catalog_category_products");
	}


	public function show_product() {

		$url = trim($this->request->get('url', 'string'), "/");
		$url_category = trim($this->request->get('url_category', 'string'), "/");

		if(empty($url) or empty($url_category)) return false;

		$tree_categories = $this->catalog->get_tree_categories();

		$cache_key = "category_".$url_category;
		if (false === ($category = $this->cache->get($cache_key))) {
			if($category = $this->catalog->get_category($url_category) and $category['enabled']);
			else return false;

			$cache_tags = array("catalog", "categoryid_".$category['id']);

			$this->cache->set($category, $cache_key, $cache_tags);
		}

		$cache_key = "product_".$url;
		if (false === ($product = $this->cache->get($cache_key))) {
			if($product = $this->catalog->get_product($url) and $product['enabled']);
			else return false;

			$cache_tags = array("catalog", "productid_".$product['id']);

			$product['images'] = $this->catalog->get_images($product['id']);
			$product['files'] = $this->catalog->get_files($product['id']);
			$this->cache->set($product, $cache_key, $cache_tags);
		}

		if($product['meta_title']=='') $product['meta_title'] = ($product['name_full']!='' ? F::ucfirst($product['name_full'])." " : "").$product['name'];

		$this->set_meta_title($product['meta_title']);
		$this->set_meta_description($product['meta_description']);
		$this->set_meta_keywords($product['meta_keywords']);

		if(!isset($_SESSION['products_viewed']) or in_array($product['id'], $_SESSION['products_viewed']) === false) {
			$this->catalog->add_view_product($product['id']);
			$_SESSION['products_viewed'][] = $product['id'];
		}

		$cache_key = "recomenduem_product_list_".$product['id'];
		$recomenduem_list_products = array();
		if (false === ($recomenduem_list_products = $this->cache->get($cache_key))) {
			$filter = array("enabled"=> 1, "category_id"=>$category['id'], "not_id"=>$product['id'], "limit"=>array(1, 4));

			$recomenduem_list_products = $this->catalog->get_list_products( $filter );
			$cache_tags = array("catalog", "list_products", "products_categoryid_".$category['id']);
			if($recomenduem_list_products) {
				foreach($recomenduem_list_products as $t_product){
					$cache_tags[] = "productid_".$t_product['id'];
				}
			}
			$this->cache->set($recomenduem_list_products, $cache_key, $cache_tags);
		}

		$cache_key = "related_products_of_".$product['id'];
		$related_products = array();
		if($this->settings->name_of_related_products){
			if(false === ($related_products = $this->cache->get($cache_key))) {
				$related_products = $this->catalog->get_related_products($product['id'], 0, array("enabled"=>1));
				$cache_tags = array("catalog", "list_products", "products_categoryid_".$category['id']);
				if($related_products)
					foreach($related_products as $related_product) {
					$cache_tags[] = "productid_".$related_product['id'];
				}
				$this->cache->set($related_products, $cache_key, $cache_tags);
			}
		}

		$catalog_full_link = $this->pages->get_full_link_module("catalog");

		$this->tpl->add_var('product', $product);
		$this->tpl->add_var('category', $category);
		$this->tpl->add_var('recomenduem_list_products', $recomenduem_list_products);
		$this->tpl->add_var('related_products', $related_products);
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->catalog->setting("dir_images"));
		$this->tpl->add_var('products_files_dir', SITE_URL.URL_FILES.$this->catalog->setting("dir_files"));
		$this->tpl->add_var('catalog_full_link', $catalog_full_link);

		$template = "catalog_show_product";
		return $this->tpl->fetch($template);
	}
}