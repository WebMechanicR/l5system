<?php
/**
 * класс отображения заказов в административной части сайта
 * @author riol
 *
 */

class BackendOrders extends View {
	public function index() {
		$this->admins->check_access_module('orders');

		$sort_by = $this->request->get("sort_by", "string");
		$sort_dir = $this->request->get("sort_dir", "string");
		$status = $this->request->get("status", "integer");
		$order_id = $this->request->get("order_id", "integer");
		$order_name = $this->request->get("order_name", "string");
		$date_to = intval(strtotime($this->request->get('date_to', 'string')));
		$date_from = intval(strtotime($this->request->get('date_from', 'string')));
                
		
		if(!isset($_GET['status'])) $status = -1;

		if(!$sort_by or !in_array($sort_by, array("id", "name", "date_add", "status", "total_price")) ) $sort_by = "id";
		if(!$sort_dir or !in_array($sort_dir, array("asc", "desc")) ) $sort_dir = "desc";


		$filtres_query = "&order_id=".$order_id."&order_name=".$order_name."&status=".$status;
		$paging_added_query = "&action=index&sort_by=".$sort_by."&sort_dir=".$sort_dir.$filtres_query;
		$link_added_query = "&sort_by=".$sort_by."&sort_dir=".$sort_dir;


		// Постраничная навигация
		$limit = intval($this->settings->limit_admin_num);
		// Текущая страница в постраничном выводе
		$p = $this->request->get('p', 'integer');
		// Если не задана, то равна 1
		$p = max(1, $p);
		$link_added_query .= "&p=".$p;

		$filter = array("sort"=> array($sort_by, $sort_dir));

		$filter["limit"] = array($p, $limit);

		if($status>-1) $filter["status"] = $status;
		if($order_id) $filter["id"] = $order_id;
		if($order_name!='') $filter["name"] = $order_name;
		if($date_to or $date_from)
		{
			$filter['date_to'] = $date_to;
			$filter['date_from'] = $date_from;
		}
                

		// Вычисляем количество страниц
		$orders_count = intval($this->orders->get_count_orders($filter));
		$total_pages_num = ceil($orders_count/$limit);


		$list_orders = $this->orders->get_list_orders( $filter );
		$this->tpl->add_var('list_orders', $list_orders);
		$this->tpl->add_var('orders_count', $orders_count);
		$this->tpl->add_var('total_pages_num', $total_pages_num);
		$this->tpl->add_var('p', $p);
		$this->tpl->add_var('sort_by', $sort_by);
		$this->tpl->add_var('sort_dir', $sort_dir);
		$this->tpl->add_var('status', $status);
		$this->tpl->add_var('order_id', $order_id);
		$this->tpl->add_var('order_name', $order_name);
		$this->tpl->add_var('paging_added_query', $paging_added_query);
		$this->tpl->add_var('link_added_query', $link_added_query);
		$this->tpl->add_var('filtres_query', $filtres_query);
		$this->tpl->add_var('date_to', $date_to);
		$this->tpl->add_var('date_from', $date_from);
		
		return $this->tpl->fetch('orders');
	}

