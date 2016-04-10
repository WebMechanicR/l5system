<?php
/**
 * класс отображения корзины в пользовательской части сайта
 * @author riol
 *
 */

class FrontedCart extends View {

        public function index() {
		$this->wraps_off();
		
		$this->set_meta_title('Оформление заказа');
		
		$this->tpl->add_var('meta_title', $this->get_meta_title());
		$this->tpl->add_var('meta_description', $this->get_meta_description());
		$this->tpl->add_var('meta_keywords', $this->get_meta_keywords());
		return $this->tpl->fetch("cart");
	}
    
	public function add_cart() {
		$this->wraps_off();
	
		$product_id = $this->request->post('product_id', 'integer');
		$category_id = $this->request->post('category_id', 'integer');
		if($product_id>0) {
			$this->cart->add($product_id, $category_id);
		}
                
		return $this->tpl->fetch("cart_status");
	}
	
	public function del_cart() {
		$this->wraps_off();
	
		$id = $this->request->get('id', 'integer');
		if($id>0) {
			$this->cart->delete($id);
		}
               
		return $this->tpl->fetch("cart_status");
	}
	
	public function update_cart() {
		$this->wraps_off();
	
		$id = $this->request->get('id', 'integer');
		
		$product_id = $this->request->post('product_id', 'integer');
		$amount = $this->request->post('amount', 'integer');
		if($id>0 and $amount>0) {
			$this->cart->update($id, $product_id, $amount);
		}
               
		return $this->tpl->fetch("cart_status");
	}
}