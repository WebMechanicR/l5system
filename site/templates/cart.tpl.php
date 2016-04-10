<?php  if(isset($cart) and count($cart['products'])>0 and !$success){ ?>
<!-- sidebar -->
<aside class="sidebar">
    <h3>Моя корзина</h3>
    <!-- cart box -->
    <div class="cart-box">
        <!-- cart list -->
        <ul class="cart-list">
            <?php
                    $count = 0;
                    foreach($cart['products'] as $cart_id => $tl_product) { 
			$link_product = SITE_URL.$catalog_full_link."/";
			if(isset($cart['category_id']) and $cart['category_id'] and isset($tree_categories['all'][ $cart['category_id'] ])) 
				$link_product .= $tree_categories['all'][ $cart['category_id'] ]["full_link"];
			else 
				$link_product .= $tree_categories['all'][ $tl_product['categ'] ]['full_link'];
	    ?>
                        <li class="product">
                            <div class="product-holder">
                                <a href="#" data-url="<?php echo SITE_URL.$catalog_full_link."/del_cart_".$cart_id.".htm";?>" data-id="<?php echo $tl_product['id']; ?>" class="icon-close close">close</a>
                                <div class="product-img">
                                    <a href="<?php echo $link_product."/".$tl_product['url'];?>.htm"><img src="<?php echo SITE_URL.URL_IMAGES.$site->catalog->setting('dir_images')."normal/".$tl_product['img'];?>" alt="<?php echo $tl_product['name'];?>"></a>
                                </div>
                                <h4><a href="<?php echo $link_product."/".$tl_product['url'];?>.htm"><?php echo $tl_product['name'];?></a></h4>
                                <div class="count">
                                    <span class="price" data-price="<?php echo $tl_product['price']; ?>"><span class="product-sum-value"><?php echo F::number_format($tl_product['price']); ?></span> <span class="unit">руб.</span></span>
                                    <div class="nums">
                                        <?php if(isset($only_read) and $only_read) { ?>
                                        	Кол-во: <?php echo $tl_product['amount'];?>
                                        <?php } else { ?>
                                        <form method="post" action="<?php echo SITE_URL.$catalog_full_link."/update_cart_".$cart_id.".htm";?>">
											<input type="hidden" value="<?php echo $tl_product['id'];?>" name="product_id">
                                        	<a href="#" class="link-minus">&ndash;</a>
                                            <input type="text" value="<?php echo $tl_product['amount'];?>" name="amount">
                                        	<a href="#" class="link-plus">+</a>
                                        </form>
                                        <?php } ?>
                                     </div>
                                </div>
                            </div>
                        </li>
                <?php
                 }
                ?>
        </ul>
        <!-- cart list end -->

        <!-- cart info -->
        <div class="cart-info">
            <?php if($cart['total_price']>0) { ?>
            <!-- cart total -->
            <div class="total">
                <strong class="total-value-holder"><?php echo F::number_format($cart['total_price']);?> руб.</strong>
                <strong class="total-amount">Всего: <span class="total-amount-value"><?php echo $cart['total_products']; ?> <?php echo F::get_right_okonch($cart['total_products'], "товаров", "товар", "товара"); ?></span></strong>
            </div>
            <!-- cart total end -->
            <?php } ?>
        </div>
        <!-- cart info end -->
    </div>
    <!-- cart box end -->
</aside>
<!-- sidebar -->
<?php } ?>