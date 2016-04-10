<!DOCTYPE HTML>
<html lang="en-US">
<head>
	<meta charset="UTF-8">
	<title>Система управления <?php echo $this->settings->site_title; ?></title>
	
	<!--[if lt IE 9]><script src="<?php echo $dir_js;?>html5shiv.js"></script><![endif]-->
	
	<link rel="stylesheet" type="text/css" href="<?php echo $dir_css;?>jquery-ui-1.10.0.custom.css" media="all"/>
	<link rel="stylesheet" type="text/css" href="<?php echo $dir_css;?>jquery.multiselect.css" media="all"/>
	<!-- Main CSS file -->
	<link rel="stylesheet" type="text/css" href="<?php echo $dir_css;?>main.css" media="all"/>
	<link rel="stylesheet" type="text/css" href="<?php echo $dir_js;?>autocomplete/styles.css" media="all"/>
	<link rel="stylesheet" type="text/css" href="<?php echo SITE_URL;?>templates/css/styles_edit.css" media="all"/>
	
	<script src="<?php echo $dir_js;?>jquery-1.9.0.min.js"></script>
	<script src="<?php echo $dir_js;?>jquery.history.js"></script>
	<script src="<?php echo $dir_js;?>jquery-ui-1.10.0.custom.min.js"></script>
	<script src="<?php echo $dir_js;?>jquery.multiselect.min.js"></script>
	<script src="<?php echo $dir_js;?>jquery.tablesorter.min.js"></script>
	<script src="<?php echo $dir_js;?>jquery.jcarousel.min.js"></script>
    <script src="<?php echo $dir_js;?>jquery.form.js"></script> 
    <script src="<?php echo $dir_js;?>jquery.ui.touch-punch.js"></script> 
    <script src="<?php echo $dir_js;?>jquery.mjs.nestedSortable.js"></script> 
    <script src="<?php echo $dir_js;?>plupload/plupload.js"></script> 
    <script src="<?php echo $dir_js;?>plupload/plupload.flash.js"></script> 
    <script src="<?php echo $dir_js;?>plupload/plupload.html5.js"></script> 
    <script src="<?php echo $dir_js;?>plupload/plupload.html4.js"></script> 
    <script src="<?php echo $dir_js;?>plupload/i18n/ru.js"></script> 
    <script src="<?php echo $dir_js;?>autocomplete/jquery.autocomplete.min.js"></script> 
    <script>
		var site_url = "<?php echo SITE_URL;?>";
		var admin_url = "<?php echo DIR_ADMIN;?>";
		var dir_images= "<?php echo $dir_images;?>";
	</script>
	<!-- Main JS file -->
	<script src="<?php echo $dir_js;?>main.js"></script>
    <script src="<?php echo DIR_ADMIN; ?>ckeditor/ckeditor.js"></script>
