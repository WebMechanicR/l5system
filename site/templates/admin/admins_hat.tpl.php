<?php
			$page_url_for_admin_hat = false;
						
			if($module == 'catalog' and $action == 'show_category' and isset($category)) {
				$page_url_for_admin_hat = DIR_ADMIN.'?module=catalog&action=edit_category&id='.$category['id'];
				$page_name_for_admin_hat = "Редактировать категорию";
			}
			elseif($module == 'catalog' and $action == 'show_product' and isset($product)) {
				$page_url_for_admin_hat = DIR_ADMIN.'?module=catalog&action=edit_product&id='.$product['id'];
				$page_name_for_admin_hat = "Редактировать товар";
			}
			elseif($module == 'news' and $action == 'show_news' and isset($news)) {
				$page_url_for_admin_hat = DIR_ADMIN.'?module=news&action=edit&id='.$news['id'];
				$page_name_for_admin_hat = "Редактировать новость";
			}
			else {
				if(!isset($page_t) and isset($page_url) and $page_url!='') {
						$page_t = $site->pages->get_page_withcache($page_url);
				}
				if(isset($page_t) and isset($page_t['id'])) {
					$page_url_for_admin_hat = DIR_ADMIN.'?module=pages&action=edit&id='.$page_t['id'];
					$page_name_for_admin_hat = "Редактировать страницу";
				}
			}

?>
<div id="admin_hat">
	<div class="fix-width">            
				<div class="logoA">
					<a href="<?php echo DIR_ADMIN; ?>" target="_blank">
						<span class="top">система управления</span>
						<span class="btm"><?php echo $site_host;?></span>
					</a>
				</div>
				<ul class="top-menu">
				<?php
					if(
						($site->admins->get_level_access("pages")==2) or
						($site->admins->get_level_access("catalog")==2) or
						($site->admins->get_level_access("news")==2) or
						($site->admins->get_level_access("slides")==2) or
						($site->admins->get_level_access("menus")==2) or
						($site->admins->get_level_access("admins")==2)
					) {
				?>
                	<li>
						<span>
							<img class="ticon user-add-page" src="<?php echo $admin_dir_images;?>icon.png" alt="user"/>
							Добавить
						</span>
						<div class="user-btn">
							<div class="menu-popup">
								<ul>
                                    <?php if($site->admins->get_level_access("catalog")==2) { ?>
                                        <li><a href="<?php echo DIR_ADMIN; ?>?module=catalog&action=add_product" target="_blank">Новый товар</a></li>
                                        <li><a href="<?php echo DIR_ADMIN; ?>?module=catalog&action=add_category" target="_blank">Категорию</a></li>
                                    <?php } ?>
									<?php if($site->admins->get_level_access("pages")==2) { ?>
                                        <li><a href="<?php echo DIR_ADMIN; ?>?module=pages&action=add" target="_blank">Страницу сайта</a></li>	
                                    <?php } ?>
                                    <?php if($site->admins->get_level_access("news")==2) { ?>
                                        <li><a href="<?php echo DIR_ADMIN; ?>?module=news&action=add" target="_blank">Новость</a></li>	
                                    <?php } ?>
                                    <?php if($site->admins->get_level_access("slides")==2) { ?>
                                        <li><a href="<?php echo DIR_ADMIN; ?>?module=slides&action=add" target="_blank">Акцию на главную</a></li>	
                                    <?php } ?>
								</ul>
								<div class="top"></div>
							</div>
						</div>
					</li>
				<?php } ?>
				<?php if($page_url_for_admin_hat) { ?>
					<li class="no_sub_menu">
						<a href="<?php echo $page_url_for_admin_hat; ?>" target="_blank">
							<img class="ticon user-edit-page" src="<?php echo $admin_dir_images;?>icon.png" alt="user"/>
							<?php echo $page_name_for_admin_hat;?>
						</a>
                   </li>
				<?php } ?>
				<?php 
					if($site->admins->get_level_access("orders")) {
						$new_orders_counter = intval($site->orders->get_count_orders( array("status"=>0) ));
				?>
                	<li id="tmenu-module-orders" class="no_sub_menu">
                        <a href="<?php echo DIR_ADMIN; ?>?module=orders" target="_blank">
                        	<img class="ticon user-orders" src="<?php echo $admin_dir_images;?>icon.png" alt="user"/>
                            Заказы<?php if($new_orders_counter>0) { ?><i class="counter"><?php echo $new_orders_counter;?></i><?php } ?>
                        </a>
                    </li>
                <?php } ?>

				<?php
                	if($site->admins->get_level_access("ordercall")) {
						$new_ordercall_counter = intval($site->ordercall->get_count_calls( array("is_new"=>1) ));
				?>
					<li id="tmenu-module-ordercall" class="no_sub_menu">
                        <a href="<?php echo DIR_ADMIN; ?>?module=ordercall" target="_blank">
                        	<img class="ticon user-ordercall" src="<?php echo $admin_dir_images;?>icon.png" alt="user"/>
                            Заказ звонков<?php if($new_ordercall_counter>0) { ?><i class="counter"><?php echo $new_ordercall_counter;?></i><?php } ?>
                        </a>
					</li>
                <?php } ?>
                	<li id="admin-hat-user-menu">
						<a href="<?php echo DIR_ADMIN; ?>?module=admins&action=profile">
							<img class="ticon user-w" src="<?php echo $admin_dir_images;?>icon.png" alt="user"/>
							Здравствуйте, <?php echo $admin['name'];?>
						</a>
						<div class="user-btn">
							<div class="menu-popup">
								<ul>
									<li><a href="<?php echo DIR_ADMIN; ?>?module=admins&action=profile" target="_blank">Личные настройки</a></li>
									<li><a href="<?php echo DIR_ADMIN; ?>?logout=1">Выход</a></li>
								</ul>
								<div class="top"></div>
							</div>
						</div>
					</li>
				</ul>
								
				<div class="clear"></div>
				
	</div>
</div>
<script>
	function update_adminhat_newcount_module(module, count) {
		$('#tmenu-module-'+module+' .counter').remove();
		if(count>0) $('#tmenu-module-'+module+' a').append('<i class="counter">'+count+'</i>');
	}
	
	var admin_hat_timer = 30;//время обновления счетчиков в секундах
	
	setInterval(function() {
		$.get('<?php echo DIR_ADMIN; ?>ajax_newcount_module.php', {module: 'orders', action: 'get_count_new'}, function(data) {
			update_adminhat_newcount_module('orders', data);
		});

		$.get('<?php echo DIR_ADMIN; ?>ajax_newcount_module.php', {module: 'ordercall', action: 'get_count_new'}, function(data) {
			update_adminhat_newcount_module('ordercall', data);
		});
	}, admin_hat_timer*1000);
</script>