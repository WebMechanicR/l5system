<?php
if (isset($list_products) and count($list_products) > 0) {
    ?>
    <!--products list-->
    <ul class="products-list<?php if(isset($as_slide) and $as_slide) echo ' products-slider'; ?>">
        <?php
        foreach ($list_products as $tl_product){
            $link_product = SITE_URL . $catalog_full_link . "/";
            $link_product .= $tree_categories['all'][$tl_product['categ']]['full_link'];
            $t_cat_id = $tl_product['categ'];
			$temp_id = $tl_product['categ']."_".rand(1,100);
            ?>
                <li>
                    <div class="product-holder<?php if($tl_product['price']<=0 ) echo " no-price"; ?>">
                        <a href="<?php echo $link_product . "/" . $tl_product['url']; ?>.htm">
                            <div class="product-img">
                                <img id="prod_image_<?php echo $temp_id;?>" src="<?php echo ($tl_product['img'] != "" ? $content_photos_dir . "normal/" . $tl_product['img']  : $dir_images.'noimg.jpg'); ?>" alt="<?php echo $tl_product['name']; ?>">
                            </div>
                            <?php
                                if($tl_product['is_hit'])
                                    echo '<span class="label bestseller">Хит продаж</span>'; 
                                else if($tl_product['novelty'])  
                                     echo '<span class="label novelty">Новинка</span>'; 
                                else if($tl_product['last_price']>$tl_product['price'])
                                    echo '<span class="label action">Акция</span>';
                            ?>
                            <h4><span><?php echo $tl_product['name']; ?></span></h4>
                            <?php if($tl_product['price']>0 ){ ?><span class="price"><?php if($tl_product['last_price']>$tl_product['price']){ ?><del><?php echo F::number_format($tl_product['last_price']); ?>&nbsp;руб.</del> <?php } ?><?php echo F::number_format($tl_product['price']); ?>&nbsp;руб.</span><?php } ?>
                        </a>
                        <?php if($tl_product['price']>0 ){ ?><a href="#" data-transfer="#prod_image_<?php echo $temp_id;?>" data-id="<?php echo $tl_product['id']; ?>" data-url="<?php echo SITE_URL.$catalog_full_link."/add_cart.htm"; ?>" class="to-car add-to-cart"><span>Добавить в корзину</span></a><?php  } ?>
                    </div>
                </li>
      <?php } ?>
     </ul>
<!-- products list  -->
<?php } ?>