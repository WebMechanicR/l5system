<?php
/**
 * класс отображения слайд-шоу в административной части сайта
 * @author riol
 *
 */

class BackendEconomic_news extends View {
	public function index() {
		$this->admins->check_access_module('economic_news');
                
		$sort_by = $this->request->get("sort_by", "string");
		$sort_dir = $this->request->get("sort_dir", "string");
                $name = $this->request->get("name", "string");
                
		if(!$sort_by or !in_array($sort_by, array("name", "date_add", "enabled", "num_events", 'is_approved', 'matched_with')) ) $sort_by = "";
		if(!$sort_dir or !in_array($sort_dir, array("asc", "desc")) ) $sort_dir = "";

		$paging_added_query = "&action=index&sort_by=".$sort_by."&sort_dir=".$sort_dir.'&name='.$name;
		$link_added_query = "&sort_by=".$sort_by."&sort_dir=".$sort_dir;

		// Постраничная навигация
		$limit = 30;
		//Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);
		$link_added_query .= "&p=".$p;

                if($sort_by)
                    $filter = array("sort"=> array($sort_by, $sort_dir));

		$filter["limit"] = array($p, $limit);
                
                if($name)
                    $filter['name'] = $name;
                
		//Вычисляем количество страниц
		$economic_news_count = intval($this->economic_news->get_count_calendar_news($filter));
		$total_pages_num = ceil($economic_news_count/$limit);

		$economic_news_full_link = $this->pages->get_full_link_module("economic_news");

		$list_economic_news = $this->economic_news->get_list_calendar_news( $filter );

		$this->tpl->add_var('list_economic_news', $list_economic_news);
		$this->tpl->add_var('sort_by', $sort_by);
                $this->tpl->add_var('name', $name);
		$this->tpl->add_var('sort_dir', $sort_dir);
		$this->tpl->add_var('economic_news_count', $economic_news_count);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_added_query', $paging_added_query);
		$this->tpl->add_var('link_added_query', $link_added_query);

		return $this->tpl->fetch('economic_news');
	}

	/**
	 * редактирование/добавлние новости
	 */
	public function edit() {
		$this->admins->check_access_module('economic_news', 2);

		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$economic_news_id = $this->request->$method("id", "integer");
		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";
		$from_revision = $this->request->get("from_revision", "integer");

                if($mat = $this->request->get('apply_matching', 'integer') and $economic_news_id and $economic_news = $this->economic_news->get_calendar_news($economic_news_id)){
                    $matched_with = $this->economic_news->get_calendar_news($economic_news['matched_with']);
                    if($matched_with){
                        $new_alt_names = $matched_with['alternative_names'];
                        if(!$new_alt_names)
                            $new_alt_names .= "||";
                        $new_alt_names .= ($economic_news['name']."||");
                        $this->economic_news->update_calendar_news($matched_with['id'], array('alternative_names' => $new_alt_names));
                        $this->economic_news->delete_calendar_news($economic_news['id']);
                        $remaining_events = $this->economic_news->get_list_events(array('news_id' => $economic_news['id']));
                        if($remaining_events){
                            foreach($remaining_events as $event){
                                if(!$this->economic_news->get_event($matched_with['id'], $event['moment'])){
                                    $event['news_id'] = $matched_with['id'];
                                    $this->economic_news->delete_event($event['id']);
                                    unset($event['id']);
                                    $this->economic_news->add_event($event);
                                }
                            }
                        }
                        header("Location: ".DIR_ADMIN."?module=economic_news&action=edit&id=".$matched_with['id']);
                        exit;
                    }
                }
                
                if($this->request->get('cancel_matching') and $economic_news_id and $economic_news = $this->economic_news->get_calendar_news($economic_news_id)){
                    $this->economic_news->update_calendar_news($economic_news['id'], array('matched_with' => 0));
                }
                
                
		/**
		 * ошибки при заполнении формы
		 */
		$errors = array();

		$economic_news = array("id"=>$economic_news_id, "enabled"=>1, "date_add"=>time());

		if($this->request->method('post') && !empty($_POST)) {
			$economic_news['name'] = trim($this->request->post('name', 'string'));
                        $economic_news['name_in_source'] = $this->request->post('name_in_source', 'string');
                        $economic_news['source'] = $this->request->post('source', 'string');
                        $economic_news['act_applying_method'] = $this->request->post('act_applying_method', 'string');
                        //TO DO$economic_news['matched_with'] = $this->request->post('matched_with', 'integer');
                        $economic_news['is_approved'] = $this->request->post('is_approved', 'integer');
                        $economic_news['currency'] = trim($this->request->post('currency', 'string'));
                        $economic_news['country'] = trim($this->request->post('country', 'string'));
                        $economic_news['alternative_names'] = trim($this->request->post('alternative_names', 'string'));
			$economic_news['date_add'] = strtotime($this->request->post('date', 'string'));
			$economic_news['enabled'] = $this->request->post('enabled', 'integer');
			$economic_news['body'] = $this->request->post('body');

			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($economic_news['name'])) {
				$errors['name'] = 'no_title';
				$tab_active = "main";
			}

			if(count($errors)==0) {

				if($economic_news_id) {
					$this->economic_news->update_calendar_news($economic_news_id, $economic_news);
				}
				else {
					$economic_news_id = (int)$this->economic_news->add_calendar_news($economic_news);
				}

				if($economic_news_id) {
					
				}

				/**
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список страниц
				 */
				if($after_exit and count($errors)==0) {
					header("Location: ".DIR_ADMIN."?module=economic_news");
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $economic_news['id'] and $may_noupdate_form) return 1;
			}
		}


