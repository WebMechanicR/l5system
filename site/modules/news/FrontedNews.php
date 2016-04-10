<?php
/**
 * класс отображения новостей в пользовательской части сайта
 * @author riol
 *
 */

class FrontedNews extends View {
	public function index() {
		$news_full_link = $this->pages->get_full_link_module("news");

		$page_url = $this->request->get('page_url', 'string');
		$page_t = $this->pages->get_page_withcache($page_url);

		$this->set_meta_title( ($page_t['meta_title']!='' ? $page_t['meta_title'] : $page_t['title']) );
		$this->set_meta_description($page_t['meta_description']);
		$this->set_meta_keywords($page_t['meta_keywords']);

		$this->tpl->add_var('page_t', $page_t);

		$year = $this->request->get("year", "string");
		$month = $this->request->get("month", "string");

		$added_cache = "";

		// Постраничная навигация
		$limit = intval($this->settings->limit_num);
		// Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);

		$filter = array("enabled"=>1, "limit" => array($p, $limit));

		if($year) {
			$filter['year'] = $year;
			$news_full_link .= "/".$year;
			$added_cache .= "_year".$year;
		}
		if($month) {
			$filter['month'] = $month;
			$news_full_link .= "/".$month;
			$added_cache .= "_month".$month;
		}

		$paging_url = $news_full_link."/index_%p%.htm";


		$cache_key = "news_count".$added_cache;
		if (false === ($news_count = $this->cache->get($cache_key))) {
			// Вычисляем количество страниц
			$news_count = intval($this->news->get_count_news($filter));
			$cache_tags = array("news", "list_news");
			$this->cache->set($news_count, $cache_key, $cache_tags);
		}
		$total_pages_num = ceil($news_count/$limit);

		$cache_key = "list_news".$added_cache."_p".$p;
		if (false === ($list_news = $this->cache->get($cache_key))) {
			$list_news = $this->news->get_list_news( $filter );

			$cache_tags = array("news", "list_news");
			if($list_news) {
				foreach($list_news as $news){
					$cache_tags[] = "newsid_".$news['id'];
				}
			}
			$this->cache->set($list_news, $cache_key, $cache_tags);
		}

		$cache_key = "year_news";
		if (false === ($years_news = $this->cache->get($cache_key))) {
			$years_news = $this->news->get_years();
			$cache_tags = array("news", "list_news");
			$this->cache->set($years_news, $cache_key, $cache_tags);
		}
		if($year<1 and $years_news) $year = $years_news[0];
		
		$cache_key = "month_news_year".$year;
		if (false === ($monthes_news = $this->cache->get($cache_key))) {
			$monthes_news = $this->news->get_monthes($year);
			$cache_tags = array("news", "list_news");
			$this->cache->set($monthes_news, $cache_key, $cache_tags);
		}
		

		$this->tpl->add_var('list_news', $list_news);
		$this->tpl->add_var('years_news', $years_news);
		$this->tpl->add_var('monthes_news', $monthes_news);
		$this->tpl->add_var('year', $year);
		$this->tpl->add_var('month', $month);
		$this->tpl->add_var('news_count', $news_count);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_url', $paging_url);
		$this->tpl->add_var('news_photos_dir', SITE_URL.URL_IMAGES.$this->news->setting("dir_images"));

		return $this->tpl->fetch("news");
	}

	public function show_news() {
		$url = $this->request->get('url', 'string');

		if(empty($url)) return false;

		$cache_key = "news_".$url;
		if (false === ($news = $this->cache->get($cache_key))) {
			if($news = $this->news->get_news($url) and $news['enabled']) {
				$news['images'] = $this->news->get_images($news['id']);
			}
			else return false;
			$this->cache->set($news, $cache_key, array("news"));
		}

		$this->set_meta_title( ($news['meta_title']!='' ? $news['meta_title'] : $news['title']) );
		$this->set_meta_description($news['meta_description']);
		$this->set_meta_keywords($news['meta_keywords']);
		
		$year = $news['year'];
		$month = $news['month'];
		
		$cache_key = "year_news";
		if (false === ($years_news = $this->cache->get($cache_key))) {
			$years_news = $this->news->get_years();
			$cache_tags = array("news", "list_news");
			$this->cache->set($years_news, $cache_key, $cache_tags);
		}
		if($year<1 and $years_news) $year = $years_news[0];
		
		$cache_key = "month_news_year".$year;
		if (false === ($monthes_news = $this->cache->get($cache_key))) {
			$monthes_news = $this->news->get_monthes($year);
			$cache_tags = array("news", "list_news");
			$this->cache->set($monthes_news, $cache_key, $cache_tags);
		}
		
		$cache_key = "last_news_notid_".$news['id'];
		if (false === ($list_news = $this->cache->get($cache_key))) {
			$filter = array("enabled"=> 1, "notid"=>$news['id']);
			$filter["limit"] = array(1, 2);
			$list_news = $this->news->get_list_news( $filter );
			$cache_tags = array("news", "list_news");
			if($list_news) {
				foreach($list_news as $t_news){
					$cache_tags[] = "newsid_".$t_news['id'];
				}
			}
			$this->cache->set($list_news, $cache_key, $cache_tags);
		}

		$this->tpl->add_var('news', $news);
		$this->tpl->add_var('list_news', $list_news);
		$this->tpl->add_var('years_news', $years_news);
		$this->tpl->add_var('monthes_news', $monthes_news);
		$this->tpl->add_var('year', $year);
		$this->tpl->add_var('month', $month);
		$this->tpl->add_var('news_photos_dir', SITE_URL.URL_IMAGES.$this->news->setting("dir_images"));

		return $this->tpl->fetch("news_show");

	}
}