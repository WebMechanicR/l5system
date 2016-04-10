<!--
Author: W3layouts
Author URL: http://w3layouts.com
License: Creative Commons Attribution 3.0 Unported
License URL: http://creativecommons.org/licenses/by/3.0/
-->
<!DOCTYPE HTML>
	<head>
		<meta charset="utf-8"/>
		<title>Ouch!!</title>
		<link href="<?php echo SITE_URL; ?>templates/waiting_html/css/style.css" rel="stylesheet" type="text/css"  media="all" />
		<script src="http://code.jquery.com/jquery-1.9.1.min.js" type="text/javascript"></script>
	    <script src="<?php echo SITE_URL; ?>templates/waiting_html/js/countdown.js" type="text/javascript"></script>	
	    <script src="<?php echo SITE_URL; ?>templates/waiting_html/js/init.js" type="text/javascript"></script>
	</head>
	<body>
		<!---start-wrap----->
		<!---start-header---->
		<div class="header">
			<div class="wrap">
				<div class="top-nav">
					<a href="#"><img src="<?php echo SITE_URL; ?>templates/waiting_html/images/logo.png" title="logo" /></a>
				</div>
			</div>
		</div>
		<!---End-header---->
		<!---start-content---->
		<div class="content">
				<div class="top-content">
					<h1>Нечто удивительное скоро представится Вам !
					<br/><br/>
					Something awesome is coming your way !
					</h1>
					<!---start-countdown-timer----->
					<ul id="countdown">
						<div class="wrap">
							<li>
								<span class="days">479</span>
								<h3>Days</h3>
							</li>
							<li>
								<span class="hours">02</span>
								<h3>hours</h3>
							</li>
							<li>
								<span class="minutes">00</span>
								<h3>minutes</h3>
							</li>
							<li>
								<span class="seconds">53</span>
								<h3>seconds</h3>
							</li>
						</div>	
					</ul>
				<!---End-countdown-timer----->
				</div>
		</div>
		<!---End-content---->
		
	</body>
</html>



