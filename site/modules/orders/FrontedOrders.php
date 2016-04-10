<?php
/**
 * класс отображения заказов в пользовательской части сайта
 * @author riol
 *
 */

class FrontedOrders extends View {
	public function index() {
		//$this->wraps_off();
		$product_id = $this->request->post('product_id', 'integer');
		$category_id = $this->request->post('category_id', 'integer');

		if($product_id>0)
			$this->cart->add($product_id, $category_id);

		$cart = $this->cart->get_cart();

		/**
		 * ошибки при заполнении формы
		*/
		$errors = array();
		$success = false;
		 
		$order = array();
		$deliveries = $this->catalog->get_list_deliveries();
		$payment_types = $this->catalog->get_list_payment_types();

		if($this->request->method('post') && !empty($_POST)) {
			$order['name'] = $this->request->post('name', 'string');
			$order['email'] = $this->request->post('email', 'string');
			$order['phone'] = $this->request->post('phone', 'string');
			$order['contacts'] = $this->request->post('contacts', 'string');
			$order['delivery_id'] = $this->request->post('delivery_id', 'integer');
			$order['payment_type_id'] = $this->request->post('payment_type_id', 'integer');
			$order['address'] = $this->request->post('address', 'string');
			$order['comment'] = $this->request->post('comment', 'string');

			if(empty($order['name'])) $errors['name'] = 'no_name';

			if(empty($order['email'])) $errors['email'] = 'no_email';
			elseif(!F::is_email($order['email'])) $errors['email'] = 'err_email';

			if(empty($order['phone'])) $errors['phone'] = 'no_phone';

			if($order['delivery_id']==0) $errors['delivery'] = 'no_delivery';
			if($order['payment_type_id']==0) $errors['payment_type'] = 'no_payment_type';

			if(empty($order['address'])) $errors['address'] = 'no_address';


			if(count($errors)==0){
				if(count($errors)==0) {
					$order['date_add'] = time();
					$order['amount'] = $cart['total_products'];
					$order['total_price'] = $cart['total_price'];
					$order_id = 0;
					if($order_id = (int)$this->orders->add($order)) {
						foreach($cart['products'] as $tl_product) {
							$product = array(
									"order_id"=>$order_id,
									"product_id"=>$tl_product['id'],
									"price"=>$tl_product['price'],
									"amount"=>$tl_product['amount']
							);
							$this->orders->add_order_product($product);
						}
						$order['id'] = $order_id;
						 
						$this->tpl->add_var('cart', $cart);
						$this->tpl->add_var('order', $order);
						$this->tpl->add_var('order_id', $order_id);
						$this->tpl->add_var('deliveries', $deliveries);
						$this->tpl->add_var('payment_types', $payment_types);
						$html_mail_user = $this->tpl->fetch("mail/order_user");
						$html_mail_admin = $this->tpl->fetch("mail/order_admin");
						//DON`T FORGET THIS LINES, MAN
						$this->mail->send_mail(array($order['email'], $order['name']), "Ваш заказ на " . $this->settings->site_title, $html_mail_user);
						$this->mail->send_mail(array($this->settings->site_email, $this->settings->site_title), "Новый заказ на " . $this->settings->site_title, $html_mail_admin);
						 
						//чистим корзину
						$this->cart->empty_cart();
						$order = array();
						$success = true;
						$this->tpl->add_var('order_id', $order_id);
					}
				}
			}
		}

		$this->tpl->add_var('cart', $cart);
		$this->tpl->add_var('order', $order);
		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('deliveries', $deliveries);
		$this->tpl->add_var('payment_types', $payment_types);
		$this->tpl->add_var('success', $success);
		return $this->tpl->fetch("orders");
	}
}