	/**
	 * редактирование/добавлние новости
	 */
	public function edit() {
		$this->admins->check_access_module('orders', 2);

		//возможность не перезагружать форму при запросах аяксом, но если это необходимо, например, загружена картинка - обновляем форму
		$may_noupdate_form = true;

		$method = $this->request->method();
		$order_id = $this->request->$method("id", "integer");

		if($order_id==0) {
			header("Location: ".DIR_ADMIN."?module=orders");
			exit();
		}
		$order = $this->orders->get_order($order_id);
		if(count($order)==0) {
			header("Location: ".DIR_ADMIN."?module=orders");
			exit();
		}

		$tab_active = $this->request->$method("tab_active", "string");
		if(!$tab_active) $tab_active = "main";

		/**
		 * ошибки при заполнении формы
		 */
		$errors = array();



		if($this->request->method('post') && !empty($_POST)) {
			$order['name'] = $this->request->post('name', 'string');
			$order['email'] = $this->request->post('email', 'string');
			$order['phone'] = $this->request->post('phone', 'string');
			$order['contacts'] = $this->request->post('contacts', 'string');
			
			$order['delivery_id'] = $this->request->post('delivery_id', 'integer');
			$order['payment_type_id'] = $this->request->post('payment_type_id', 'integer');
			$order['address'] = $this->request->post('address', 'string');
			//$order['comment'] = $this->request->post('comment', 'string');
			$order['admin_comment'] = $this->request->post('admin_comment', 'string');
			$order['status'] = $this->request->post('status', 'integer');
			$order['aid'] = $this->request->post('aid', 'integer');
			$order['file_invoice'] = $this->request->post('file_invoice', 'string');
			$products = $this->request->post('products', 'array');
			$products_new = $this->request->post('products_new', 'array');
                        
			$after_exit = $this->request->post('after_exit', "boolean");

			if(empty($order['name'])) $errors['name'] = 'no_name';

			if(empty($order['email'])) $errors['email'] = 'no_email';
			elseif(!F::is_email($order['email'])) $errors['email'] = 'err_email';

			if(empty($order['phone'])) $errors['phone'] = 'no_phone';
			if($order['delivery_id']==0) $errors['delivery'] = 'no_delivery';
			if($order['payment_type_id']==0) $errors['payment_type'] = 'no_payment_type';
                        
			if(empty($order['address'])) $errors['address'] = 'no_address';


			if(count($errors)==0) {
                                $order['amount'] = 0;
				$order['total_price'] = 0;
                                $old_status = 0;
                                $old_order = $this->orders->get_order($order_id);
                                if($old_order)
                                    $old_status = $old_status['status'];
                                //обновляем товары заказа
				$this->orders->delete_order_product_all($order_id);
				foreach($products as $tl_product) {
					$tl_product['price'] = floatval($tl_product['price']);
					$product = array(
							"order_id"=>$order_id,
							"product_id"=>$tl_product['id'],
							"price"=>$tl_product['price'],
							"amount"=>$tl_product['amount']
					);
					$order['amount'] += $tl_product['amount'];
					$order['total_price'] += $tl_product['price']*$tl_product['amount'];

					$this->orders->add_order_product($product);
				}
                                
                                //добавляем новые товары к заказу
				if(is_array($products_new)) {
					foreach($products_new as $tl_product) {
						$tl_product['price'] = floatval($tl_product['price']);
						$product = array(
								"order_id"=>$order_id,
								"product_id"=>$tl_product['id'],
								"price"=>$tl_product['price'],
								"amount"=>$tl_product['amount']
						);
						$order['amount'] += $tl_product['amount'];
						$order['total_price'] += $tl_product['price']*$tl_product['amount'];
						$this->orders->add_order_product($product);
					}
					$may_noupdate_form = false;
				}
				$this->orders->update($order_id, $order);
				// Загрузка файлов
				if($file = $this->request->files('file'))
				{
					if(isset($file['error']) and $file['error']!=0) {
						$errors['file'] = 'error_size';
						$tab_active = "main";
					}
					else {
						if ($file_name = $this->file->upload_file($file, $file['name'], $this->orders->setting("dir_files_invoices")))
						{
							$file_id = $this->orders->add_file($order_id, $file_name);
							if(!$file_id) {
								$errors['file'] = 'error_internal';
								$tab_active = "main";
							}
							else $order['file_invoice'] = $file_name;
						}
						else
						{
							if($file_name===false) $errors['file'] = 'error_type';
							else $errors['file'] = 'error_upload';
							$tab_active = "main";
						}
					}
					$may_noupdate_form = false;
				}
                                
                                //при изменении статуса, ставим дату изменения статуса у заказа и отправляем пользователю писмьмо о новом статусе заказа.
				if($order['status']!=$old_status) {
					
					$order_products = $this->orders->get_order_products($order_id);
					$deliveries = $this->catalog->get_list_deliveries();
					$payment_types = $this->catalog->get_list_payment_types();
					$catalog_full_link = $this->pages->get_full_link_module("catalog");
					$tree_categories = $this->catalog->get_tree_categories();
					
					$this->tpl->add_var('order', $order);
					$this->tpl->add_var('order_products', $order_products);
					$this->tpl->add_var('deliveries', $deliveries);
					$this->tpl->add_var('payment_types', $payment_types);
					$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->catalog->setting("dir_images"));
					$this->tpl->add_var('catalog_full_link', $catalog_full_link);
					$this->tpl->add_var('tree_categories', $tree_categories);
                                        $this->tpl->add_var('order_statuses', $CONFIG['order_statuses']);
					
					$this->tpl->in_user();
					$html_mail_user = $this->tpl->fetch("mail/orders_new_status_user");
					$this->mail->send_mail(array($order['email'], $order['name']), "Обновление статуса заказа на ".$this->settings->site_title, $html_mail_user);
					$this->tpl->in_admin();
				}

				/**
				 * если было нажата кнопка Сохранить и выйти, перекидываем на список страниц
				 */
				if($after_exit and count($errors)==0) {
					header("Location: ".DIR_ADMIN."?module=orders");
					exit();
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				elseif($this->request->isAJAX() and count($errors)==0 and $order['id'] and $may_noupdate_form) return 1;
			}
		}


		$order_products = $this->orders->get_order_products($order_id);
		$deliveries = $this->catalog->get_list_deliveries();
		$payment_types = $this->catalog->get_list_payment_types();
		$admins = $this->admins->get_admins();
		
		$this->tpl->add_var('list_admins', $admins);
		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('order', $order);
		$this->tpl->add_var('tab_active', $tab_active);
		$this->tpl->add_var('order_products', $order_products);
		$this->tpl->add_var('deliveries', $deliveries);
		$this->tpl->add_var('payment_types', $payment_types);
		$this->tpl->add_var('content_files_dir', SITE_URL.URL_FILES.$this->orders->setting("dir_files"));
		$this->tpl->add_var('invoices_files_dir', SITE_URL.URL_FILES.$this->orders->setting("dir_files_invoices"));
		$this->tpl->add_var('content_photos_dir', SITE_URL.URL_IMAGES.$this->catalog->setting("dir_images"));
		
		$print = $this->request->$method("print", "integer");
		if($print) {
			$this->wraps_off();
			return $this->tpl->fetch('orders_order_print');
		}
		else return $this->tpl->fetch('orders_edit');
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
		$this->admins->check_access_module('orders', 2);

		$id = $this->request->get("id", "integer");
		if($id>0) $this->orders->delete($id);
		return $this->index();
	}