		if($economic_news_id) {
			$economic_news = $this->economic_news->get_calendar_news($economic_news_id);
			
			if(count($economic_news)==0) {
				header("Location: ".DIR_ADMIN."?module=economic_news");
				exit();
			}
		}
		

		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('economic_news', $economic_news);
                $this->tpl->add_var('events', $economic_news_id?$this->economic_news->get_list_events(array('news_id' => $economic_news_id)):array());
		$this->tpl->add_var('tab_active', $tab_active);
		return $this->tpl->fetch('economic_news_add');
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
		$this->admins->check_access_module('economic_news', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->economic_news->delete_calendar_news($id);
		return $this->index();
	}

	/**
	 * действия с группами страниц
	 */
	public function group_actions() {
		$this->admins->check_access_module('economic_news', 2);
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "hide":
					$this->economic_news->update_calendar_news($items, array("enabled"=>0));
					break;
				case "show":
					$this->economic_news->update_calendar_news($items, array("enabled"=>1));
					break;
                                case "approve":
					$this->economic_news->update_calendar_news($items, array("is_approved"=>1));
					break;
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->economic_news->delete_calendar_news($id);
					}
					break;
			}
		}

		return $this->index();
	}
        
        public function events() {
		$this->admins->check_access_module('economic_news');
                
		$date_to = $this->request->get('date_to', 'string');
		$date_from = $this->request->get('date_from', 'string');
                $unmatched= $this->request->get('unmatched', 'integer');
                
		$paging_added_query = "&action=events&date_from=".$date_from.'&date_to='.$date_to;

		// Постраничная навигация
		$limit = 30;
		//Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);
		
		$filter["limit"] = array($p, $limit);
                
                if($date_to or $date_from)
                {
			$filter['date_to'] = strtotime($date_to);
			$filter['date_from'] = strtotime($date_from);
		}
                if($unmatched){
                    $filter['unmatched'] = 1;
                }
                
                
		//Вычисляем количество страниц
		$economic_events_count = intval($this->economic_news->get_full_count_events($filter));
		$total_pages_num = ceil($economic_events_count/$limit);

		$economic_news_full_link = $this->pages->get_full_link_module("economic_news");

		$list_events = $this->economic_news->get_full_list_events( $filter );

		$this->tpl->add_var('list_events', $list_events);
		$this->tpl->add_var('economic_events_count', $economic_events_count);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('paging_added_query', $paging_added_query);
                $this->tpl->add_var('date_to', $date_to);
                $this->tpl->add_var('date_from', $date_from);
                $this->tpl->add_var('unmatched', $unmatched);

		return $this->tpl->fetch('economic_news_events');
	}
}