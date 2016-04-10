<?php
class Orders extends Module implements IElement {

	protected $module_name = "orders";
	private $module_table = "orders";
	private $module_table_order_products = "order_products";
	private $module_nesting = false; //возможность владывать подстраницы в модуль

	private $module_settings = array(
			"dir_files" => "orders/",
			"dir_files_invoices" => "invoices/",
			"revisions_content_type" => "orders",
			"allowed_file_extentions" => array('png', 'gif', 'jpg', 'jpeg', 'bmp', 'txt', 'rtf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf', 'zip', 'rar', 'gz', 'xml', 'mxl')

	);


	/**
	 * добавляет новый элемент в базу
	*/
	public function add($order) {
		return $this->db->query("INSERT INTO ?_".$this->module_table." (?#) VALUES (?a)", array_keys($order), array_values($order));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $order) {

		if($this->db->query("UPDATE ?_".$this->module_table." SET ?a WHERE id IN (?a)", $order, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete($id) {
		if($order = $this->get_order($id)) {

			if($order['file_rekvisits']!='') {
				@unlink(ROOT_DIR_FILES.$this->setting("dir_files").$order['file_rekvisits']);
			}
			if($order['file_invoice']!='') $this->delete_file($id);

			$this->db->query("DELETE FROM ?_".$this->module_table." WHERE id=?", $id);
			$this->db->query("DELETE FROM ?_".$this->module_table_order_products." WHERE order_id=?d", $id);
		}
	}

	/**
	 * создает копию элемента
	 */
	public function duplicate($id) {
		
	}

	/**
	 * возвращает историю версий элемента
	 */
	public function get_list_revisions($for_id) {
		
	}

	/**
	 * добавляет версию элемента в историю
	 */
	public function add_revision($for_id) {
		return null;
	}

	/**
	 * возвращает данные элемента из определенной ревизии
	 */
	public function get_from_revision($id, $for_id) {
		
	}

	/**
	 * удаляет все ревизии элемента
	 */
	public function clear_revisions($for_id) {
		
	}

	/**
	 * возвращает заказа по id или url
	 * @param mixed $id
	 * @return array
	 */
	public function get_order($id) {
		return $this->db->selectRow("SELECT * FROM ?_".$this->module_table." WHERE id=?d", $id);
	}

	/**
	 * возвращает заказов удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_list_orders($filter=array()) {
		$sort_by = " ORDER BY n.id DESC";
		$limit = "";
		$where = "";
		
		if(isset($filter['sort']) and count($filter['sort'])==2) {
			if(!in_array($filter['sort'][0], array("id", "name", "date_add", "status", "total_price"))) $filter['sort'][0] = "id";
			if(!in_array($filter['sort'][1], array("asc", "desc")) ) $filter['sort'][1] = "desc";
			$sort_by = " ORDER BY n.".$filter['sort'][0]." ".$filter['sort'][1];
		}

		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}

		if(isset($filter['date_from'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add >= ".$filter['date_from'];
		}
		
		if(isset($filter['date_to']) and $filter['date_to'] > 0) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.date_add <= ".$filter['date_to'];
		}
		
		if(isset($filter['notid'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id!=".intval($filter['notid']);
		}
		
		if(isset($filter['id'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id=".intval($filter['id']);
		}
		
		if(isset($filter['status'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.status=".intval($filter['status']);
		}
                
		if(isset($filter['name']) and $filter['name']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.name LIKE '%".$filter['name']."%'";
		}
		
		return $this->db->select("SELECT n.*
				FROM ?_".$this->module_table." n".$where
				.$sort_by.$limit);
	}

	/**
	 * возвращает количество заказов удовлетворяющих фильтрам
	 * @param array $filter
	 */
	public function get_count_orders($filter=array()) {
		$where = "";
		
		if(isset($filter['id'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.id=".intval($filter['id']);
		}
		
		if(isset($filter['status'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.status=".intval($filter['status']);
		}

		if(isset($filter['name']) and $filter['name']!='') {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.name LIKE '%".$filter['name']."%'";
		}
                
		return $this->db->selectCell("SELECT count(n.id)
				FROM ?_".$this->module_table." n".$where);
	}

	/**
	 * возвращает настройку модуля
	 * @param string $id
	 * @return Ambigous <NULL, multitype:string >
	 */
	public function setting($id) {
		return (isset($this->module_settings[$id]) ? $this->module_settings[$id] : null);
	}
        
        public function delete_order_product_all($order_id) {
		return $this->db->query("DELETE FROM ?_".$this->module_table_order_products." WHERE order_id=?d", $order_id);
	}
	
	/**
	 * возвращает массив с товарами заказа
	 * @param int $id
	 */
	public function get_order_products($id) {
			$cart = array();
			$cart['products'] = array();
			
			if($shopping_cart=$this->db->select("SELECT * FROM ?_".$this->module_table_order_products." WHERE order_id=?d", $id)) {
				$pr_ids = array();
				foreach($shopping_cart as $product) {
					$pr_ids[] = $product['product_id'];
				}

				if($products = $this->catalog->get_list_products(array("in_ids"=>$pr_ids, "ARRAY_KEY"=>"pr.id"))) {
					foreach($shopping_cart as $t_product) {
						$key = $t_product['id'];
						$product = $products[$t_product['product_id']];
						$product['amount'] = $t_product['amount'];
						$product['price_order'] = $t_product['price'];
						$product['order_id'] = $t_product['order_id'];
						$cart['products'][$key] = $product;
					}
				}
			}
			return $cart;
	}
	
	/**
	 * добавляет новый товар заказа в базу
	 */
	public function add_order_product($product) {
		return $this->db->query("INSERT IGNORE INTO ?_".$this->module_table_order_products." (?#) VALUES (?a)", array_keys($product), array_values($product));
	}
	
	/**
	 * удаляет товар заказа из базы
	 */
	public function delete_order_product($order_id, $product_id) {
		return $this->db->query("DELETE FROM ?_".$this->module_table_order_products." WHERE order_id=?d AND brand_id=?d", $order_id, $product_id);
	}
	
	/**
	 * добавляет файл счета
	 * @param int $supplier_id
	 * @param string $file
	 */
	public function add_file($order_id, $file) {
		$this->update($order_id, array("file_invoice"=>$file));
		return $order_id;
	}
	
	public function delete_file($id) {
		$order = $this->get_order($id);
		if($order and $order['file_invoice']!="") {
			//проверяем, не используется ли этот файл где-то еще
			$count = $this->db->selectCell("SELECT count(*) FROM ?_".$this->module_table." WHERE file_invoice=?", $order['file_invoice']);
			if($count==1) {
				@unlink(ROOT_DIR_FILES.$this->setting("dir_files_invoices").$order['file_invoice']);
			}
			$this->update($id, array("file_invoice"=>""));
		}
	}
	
	public function exportTo1C($items = array())
	{
		$orders = array();
		if(is_array($items) and $items)
		{
			foreach($items as $val)
				$orders[] = $this->get_order($val);
		}
		else
			$orders = $this->get_list_orders();
		
		if($orders)
		{
			$emptyFlag = false; //don`t forget
			$xmlStr = '<?xml version="1.0" encoding="utf8"?>
							<КоммерческаяИнформация ВерсияСхемы="2.05" ДатаФормирования="'.date("Y.m.dTH:i:s", time()).'" ФорматДаты="ДФ=yyyy-MM-dd; ДЛФ=DT" ФорматВремени="ДФ=ЧЧ:мм:сс; ДЛФ=T" РазделительДатаВремя="T" ФорматСуммы="ЧЦ=18; ЧДЦ=2; ЧРД=." ФорматКоличества="ЧЦ=18; ЧДЦ=2; ЧРД=.">';
			$deliveries =  $this->catalog->get_list_deliveries();
			foreach($orders as $order)
			{
				@list($sirname, $name) = explode(' ', $order['name']);
				$delivery = "";
				if($deliveries)
					foreach($deliveries as $val)
						if($val['id'] == $order['delivery_id'])
							$delivery = $val['name'];
					
				$xmlOrderStr = '<Документ>';
				$xmlOrderStr .= "<Ид>{$order['id']}</Ид><Номер>{$order['id']}</Номер>
								<Дата>".date("Y-m-d", $order['date_add'])."</Дата>
								<ХозОперация>Заказ товара</ХозОперация>
								<Роль>Продавец</Роль>
								<Валюта>RUB</Валюта>
								<Курс>1</Курс>
								<Сумма>".round($order['total_price'] ,2)."</Сумма>
								<Контрагенты>
									<Контрагент>
										<Наименование>{$order['name']}</Наименование>
										<ПолноеНаименование>{$order['name']}</ПолноеНаименование>
										<Фамилия>".$sirname."</Фамилия>
										<Имя>".$name."</Имя>	
										<Контакты>
											<Контакт>
												<Тип>Почта</Тип>
												<Значение>{$order['email']}</Значение>
											</Контакт>
											<Контакт>
												<Тип>Телефон</Тип>
												<Значение>{$order['phone']}</Значение>
											</Контакт>		
											<Контакт>
												<Тип>Другое</Тип>
												<Значение>{$order['contacts']}</Значение>
											</Контакт>												
										</Контакты>					
										<Роль>Покупатель</Роль>						
									</Контрагент>
								</Контрагенты>
								<Время>".date("H:i:s", $order['date_add'])."</Время>
								<Комментарий>{$order['admin_comment']}</Комментарий>
								";
				$xmlProductStr = "<Товары>";
				
				$cart = $this->get_order_products($order['id']);
				$products = $cart['products'];
				if($products)
				{
					foreach($products as $product)
					{
						$xmlOneProduct = "<Товар>
											<Ид>{$product['id']}</Ид>
											<ИдКаталога>{$product['categ']}</ИдКаталога>
											<Наименование>{$product['name']}</Наименование>
											<БазоваяЕдиница Код=\"796\" НаименованиеПолное=\"Штука\" МеждународноеСокращение=\"PCE\">шт</БазоваяЕдиница>
											<ЦенаЗаЕдиницу>{$product['price_order']}</ЦенаЗаЕдиницу>
											<Количество>{$product['amount']}</Количество>
											<Сумма>".($product['price_order']*$product['amount'])."</Сумма>
											<ЗначенияРеквизитов>
												<ЗначениеРеквизита>
													<Наименование>ВидНоменклатуры</Наименование>
													<Значение>Товар</Значение>
												</ЗначениеРеквизита>
												<ЗначениеРеквизита>
													<Наименование>Артикул</Наименование>
													<Значение>{$product['articul']}</Значение>
												</ЗначениеРеквизита>
											</ЗначенияРеквизитов>
										</Товар>";
						$xmlProductStr .= $xmlOneProduct;
					}
				}
				else
					continue;
				
				$xmlProductStr .= "</Товары>";
				$xmlOrderStr .= $xmlProductStr;
				$xmlOrderStr .= "
					<ЗначенияРеквизитов>
						<ЗначениеРеквизита>
							<Наименование>Способ доставки</Наименование>
							<Значение>$delivery</Значение>
						</ЗначениеРеквизита>
						<ЗначениеРеквизита>
							<Наименование>Адрес доставки</Наименование>
							<Значение>{$order['address']}</Значение>
						</ЗначениеРеквизита>
						<ЗначениеРеквизита>
							<Наименование>Комментарий</Наименование>
							<Значение>{$order['comment']}</Значение>
						</ЗначениеРеквизита>
					</ЗначенияРеквизитов>
				";
				$xmlOrderStr .= '</Документ>';
				
				$xmlStr .= $xmlOrderStr;
			}
			$xmlStr .= '</КоммерческаяИнформация>';
			
			if(!$emptyFlag)
			{
	            return $xmlStr;
			}
		}
		return false;
	}
	
		/**
	 * возвращает количество новых заказов
	 */
	public function get_count_new() {
		return $this->get_count_orders( array("status"=>0, "paid" => 1) );
	}

}