	/**
	 * действия с группами страниц
	 */
	public function group_actions() {
		$this->admins->check_access_module('orders', 2);
		$items = $this->request->post("check_item", "array");
		if(is_array($items) and count($items)>0) {
			$items = array_map("intval", $items);
			switch($this->request->post("do_active", "string")) {
				case "delete":
					foreach($items as $id) {
						if($id>0) $this->orders->delete($id);
					}
					break;
				case "export1c":
					if($data = $this->orders->exportTo1C($items))
						$this->sendExportData($data);
				break;
			}
		}
		else if($this->request->post("do_active", "string") == 'export1c')
			if($data = $this->orders->exportTo1C())
				$this->sendExportData($data);

		return $this->index();
	}
	
	public function sendExportData($data)
	{
		define("FLASH_OFF_DEBUG", true);

        $this->wraps_off();
		$this->add_header("Content-Description: File Transfer\r\n");
		$this->add_header("Pragma: public\r\n");
		$this->add_header("Expires: 0\r\n");
		$this->add_header("Cache-Control: must-revalidate, post-check=0, pre-check=0\r\n");
		$this->add_header("Cache-Control: public\r\n");
		$this->add_header("Content-Type: text/xml;\r\n");
		$this->add_header("Content-Disposition: attachment; filename=\"orders.xml\"\r\n");
		
		echo htmlspecialchars($data);
		exit;
	}
}