<?php 
	$ar_month = array("","Января","Февраля","Марта","Апреля","Мая","Июня","Июля","Августа","Сентября","Октября","Ноября","Декабря");
?>
<!-- main content wrapper -->
<div class="content-wrap">
    <!-- main content -->
    <div class="content">
        <?php echo $site->tpl->display('breadcrumbs'); ?>

        <!-- news simple -->
        <article class="news">
            <h1><?php echo $news['title']; ?></h1>
            <figure class="news-figure">
                <img src="<?php echo $news_photos_dir.'big/'.$news['img']; ?>" alt="<?php echo $news['title']; ?>">
            </figure>
            <?php
                echo $news['body']; 
            ?>
            <?php
                if($news['images']){
                    ?>  
                        <!-- images list -->
                        <div class="img-list">
                            <?php
                                foreach($news['images'] as $item){
                                    ?>
                                            <li><a href="<?php echo $news_photos_dir.'big/'.$item['picture']; ?>" class="fb-gallery" data-fancybox-group="gallery" title="<?php echo $item['name']; ?>"><img src="<?php echo $news_photos_dir.'normal/'.$item['picture']; ?>" alt="<?php echo $item['name']; ?>"></a></li>
                                    <?php
                                }
                            ?>
                        </div>
                        <!-- images list end -->  
                    <?php
                }
            ?>
            
        </article>
        <!-- news simple  -->

        <?php if($list_news): ?>
        <!-- other news -->
        <div class="other-news">
            <h2>Другие новости</h2>
            <?php $site->tpl->display('news_list', array("list_news" => &$list_news)); ?>
        </div>
        <!-- other news end -->
        <?php endif; ?>
    </div>
    <!-- main content end -->
</div>
<!-- main content wrapper end -->

<?php $site->tpl->display('news_right_block'); ?>