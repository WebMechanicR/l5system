<?php
    $t_cart = $site->cart->get_cart();
?>
<a href="<?php echo SITE_URL.$site->pages->get_full_link_module("catalog")."/order.htm"; ?>"><i class="icon-cart"></i><span>Моя корзина</span></a>:
<span class="cart-value"><?php echo ($t_cart['total_products'])?$t_cart['total_products']." ".F::get_right_okonch($t_cart['total_products'], "товаров", "товар", "товара").' на сумму '.F::number_format($t_cart['total_price']).' руб.':"нет товаров"; ?></span>
