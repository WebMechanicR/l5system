<!-- main content wrapper -->
<div class="content-wrap">
    <!-- main content -->
    <div class="content">
        <?php echo $site->tpl->display('breadcrumbs'); ?>
        
        <h1><?php if(!isset($category) or !$category) { ?>Каталог товаров<? } else { echo $category['title']; } ?></h1>
        <?php if(isset($category) and $category): ?>
        <?php if(isset($list_categ_products) and count($list_categ_products)>0) { ?>
        <!-- products box -->
        <div class="products-box">
            <?php $site->tpl->display('catalog_list_products', array("list_products" => &$list_categ_products)); ?>
        </div>
        <?php $site->tpl->display('paging'); ?>
        <!-- products box -->
        <?php } else { ?> 
             <p>По Вашему запросу ничего не найдено.</p>
        <?php } ?>
        <?php else: ?>
             
             <?php
                if(isset($tree_categories['tree'][0]) and is_array($tree_categories['tree'][0])){
                    ?>
                        <!-- products list / catalog -->
			<ul class="catalog products-list">
                            <?php
                                foreach($tree_categories['tree'][0] as $categ_id){
                                $link = SITE_URL . $catalog_full_link . "/";
                                $categ = $tree_categories['all'][$categ_id];
                                $link .= $categ['full_link'];
                                if(!$categ['enabled'])
                                    continue;
                            ?>
                                        <li>
                                            <div class="product-holder">
                                                <a href="<?php echo $link; ?>">
                                                    <div class="product-img">
                                                        <img src="<?php echo ($categ['img'] ? $content_photos_dir.'small/'.$categ['img'] : $dir_images.'noimg.jpg'); ?>" alt="<?php echo $categ['title']; ?>">
                                                    </div>
                                                    <h4><?php echo $categ['title']; ?></h4>
                                                    <?php if(isset($prices[$categ_id])){ ?>
                                                    <span class="price">от <?php echo $prices[$categ_id]; ?> руб.</span>
                                                    <?php } ?>
                                                </a>
                                            </div>
                                        </li>
                           <?php
                                }
                           ?>
                        </ul>
                    <?php
                }
             ?>
             
        <?php endif; ?>
    </div>
    <!-- main content end -->
</div>
<!-- main content wrapper end -->
<?php $site->tpl->display('catalog_right_categories'); ?>
                        
                       