</head>
<body>
	<div id="wrapper">
		<!-- Site header start -->
		<div id="header">
			<div class="fix-width">
				
				<div class="logo">
					<a href="<?php echo DIR_ADMIN; ?>">
						<span class="top">система управления</span>
						<span class="btm"><?php echo $site_host;?></span>
					</a>
				</div>
				<!--
				<form action="<?php echo DIR_ADMIN;?>" class="input search" method="get">
                	<input type="hidden" name="module" value="catalog">
                	<input type="hidden" name="action" value="products">
					<input autocomplete="off" id="quick_input_search" name="name" type="text" data-url="<?php echo DIR_ADMIN;?>?module=search&action=quick" placeholder="Поиск"/>
					<input type="submit" value=""/>
				</form>
				-->
				<ul class="top-menu">
					<li id="user-menu">
						<a href="<?php echo DIR_ADMIN; ?>?module=admins&action=profile" class="ajax_link" data-module="profile">
							<img class="ticon user-w" src="<?php echo $dir_images;?>icon.png" alt="user"/>
							Здравствуйте, <?php echo $admin['name'];?>
						</a>
						<div class="user-btn">
							<div class="menu-popup">
								<ul>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=admins&action=profile" class="ajax_link" data-module="profile">Личные настройки</a></li>
									<li><a href="<?php echo DIR_ADMIN; ?>?logout=1">Выход</a></li>
								</ul>
								<div class="top"></div>
							</div>
						</div>
					</li>
					<!--<li>
						<img class="ticon tool-w" src="<?php echo $dir_images;?>icon.png" alt="user"/>
						<a href="#">Помощь</a>
					</li>-->
					<li id="go_to_site">
						<img class="ticon arrow-w" src="<?php echo $dir_images;?>icon.png" alt="user"/>
						<a href="<?php echo SITE_URL;?>" target="_blank">Перейти на <?php echo $site_host;?></a>
					</li>
				</ul>
                <!--
                    <div id="quick_search_results">
                    	<div class="tooltip-corner"></div>
                        <div class="tooltip-container"></div>
                    </div>				
				-->
				
				<div class="clear"></div>
				
			</div><!-- .fix-width end -->
		</div>
		<!-- Site header end -->
		
		<div id="main" class="fix-width">
			
			<!-- Main site sidebar start -->
			<div id="sidebar">
				
				<!-- Menu start -->
				<div class="menu">
					<?php if($site->admins->get_level_access("pages")) { ?>
					<div class="menu-item <?php if($module=="pages") echo "active"; ?>" id="menu-module-pages">
						<a href="<?php echo DIR_ADMIN; ?>?module=pages" class="ajax_link" data-module="pages">
							<img class="micon article" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Страницы сайта</span>
						</a>
                        <?php if($site->admins->get_level_access("pages")==2) { ?>
						<div class="menu-btn">
							<div class="menu-popup">
								<ul>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=pages&action=add" class="ajax_link" data-module="pages">Добавить страницу</a></li>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=pages" class="ajax_link" data-module="pages">Все страницы</a></li>
								</ul>
								<div class="top"></div>
							</div>
						</div>
                        <?php } ?>
					</div>
                    <?php } ?>

				
					
					<?php if($site->admins->get_level_access("economic_news")) { ?>
					<div class="menu-item <?php if($module=="economic_news") echo "active"; ?>" id="menu-module-economic_news">
						<a href="<?php echo DIR_ADMIN; ?>?module=economic_news" class="ajax_link" data-module="economic_news">
							<img class="micon news" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Экономические новости</span>
						</a>
                        <?php if($site->admins->get_level_access("economic_news")==2) { ?>
						<div class="menu-btn">
							<div class="menu-popup">
								<ul>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=economic_news&action=add" class="ajax_link" data-module="economic_news">Добавить новость экономического календаря</a></li>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=economic_news" class="ajax_link" data-module="news">Экономический календарь</a></li>
								</ul>
								<div class="top"></div>
							</div>
						</div>
                        <?php } ?>
					</div>
                                    <ul class="menu-added <?php if($module=="economic_news") echo "active"; ?>" id="menu-added-module-economic_news">
							<li><a href="<?php echo DIR_ADMIN; ?>?module=economic_news" class="ajax_link" data-module="economic_news">Список новостей</a></li>
                                                        <li><a href="<?php echo DIR_ADMIN; ?>?module=economic_news&action=events" class="ajax_link" data-module="economic_news">Список событий</a></li>
                                    </ul>
                    <?php } ?>


					<?php if($site->admins->get_level_access("ordercall")) { 
						$new_ordercall_counter = intval($site->ordercall->get_count_calls( array("is_new"=>1) ));
					?>
					<div class="menu-item <?php if($module=="ordercall") echo "active"; ?>" id="menu-module-ordercall">
						<a href="<?php echo DIR_ADMIN; ?>?module=ordercall" class="ajax_link" data-module="ordercall">
							<img class="micon ordercall" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Заказ звонков<?php if($new_ordercall_counter>0) { ?><span class="counter"><?php echo $new_ordercall_counter;?></span><?php } ?></span>
						</a>
					</div>
                    <?php } ?>
					
                    <?php if($site->admins->get_level_access("menus")==2) { ?>
					<div class="menu-item <?php if($module=="menus") echo "active"; ?>" id="menu-module-menus">
						<a href="<?php echo DIR_ADMIN; ?>?module=menus" class="ajax_link" data-module="menus">
							<img class="micon menus" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Меню</span>
						</a>
						<div class="menu-btn">
							<div class="menu-popup">
								<ul>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=menus&action=add" class="ajax_link" data-module="menus">Добавить ссылку</a></li>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=menus" class="ajax_link" data-module="menus">Типы меню</a></li>
								</ul>
								<div class="top"></div>
							</div>
						</div>
					</div>
					
					<?php if(count($menus)): ?>
                      <ul class="menu-added <?php if($module=="menus") echo "active"; ?>" id="menu-added-module-menus">
                     		<?php  foreach($menus as $menu) {  ?>
							<li><a href="<?php echo DIR_ADMIN;?>?module=menus&action=menu_items&menu_id=<?php echo $menu['id'];?>" class="ajax_link" data-module="menus"><?php echo $menu['name']; ?></a></li>
                            <?php } ?>
                     </ul>
					<?php endif; ?>
                    <?php } ?>

		    <?php if($site->admins->get_level_access("slides")) { ?>
					<div class="menu-item <?php if($module=="slides") echo "active"; ?>" id="menu-module-slides">
						<a href="<?php echo DIR_ADMIN; ?>?module=slides" class="ajax_link" data-module="slides">
							<img class="micon slides" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Акции на главной</span>
						</a>
                        <?php if($site->admins->get_level_access("slides")==2) { ?>
						<div class="menu-btn">
							<div class="menu-popup">
								<ul>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=slides&action=add" class="ajax_link" data-module="slides">Добавить акцию</a></li>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=slides" class="ajax_link" data-module="slides">Все акции</a></li>
								</ul>
								<div class="top"></div>
							</div>
						</div>
                        <?php } ?>
					</div>
                    <?php } ?>
					
					<?php if($site->admins->get_level_access("antivirus") == 2) { 
						$new_notices = intval($site->antivirus->GetNumNotices());
						$new_alerts = count($site->antivirus->GetAlerts(true));
						$combined_notices = $new_notices + $new_alerts;
					?>
					<div class="menu-item <?php if($module=="antivirus") echo "active"; ?>" id="menu-module-antivirus">
						<a href="<?php echo DIR_ADMIN; ?>?module=antivirus" class="ajax_link" data-module="antivirus">
							<img class="micon security" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Защита<?php if($combined_notices>0) { ?><span class="counter"> ! </span><?php } ?></span>
						</a>
					</div>
						 <ul class="menu-added <?php if($module=="antivirus") echo "active"; ?>" id="menu-added-module-antivirus">
							<li><a href="<?php echo DIR_ADMIN; ?>?module=antivirus" class="ajax_link" data-module="antivirus">Статус защиты</a></li>
                            <li><a href="<?php echo DIR_ADMIN; ?>?module=antivirus&action=file_alert" class="ajax_link" data-module="antivirus">Защита файловой системы</a></li>
							<li><a href="<?php echo DIR_ADMIN; ?>?module=antivirus&action=injection_alert" class="ajax_link" data-module="antivirus">Монитор запросов</a></li>
							<li><a href="<?php echo DIR_ADMIN; ?>?module=antivirus&action=adminLogin_alert" class="ajax_link" data-module="antivirus">Контроль авторизации</a></li>
                        </ul>
					
                    <?php } ?>
					
                    <?php if($site->admins->get_level_access("settings")==2) { ?>
					<div class="menu-item <?php if($module=="settings") echo "active"; ?>" id="menu-module-settings">
						<a href="<?php echo DIR_ADMIN; ?>?module=settings&action=index" class="ajax_link" data-module="settings">
                          <img class="micon tools" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Настройки</span>
						</a>
                                        </div>
					
                    <?php } ?>
                    
                    <?php if($site->admins->get_level_access("admins")) { ?>
					<div class="menu-item <?php if($module=="admins" and $action!="profile") echo "active"; ?>" id="menu-module-admins">
						<a href="<?php echo DIR_ADMIN; ?>?module=admins&action=index" class="ajax_link" data-module="admins">
							<img class="micon admins" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Администраторы</span>
						</a>
                        <?php if($site->admins->get_level_access("admins")==2) { ?>
						<div class="menu-btn">
							<div class="menu-popup">
								<ul>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=admins&action=add" class="ajax_link" data-module="admins">Добавить админа</a></li>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=admins&action=groups" class="ajax_link" data-module="admins">Группы админов</a></li>
								</ul>
								<div class="top"></div>
							</div>
						</div>
                        <?php } ?>
					</div>
                    <?php if($site->admins->get_level_access("admins")==2) { ?>
                    <ul class="menu-added <?php if($module=="admins" and $action!="profile") echo "active"; ?>" id="menu-added-module-admins">
						<li><a href="<?php echo DIR_ADMIN; ?>?module=admins" class="ajax_link" data-module="admins">Администраторы</a></li>
						<li><a href="<?php echo DIR_ADMIN; ?>?module=admins&action=groups" class="ajax_link" data-module="admins">Группы админов</a></li>
					</ul>
					<?php }
					}  
					?>

                    <?php if($site->admins->get_level_access("tools")==2) { ?>
					<div class="menu-item <?php if($module=="tools") echo "active"; ?>" id="menu-module-tools">
						<a href="<?php echo DIR_ADMIN; ?>?module=tools&action=index" class="ajax_link" data-module="tools">
                          <img class="micon tools" src="<?php echo $dir_images;?>icon.png" alt="icon"/>
							<span class="clip">Инструменты</span>
						</a>
					</div>
                    <?php } ?>
				</div>
				<!-- Menu end -->
				
				  <?php
                  if(!$this->settings->seo_promo_disabled && ($this->settings->seo_promo_start_date - time() <= 0)){
                      $query = array();
                      @$results = unserialize($this->settings->seo_promo_results);
                      $available = array();
                      if($results)
                          foreach($results as $item)
                              if($item['number'] > 20)
                                  $available[] = $item;
                      if($available){
                          shuffle($available);
                          $query = $available[0];
                      }
                      if($query){
                          ?>
                          <div class="seopromo">
                                      <div class="title-promo"><img class="seopromo-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/>Метрика сайта</div>
                                      <div class="body-promo">
                                      	  <p><span>Ваш сайт</span>  в Яндексе по поисковому запросу
                                          &laquo;<span><?php echo trim($query['query']); ?></span>&raquo;
                                          <a href="http://yandex.ru/yandsearch?lr=<?php echo $query['region']; ?>&text=<?php echo urlencode($query['query']); ?>&p=<?php echo floor($query['number']/10);?>" target="_blank">
                                          занимает <?php echo $query['number'] < 201?$query['number']:'более чем 200'; ?> место</a>.</p>
                                          
                                          <p>Вы можете заказать поисковое продвижение и посещаемость сайта <span>увеличится в
                                          <?php echo $query['poss_pro'].' '.F::get_right_okonch($query['poss_pro'],'раз','раз','раза'); ?></span></p>
                                      </div>
                                      <span class="btn standart-size green">
                                        <a href="http://unixar.ru/order_seo/?utm_source=unixar&utm_medium=CPC&utm_campaign=adminseo&utm_term=<?php echo urlencode($query['query']); ?>#contacts" class="button" target="_blank">
                                            <span><img class="bicon up-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Поднять сайт</span>
                                        </a>
                                    </span>
                           </div>
                     <?php
                      }
                  }
              ?>

			</div>
			<!-- Main site sidebar end -->
			
			<!-- Main site content start -->
			<div id="content">
            	<div id="contentHelper">
				<?php echo $content; ?>
                </div>
                <div class="clear"></div>
            </div>
			<!-- Main site content start -->
			
			<div class="clear"></div>
		</div><!-- #main end -->
		
	</div><!-- #wrapper end -->
	<?php
			if(!$this->settings->is_conveyer_disabled){
                            //general conveyer
                             $generalConveyer = new Conveyers("general", "console");
                             if(!$generalConveyer->ExecCommand("check")){
                                    $generalConveyer = new Conveyers("general", "force_start");
                                    $generalConveyer->Run(SITE_URL."cron/conveyers/general/minor.php", false);
                             }
                             //end general conveyer
                             $this->antivirus->Run(true);     
                        }
    ?>
</body>
</html>