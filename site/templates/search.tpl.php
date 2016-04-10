<!-- main content wrapper -->
<div class="content-wrap">
    <!-- main content -->
    <div class="content">
        <?php echo $site->tpl->display('breadcrumbs'); ?>
        
        <h1><?php if(!empty($page_t['title_first'])) { echo $page_t['title_first']; } else {echo $page_t['title'];} ?></h1>
        
        <?php if(isset($list_products) and count($list_products)>0) { ?>
        <!-- products box -->
        <div class="products-box">
            <?php $site->tpl->display('catalog_list_products', array("list_products" => &$list_products)); ?>
        </div>
        <?php $site->tpl->display('paging'); ?>
        <!-- products box -->
        <?php } else { ?> 
             <p>По Вашему запросу ничего не найдено.</p>
        <?php } ?>
    </div>
</div>
<?php $site->tpl->display('catalog_right_categories'); ?>