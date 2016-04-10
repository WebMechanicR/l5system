<?php
if ($list_news and count($list_news) > 0) {
    $content_photos_dir = SITE_URL . URL_IMAGES . $site->news->setting("dir_images");
    $ar_month = array("", "Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря");
    ?>
<!-- news list -->
<ul class="news-list">			
        <?php foreach($list_news as $t_news) { ?>
            <li>
                <figure class="news-img">
                    <a href="<?php echo SITE_URL.$news_full_link."/".$t_news['url']; ?>.htm"><img src="<?php echo $content_photos_dir.'normal2/'.$t_news['img']; ?>" width="336" height="160" alt="<?php echo $t_news['title']; ?>"></a>
                </figure>
                <h4><a href="<?php echo SITE_URL.$news_full_link."/".$t_news['url']; ?>.htm"><?php echo $t_news['title']; ?></a></h4>
                <time datetime="<?php echo date('Y-m-d', $t_news['date_add']); ?>" class="published"><?php echo date('d', $t_news['date_add']) . ' ' . $ar_month[date('n', $t_news['date_add'])] . ' ' . date('Y', $t_news['date_add']); ?></time>
                <p>
                    <?php
                    if(mb_strlen($t_news['brief_description']) > 10)
                        echo $t_news['brief_description'];
                    else
                        echo F::truncate_txt($t_news['body'], 350);
                    ?>
                </p>
            </li>   
        <?php } ?>
</ul>
<!-- end news list -->					 
<?php } ?>