<?php /*<!DOCTYPE HTML>
<html>
    <head>
        <meta charset="UTF-8">
        <title><?php echo $meta_title;?></title>
        <meta name="keywords" content="<?php echo $meta_description;?>" />
        <meta name="description" content="<?php echo $meta_description;?>" />
        <script type="text/javascript">
            var site_url = "<?php echo SITE_URL; ?>";
			var dir_css = '<?php echo $dir_css;?>';
			var dir_images = '<?php echo $dir_images;?>';
			var slide_delay = <?php echo $site->settings->slide_delay;?>*1000;
        </script>
        <!--[if IE]><script src="<?php echo $dir_js; ?>html5.js"></script><![endif]-->

        <!-- favicon -->
        <?php if($site->settings->favicon!='') {?>
        <link rel="shortcut icon" type="image/x-icon" href="<?php echo SITE_URL.URL_FILES.$site->settings->favicon;?>" >
        <?php } ?>

        <!-- main style -->
        <link href="<?php echo $dir_css; ?>widgets.css" rel="stylesheet" media="screen">
        <link href="<?php echo $dir_css; ?>all.css" rel="stylesheet" media="screen">

        <!--style for IE-->
        <!--[if lte IE 8]><link rel="stylesheet" href="<?php echo $dir_css; ?>ie8.css" media="screen, projection"><![endif]-->
        <!--[if lte IE 7]><link rel="stylesheet" href="<?php echo $dir_css; ?>ie7.css" media="screen, projection"><![endif]-->
        
        <!-- jquery library -->
        <script src="<?php echo $dir_js; ?>jquery-1.8.2.min.js"></script>
        <!-- ui -->
        <script src="<?php echo $dir_js; ?>jquery-ui-1.10.4.custom.min.js"></script>
        <!-- widgets -->
        <script src="<?php echo $dir_js; ?>widgets.js"></script>
        <!-- main functions -->
        <script src="<?php echo $dir_js; ?>functions.js"></script>
        <?php if(ADMINS_HAT){ ?>
        <link href="<?php echo $admin_dir_css;?>admin_hat.css" rel="stylesheet" media="screen">
        <?php } ?>
        
        <?php echo $site->settings->head_code; ?>
        
        <?php
			$bg_classes = array();
			if($site->settings->color_theme!='') $bg_classes[] = "color-".$site->settings->color_theme;
			if($site->settings->bg_type_scroll==1) $bg_classes[] = "bg-attachment";
			if($site->settings->bg_type_size==1) $bg_classes[] = "bg-width100";
			elseif($site->settings->bg_type_size==2) $bg_classes[] = "bg-cover";
			elseif($site->settings->bg_type_size==3) $bg_classes[] = "bg-repeat";
			
			$styles_body = "";
			if($site->settings->site_background) {
				$styles_body .= "background-image: url(".SITE_URL.URL_IMAGES."img/big/".$site->settings->site_background.");\r\n";
				if($site->settings->bg_type_size==2) {
    				$styles_body .= "filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src='".SITE_URL.URL_IMAGES."img/big/".$site->settings->site_background."', sizingMethod='scale');\r\n";
					$styles_body .= "-ms-filter: \"progid:DXImageTransform.Microsoft.AlphaImageLoader(src='".SITE_URL.URL_IMAGES."img/big/".$site->settings->site_background."', sizingMethod='scale')\";\r\n";
				}
			}
			
			if($styles_body) { ?>
			<style>
				body {
					<?php echo $styles_body;?>
				}
			</style>
            <?php } ?>
    </head>
    <body <?php if($bg_classes) { ?>class="<?php echo implode(" ", $bg_classes);?>"<?php } ?>>
		<?php echo $site->settings->body_top_code; ?>
        <!-- wrapper -->
        <div class="wrapper">
            <!-- header -->
            <header class="header">
                <!-- top panel -->
                <div class="top-panel">
                    <!-- max-wrap -->
                    <div class="max-wrap">
                        <!-- social networks -->
                        <ul class="social-networks">
                            <?php if($site->settings->vk_link) { ?><li><a href="<?php echo $site->settings->vk_link; ?>" class="soc-icon-vk" target="_blank">vk</a></li><?php } ?>
                            <?php if($site->settings->facebook_link) { ?><li><a href="<?php echo $site->settings->facebook_link; ?>" class="soc-icon-facebook" target="_blank">facebook</a></li><?php } ?>
                            <?php if($site->settings->twitter_link) { ?><li><a href="<?php echo $site->settings->twitter_link; ?>" class="soc-icon-twitter" target="_blank">twitter</a></li><?php } ?>
                            <?php if($site->settings->google_link) { ?><li><a href="<?php echo $site->settings->vk_link; ?>" class="soc-icon-google-plus" target="_blank">google-plus</a></li><?php } ?>
                        </ul>
                        <!-- social networks end -->

                        <!-- cart -->
                        <strong class="cart">
                            <?php $site->tpl->display('cart_status'); ?>
                        </strong>
                        <!-- cart end -->
                    </div>
                    <!-- max-wrap end -->
                </div>
                <!-- top panel end -->

                <!-- max-wrap -->
                <div class="max-wrap">
                    <!-- header holder -->
                    <div class="header-holder">
                        <!-- logo box -->
                        <div class="logo-box">
                            <?php if($module != 'main') { ?><a href="<?php echo SITE_URL; ?>"><?php } ?>
                            	<?php if($site->settings->site_logo) { ?>
                                	<img src="<?php echo SITE_URL.URL_IMAGES."img/big/".$site->settings->site_logo;?>" alt="<?php echo $site->settings->site_title; ?>">
                                <?php } else { ?>
                                <strong class="logo"><?php echo $site->settings->site_title; ?></strong>
                                <span class="logo-description"><?php echo $site->settings->site_brief_description; ?></span>
                                <?php } ?>
                             <?php if($module != 'main') { ?></a><?php } ?>
                        </div>
                        <!-- logo box end -->

                        <!-- user links -->
                        <div class="user-links">
                            <ul class="link-list">
                                <?php if($site->settings->site_phone) { ?><li class="phones"><i class="icon-handset"></i><?php echo $site->settings->site_phone; ?></li><?php } ?>
                                <?php if($site->settings->site_email) { ?><li><a href="mailto:<?php echo $site->settings->site_email; ?>"><i class="icon-email"></i><span><?php echo $site->settings->site_email; ?></span></a></li><?php } ?>
                            </ul>
                            <ul class="link-list">
                                <li><a href="<?php echo SITE_URL.'ordercall/'; ?>" class="popup" data-width="450" data-height="433"><i class="icon-callback"></i><span>Обратный звонок</span></a></li>
                                <li><a href="<?php echo SITE_URL.'question/'; ?>" class="popup" data-width="450" data-height="315"><i class="icon-chat"></i><span>Задайте вопрос</span></a></li>
                            </ul>
                        </div>
                        <!-- user links end -->
                    </div>
                    <!-- header holder end -->

                    <!-- nav area -->
                    <div class="nav-area">
                        <!-- search form -->
                        <div class="search-form">
                            <form action="<?php echo SITE_URL.$site->pages->get_full_link_module('search').'/'; ?>" method="get">
                                <fieldset>
                                    <div class="form-line">
                                        <div class="input-holder">
                                            <input type="text" name = "q" value="<?php echo $site->request->get('q', 'string')?$site->request->get('q', 'string'):''; ?>" placeholder="Поиск по сайту">
                                        </div>
                                        <div class="btn btn-search">
                                            <span class="icon-magnifier"></span>
                                            <input type="submit" value="">
                                        </div>
                                    </div>
                                </fieldset>
                            </form>
                        </div>
                        <!-- search form end -->

                        <!-- main navigation -->
                        <nav class="nav">
                             <?php
                            function get_top_menu($tree_menus, $tree_pages, $tree_categories, $page_t, $type, $page_url, $module, $catalog_full_link, $parent = 0, $catalog_item_arg = false, $catalog_parent = 0){
                                global $site;
                                $t_aux_page = "";
                                
                                if($catalog_item_arg){
                                    if(isset($tree_categories["tree"][$catalog_parent]) and is_array($tree_categories["tree"][$catalog_parent]))
                                                       foreach($tree_categories['tree'][$catalog_parent] as $categ_id){
                                                           if($tree_categories["all"][$categ_id]['enabled']){
                                                               $t_aux_page .= ('<li> '
                                                                       . '<a href="'.SITE_URL.$catalog_full_link.'/'.$tree_categories['all'][$categ_id]['full_link'].'/" title = "'.$tree_categories['all'][$categ_id]['title'].'">'.$tree_categories['all'][$categ_id]['title'].'<i class="arrow-drop-right"></i></a>'
                                                                       . ((isset($tree_categories['tree'][$categ_id]))?'<ul>'.get_top_menu($tree_menus, $tree_pages, $tree_categories, $page_t, $type, $page_url, $module, $catalog_full_link, $parent, $catalog_item_arg, $categ_id).'</ul>':'')
                                                                       . '</li>');
                                                           }
                                                       }
                                    return $t_aux_page;
                                }
                                
                                if(isset($tree_menus["tree"][$type][$parent]) and is_array($tree_menus["tree"][$type][$parent])){
                                    foreach ($tree_menus["tree"][$type][$parent] as $page_id){
                                        if ($tree_menus["all"][$page_id]['enabled']){
                                            $active = false;
                                            $catalog_item = $catalog_item_arg;
                                            if ($tree_menus["all"][$page_id]['page_id'] and isset($tree_pages["all"][$tree_menus["all"][$page_id]['page_id']]) and $tree_pages["all"][$tree_menus["all"][$page_id]['page_id']]['enabled']) {
                                                $tree_menus["all"][$page_id]['url'] = SITE_URL . $tree_pages["all"][$tree_menus["all"][$page_id]['page_id']]['full_link'] . "/";
                                                if($tree_pages["all"][$tree_menus["all"][$page_id]['page_id']]['module'] == 'catalog')
                                                    $catalog_item = true;
                                                if($catalog_item){
                                                    if(!$parent and $module == 'catalog')
                                                        $active = true;
                                                }
                                                else{
                                                    if(!$parent and $page_t){
                                                        $parentPage;
                                                        $current = $page_t['id'];
                                                        while(isset($tree_pages['all'][intval($current)])){
                                                            $page = $tree_pages['all'][intval($current)];
                                                            if($page['parent'] == 0){   
                                                                 $parentPage = $page;
                                                                 break;
                                                            }
                                                            $current = $page['parent'];
                                                        }
                                                        if($current == $tree_pages["all"][$tree_menus["all"][$page_id]['page_id']]['id'])
                                                            $active = true;
                                                    }
                                                    if($module == 'news')
                                                        if($page_url == $tree_pages["all"][$tree_menus["all"][$page_id]['page_id']]['url'])
                                                            $active = true;
                                                }
                                            }
                                                if($catalog_item){
                                                    $addingStr = '<ul>'.get_top_menu($tree_menus, $tree_pages,  $tree_categories,  $page_t, $type, $page_url, $module, $catalog_full_link, 0, true, 0).'</ul>';
                                                }
                                                else{
                                                    $addingStr = ((isset($tree_menus["tree"][$type][$tree_menus["all"][$page_id]['id']]) and $tree_menus["tree"][$type][$tree_menus["all"][$page_id]['id']])?'<ul>'.get_top_menu($tree_menus, $tree_pages,  $tree_categories,  $page_t, $type, $page_url, $module, $catalog_full_link, $tree_menus["all"][$page_id]['id']).'</ul>':'');
                                                }
                                                $t_aux_page .= '<li '.($active?'class="active"':'').'>'
                                                        . '<a href="' . $tree_menus["all"][$page_id]['url'] . '" ' . ($tree_menus["all"][$page_id]['title2'] ? 'title="' . $tree_menus["all"][$page_id]['title2'] . '"' : '') . '>'
                                                            .  $tree_menus["all"][$page_id]['title'] .((!$parent)?'<i class="arrow-drop-down"></i>':'<i class="arrow-drop-right"></i>'). '</a>'
                                                        . $addingStr 
                                                        . '</li>';
                                            
                                        }
                                    }
                                }
                                return $t_aux_page;
                            }
                            ?>
                            <ul class="nav-list">
                                <?php echo get_top_menu($tree_menus, $tree_pages,  $tree_categories,  isset($page_t)?$page_t:array(), 1, $page_url, $module, $site->pages->get_full_link_module('catalog')); ?>
                            </ul>
                        </nav>
                        <!-- main navigation end -->
                    </div>
                    <!-- nav area end -->
                </div>
                <!-- max-wrap end -->
            </header>
            <!-- header end -->

            <!-- main -->
            <div class="main">
                <!-- max-wrap -->
                <div class="max-wrap">
                    <!-- main holder -->
                    <div class="main-holder">
                        <?php echo $content; ?>
                        <span class="bg-sidebar"></span>
                    </div>
                    <!-- main holder end -->
                </div>
                <!-- max-wrap end -->
            </div>
            <!-- main end -->

            <div class="spacer"></div>
        </div>
        <!-- wrapper end -->

        <!-- footer -->
        <footer class="footer">
            <!-- max-wrap -->
            <div class="max-wrap">
                <div class="footer-wrap">
                    <!-- footer holder -->
                    <div class="footer-holder">
                        <!-- logo footer -->
                        <strong class="logo-footer">
                            <?php if($module != 'main') { ?><a href="<?php echo SITE_URL; ?>"><?php } ?><?php echo $site->settings->site_title; ?><?php if($module != 'main') { ?></a><?php } ?>
                        </strong>
                        <!-- logo footer end -->

                        <!-- footer info -->
                        <div class="footer-info">
                            <span class="copyright">&copy; <?php echo date('Y'); ?>, <?php if($module != 'main') { ?><a href="<?php echo SITE_URL; ?>"><?php } ?><?php echo $site->settings->site_title; ?><?php if($module != 'main') { ?></a><?php } ?> </span>
                            <p><?php echo $site->settings->site_description; ?></p>
                        </div>
                        <!-- footer info end -->
                    </div>
                    <!-- footer holder end -->

                    <!-- footer links -->
                    <div class="footer-links">
                        <!-- footer list -->
                        <ul class="footer-list">
                           <?php echo $site->pages->get_list_menus($tree_menus, $tree_pages, 2); ?>
                        </ul>
                        <!-- footer list end -->

                        <!-- user links -->
                        <div class="user-links">
                            <ul class="link-list">
                                <?php if($site->settings->site_phone) { ?><li class="phones"><i class="icon-handset"></i><?php echo $site->settings->site_phone; ?></li><?php } ?>
                                <?php if($site->settings->site_email) { ?><li><a href="mailto:<?php echo $site->settings->site_email; ?>"><i class="icon-email"></i><span><?php echo $site->settings->site_email; ?></span></a></li><?php } ?>
                            </ul>

                            <!-- social networks -->
                            <ul class="social-networks">
                                <?php if($site->settings->vk_link) { ?><li><a href="<?php echo $site->settings->vk_link; ?>" class="soc-icon-vk">vk</a></li><?php } ?>
                                <?php if($site->settings->facebook_link) { ?><li><a href="<?php echo $site->settings->facebook_link; ?>" class="soc-icon-facebook">facebook</a></li><?php } ?>
                                <?php if($site->settings->twitter_link) { ?><li><a href="<?php echo $site->settings->twitter_link; ?>" class="soc-icon-twitter">twitter</a></li><?php } ?>
                                <?php if($site->settings->google_link) { ?><li><a href="<?php echo $site->settings->vk_link; ?>" class="soc-icon-google-plus">google-plus</a></li><?php } ?>
                            </ul>
                            <!-- social networks end -->
                            <a href="http://unixar.ru" target="_blank" class="dev" title="Создание, продвижение и поддержка сайтов в Unixar"><span>Создание сайта</span></a>
                        </div>
                        <!-- user links end -->
                    </div>
                    <!-- footer links end -->
                </div>
            </div>
            <!-- max-wrap end -->
        </footer>
        <!-- footer end -->
        <?php echo $site->settings->counters_code; ?>
        <?php	
			if(ADMINS_HAT)
			{
				$site->tpl->in_admin();
				$site->tpl->display("admins_hat");
				$site->tpl->in_user();
			}
		?>
    </body>
</html>
*/
