<!-- sidebar -->
<aside class="sidebar">
	<?php if(!$site->settings->off_news and $list_news = $site->news->get_list_last_news(6)) { ?>
    <h3>Новости компании</h3>
    <!-- news preview -->
    <ul class="news-preview">
        <?php
            $content_photos_dir = SITE_URL . URL_IMAGES . $site->news->setting("dir_images");
            $ar_month = array("", "Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря");
            foreach($list_news as $t_news) { ?>
             <li>
             	<?php if($t_news['img']!='') { ?>
                <figure class="news-img">
                    <a href="<?php echo SITE_URL.$news_full_link."/".$t_news['url']; ?>.htm"><img src="<?php echo $content_photos_dir.'small/'.$t_news['img']; ?>" alt="<?php echo $t_news['title']; ?>"></a>
                </figure>
                <?php } ?>
                <p><a href="<?php echo SITE_URL.$news_full_link."/".$t_news['url']; ?>.htm"><?php echo $t_news['title']; ?></a></p>
                <time datetime="<?php echo date('Y-m-d', $t_news['date_add']); ?>" class="published"><?php echo date('d', $t_news['date_add']) . ' ' . $ar_month[date('n', $t_news['date_add'])] . ' ' . date('Y', $t_news['date_add']); ?></time>
            </li>
        <?php } ?>
    </ul>
    <!-- news preview end -->
	<?php } ?>
    
    <?php $site->display('sidebar_blocks');?>
</aside>
<!-- sidebar -->
