<?php
class Cart extends Module {

	protected $module_name = "cart";
	public $module_table = "cart";
	private $module_nesting = false; //возможность владывать подстраницы в модуль


	/**
	 * добавляет новый элемент в корзину
	 */
	public function add($product_id, $category_id=0, $amount = 1) {
		$amount = max(1, $amount);

		$session_id = session_id();
		$this->cache->delete("cart_".$session_id);


		if($cart_item = $this->get_cart_item($session_id, $product_id)) {
			$this->db->query("UPDATE ?_".$this->module_table." SET amount=amount+".$amount." WHERE id=?d", $cart_item['id']);
		}
		else {
			// Выберем товар из базы, заодно убедившись в его существовании
			$product = $this->catalog->get_product_info(intval($product_id));

			if($product)
                            $this->db->query("INSERT INTO ?_".$this->module_table."
				(product_id, session_id, category_id, amount, date_add) VALUES (?d, ?, ?d, ?d, ?d)",
				$product_id, $session_id, $product['categ'], $amount, time());
		}
	}

	public function get_cart_item($session_id, $product_id, $id=0) {
		if($id) return $this->db->selectRow("SELECT * FROM ?_".$this->module_table." WHERE session_id=? AND id=?d", $session_id, $id);
		else return $this->db->selectRow("SELECT * FROM ?_".$this->module_table." WHERE session_id=? AND product_id=?d", $session_id, $product_id);
	}

	/**
	 * обновляет элемент в корзине
	 */
	public function update($id, $product_id, $amount = 1) {
		$amount = max(1, $amount);
		$session_id = session_id();
		$this->cache->delete("cart_".$session_id);
                
		if($cart_item = $this->get_cart_item($session_id, $product_id, $id)) { 
			$this->db->query("UPDATE ?_".$this->module_table." SET amount=?d WHERE id=?d", $amount, $id);
		}
		else $this->add($product_id, 0, $amount);
	}

	/**
	 * удаляет элемент из корзины
	 */
	public function delete($id) {
		$session_id = session_id();
		$this->cache->delete("cart_".$session_id);
		$this->db->query("DELETE FROM ?_".$this->module_table." WHERE id=?d AND session_id=?", $id, $session_id);
	}

	/**
	 * очистка корзины
	 */
	public function empty_cart() {
		$session_id = session_id();
		$this->cache->delete("cart_".$session_id);
		$this->db->query("DELETE FROM ?_".$this->module_table." WHERE session_id=?", $session_id);
	}

	/**
	 * возвращает корзину
	 */
	public function get_cart() {
		$session_id = session_id();

		$cache_key = "cart_".$session_id;

		//$this->cache->delete($cache_key);
		if (false === ($cart = $this->cache->get($cache_key))) {

			$cart = array();
			$cart['products'] = array();
			$cart['total_price'] = 0;
			$cart['total_products'] = 0;
			$parent_products = array();

			if($shopping_cart=$this->db->select("SELECT * FROM ?_".$this->module_table." WHERE session_id=?", $session_id)) {
				$pr_ids = array();
				foreach($shopping_cart as $product) {
					$pr_ids[] = $product['product_id'];
				}

				if($products = $this->catalog->get_list_products(array("enabled"=> 1, "in_ids"=>$pr_ids, "ARRAY_KEY"=>"pr.id"))) {
					foreach($shopping_cart as $t_product) {
						$key = $t_product['id'];
						$product = $products[$t_product['product_id']];
						$product['amount'] = $t_product['amount'];
						$product['category_id'] = $t_product['category_id'];

						$cart['total_price'] += $product['price']*$product['amount'];
						$cart['products'][$key] = $product;

						$cart['total_products'] += $product['amount'];
					}
				}
			}

			$this->cache->set($cart, $cache_key, array(), 30*60);

			//удаляем старые записи из корзины, сроком больше суток
			$this->db->query("DELETE FROM ?_".$this->module_table." WHERE date_add<=?d", (time()-24*60*60));
		}
			
		return $cart;
	}
}