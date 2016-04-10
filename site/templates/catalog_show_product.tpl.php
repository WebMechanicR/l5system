<!-- main content wrapper -->
<div class="content-wrap">
    <!-- main content -->
    <div class="content">
        <?php $site->tpl->display('breadcrumbs'); ?>
  
        <!--product single -->
        <section class="product-single">
            <h1><?php echo $product['name'];?></h1>
            <!-- product -->
            <div class="product">
                <!-- product visual -->
                <div class="product-visual">
                    <!-- product image -->
                    <?php if(isset($product['images'])){ ?>
                    <div class="large-img">
                    	<ul class="bxslider">
                    	<?php foreach($product['images'] as $i=>$content_photo) { ?>
                        <li><a href="<?php echo $content_photos_dir."super/".$content_photo['picture'];?>" class="fb-gallery" data-fancybox-group="gallery" title="<?php echo $content_photo['name'];?>"><img src="<?php echo $content_photos_dir."big/".$content_photo['picture'];?>" alt="<?php echo $content_photo['name'];?>"></a></li>
                    	<?php } ?>
                        </ul>
                    </div>

                    <?php
                        if($product['is_hit'])
                            echo '<span class="label bestseller">Хит продаж</span>'; 
                        else if($product['novelty'])  
                             echo '<span class="label novelty">Новинка</span>'; 
                        else if($product['last_price']>$product['price'])
                            echo '<span class="label action">Акция</span>';
                    ?>
                    <?php } ?>
                    <!-- product image end -->
                    <?php if(isset($product['images']) and count($product['images'])>1){ ?>
                    <!-- preview carousel -->
                    <div class="visual-preview">
                        <ul class="preview-carousel">
                            <?php foreach($product['images'] as $i=>$content_photo) { ?>
                            <li>
                                <a data-slide-index="<?php echo $i;?>" <?php echo $i==0?'class="active"':''; ?> href="<?php echo $content_photos_dir."big/".$content_photo['picture'];?>"><img src="<?php echo $content_photos_dir."small/".$content_photo['picture'];?>"alt="<?php echo $content_photo['name'];?>"></a>
                            </li>
                            <?php } ?>
                        </ul>
                    </div>
                    <!-- preview carousel end -->
                    <?php } ?>
                </div>
                <!-- product visual end -->

                <!-- product description -->
                <div class="product-description">
                	<?php if($product['price']>0) { ?>
                    <div class="product-heading">
                        <a href="#" data-transfer="h1" class="btn btn-default add-to-cart" data-id="<?php echo $product['id']; ?>" data-url="<?php echo SITE_URL.$catalog_full_link."/add_cart.htm"; ?>">Добавить в корзину</a>
                        <?php if($product['last_price']){ ?><del><?php echo F::number_format($product['last_price']); ?> руб.</del> <?php } ?>
                        <strong class="price"><?php echo F::number_format($product['price']); ?> <span class="unit">руб.</span></strong>
                    </div>
                    <?php } ?>
                     <?php echo $product['brief_description'];?>
                     <?php echo $product['description'];?>
                    <?php if($product['articul']) {?><span class="article">Артикул: <?php echo $product['articul']; ?></span><?php } ?>
                </div>

                <!-- object description end -->
            </div>
            <!-- product end -->
            
            <?php if(isset($product['files']) and count($product['files'])>0) { ?>
                         	<div class="documents">
                            <h2>Файлы</h2>
                            <ul class="element-list">
                                <?php foreach($product['files'] as $file) {  ?>
                                <li>
                                    <figure><a href="<?php echo $products_files_dir.$file['file']; ?>"><i class="icon-file file-<?php echo strtolower($file['type']); ?>"></i></a></figure>
                                    <div class="description">
                                        <h4><a href="<?php echo $products_files_dir.$file['file']; ?>"><?php echo $file['name']; ?></a></h4>
                                        <div>
                                            <time datetime="<?php echo date('d.m.Y', $file['date_add']); ?>"><?php echo date('d.m.Y', $file['date_add']); ?></time>
                                            <?php
                                                    $size = round($file['size'] / 1024, 2);
                                                    if ($size > 1000)
                                                        $size = str_replace(",", ".", round($size / 1024, 2)) . " MB";
                                                    else
                                                        $size = str_replace(",", ".", $size) . " KB";
                                             ?>
                                            <span><?php echo strtoupper($file['type']); ?>,  <?php echo $size; ?></span>
                                        </div>
                                    </div>
                                </li>
                                <?php } ?>
                            </ul>
                            </div>
			<?php } ?>	

        </section>
        <!-- product single end -->

        <?php if($related_products): ?>
        <!-- product section -->
        <section class="product-section">
            <h2><?php echo $site->settings->name_of_related_products; ?></h2>
            <!-- products slider -->
            <div class="products-box">
                <ul class="products-list">
                    <?php $site->tpl->display('catalog_list_products', array('list_products' => $related_products)); ?>
                </ul>
            </div>
            <!-- products slider end -->
        </section>
        <!-- product section end -->
        <?php endif; ?>
        
         <?php if($site->settings->name_of_other_products and $recomenduem_list_products): ?>
        <!-- product section -->
        <section class="product-section">
            <h2><?php echo $site->settings->name_of_other_products; ?></h2>
            <!-- products slider -->
            <div class="products-box">
                <?php $site->tpl->display('catalog_list_products', array('list_products' => $recomenduem_list_products)); ?>
            </div>
            <!-- products slider end -->
        </section>
        <!-- product section end -->
        <?php endif; ?>
    </div>
    <!-- main content end -->
</div>
<!-- main content wrapper end -->

<?php $site->tpl->display('catalog_right_categories'); ?>