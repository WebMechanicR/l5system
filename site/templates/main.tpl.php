<!-- main content wrapper -->
<div class="content-wrap">
    <!-- main content -->
    <div class="content">
        <!-- promo -->
        <section class="promo">
            <ul class="main-slider">
                <?php
                    $content_photos_dir = SITE_URL.URL_IMAGES.$site->slides->setting('dir_images');
                    if($list_slides)
                        foreach($list_slides as $item){
                            ?>
                                <li>
                                    <div class="promo-img">
                                    	<?php if($item['url']!='') { ?><a href="<?php echo $item['url']; ?>"><?php } ?>
                                        <img src="<?php echo $content_photos_dir.'normal/'.$item['img']; ?>"alt="<?php echo $item['title']; ?>">
                                        <?php if($item['url']!='') { ?></a><?php } ?>
                                    </div>
                                    <div class="promo-text">
                                        <strong class="caption"><?php echo $item['title']; ?></strong>
                                        <span class="note"><?php echo $item['desc']; ?></span>
                                    </div>
                                </li>
                            <?php
                        }
                ?>
            </ul>
        </section>
        <!-- promo end -->

        <?php if($block1) { ?>
        <!-- product section -->
        <section class="product-section slider-box">
            <h2><?php echo $site->settings->name_of_mainpage_block1; ?></h2>
            <!-- products slider -->
            <div class="products-box">
                <?php $site->tpl->display('catalog_list_products', array('list_products' => $block1, 
																						   'content_photos_dir' => SITE_URL.URL_IMAGES.$site->catalog->setting('dir_images'), 
																						   'catalog_full_link' => $site->pages->get_full_link_module('catalog'),
																						   'as_slide'=>true)); ?>
            </div>
            <!-- products slider end -->
        </section>
        <!-- product section end -->
        <?php } ?>
        
        <?php if($block2) { ?>
        <!-- product section -->
        <section class="product-section slider-box">
            <h2><?php echo $site->settings->name_of_mainpage_block2; ?></h2>
            <!-- products slider -->
            <div class="products-box">
                <?php $site->tpl->display('catalog_list_products', array('list_products' => $block2, 
																						   'content_photos_dir' => SITE_URL.URL_IMAGES.$site->catalog->setting('dir_images'), 
																						   'catalog_full_link' => $site->pages->get_full_link_module('catalog'),
																						   'as_slide'=>true)); ?>
            </div>
            <!-- products slider end -->
        </section>
        <!-- product section end -->
        <?php } ?>
        
        <?php if(mb_strlen($site->settings->description_on_main)>10) { ?>
        <!-- text section -->
        <section class="text-section">
            <?php echo $site->settings->description_on_main; ?>
        </section>
        <!-- text section end -->
        <?php } ?>
    </div>
    <!-- main content end -->
</div>
<!-- main content wrapper end -->

<?php $site->tpl->display('news_right_block'); ?>

