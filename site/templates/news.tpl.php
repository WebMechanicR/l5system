<!-- main content wrapper -->
<div class="content-wrap">
    <!-- main content -->
    <div class="content">
       <?php echo $site->tpl->display('breadcrumbs'); ?>
       <?php  
        if(count($list_news)>0){ ?>
            <div class="news-box">
                <h1>Новости компании</h1>
                <?php $site->tpl->display('news_list', array("list_news" => &$list_news)); ?>	
            </div>
            <?php $site->tpl->display('paging'); ?>
        <?php 
        } else 
        { ?>
                <p>Ничего не найдено.</p>
        <?php } ?>
    </div>
    <!-- main content end -->
</div>
<!-- main content wrapper end -->

<?php $site->tpl->display('catalog_right_categories'); ?>
				
