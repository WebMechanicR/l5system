<?php $site->tpl->display('list_revisions'); ?>
                
				<h1><img class="menus-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <?php if(isset($menu_item['id']) and $menu_item['id']>0) { ?>Редактировать<?php } else { ?>Добавить<?php } ?> ссылку</h1>

                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit" method="post" enctype="multipart/form-data">
                <?php if(isset($menu_item['id'])) { ?><input type="hidden" name="id" value="<?php echo $menu_item['id'];?>"><?php } ?>
				
				<div class="tabs">
					<ul class="bookmarks">
						<li class="active"><a href="#" data-name="main">Содержание</a></li>
					</ul>

					<div class="tab-content">
											
							<ul class="form-lines wide left">
								<li>
									<label for="page-caption">Название</label>
									<div class="input text <?php if(isset($errors['title'])) echo "fail";?>">
										<input type="text" id="page-caption" name="title" value="<?php if(isset($menu_item['title'])) echo $menu_item['title'];?>"/>
	                                    <?php if(isset($errors['title'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
								<li>
									<label for="subcaption">Атрибут title</label>
									<div class="input text">
										<input type="text" id="subcaption" name="title2" value="<?php if(isset($menu_item['title2'])) echo $menu_item['title2'];?>"/>
									</div>
								</li>
								<li>
									<label>Страница</label>
									<div class="input">
										<select class="select" name="page_id">
											<option value="0">----</option>
                                            <?php 
												function list_pages_inp($tree_pages, $menu_item, $sel=0, $parent=0, $nbsp="") {
													$list = "";
													if(isset($tree_pages["tree"][$parent]) and is_array($tree_pages["tree"][$parent])) {
														foreach($tree_pages["tree"][$parent] as $page_id) {
																$list .= '<option value="'.$page_id.'"';
																if($page_id == $sel) $list .= ' selected="true"';
																$list .= ">".$nbsp.$tree_pages["all"][$page_id]['title']."</option>";
																$list .= list_pages_inp($tree_pages, $menu_item, $sel, $page_id, $nbsp."&nbsp;&nbsp;");
														}
													}
													return $list;
												}
												echo list_pages_inp($tree_pages, $menu_item, (isset($menu_item['page_id'])?$menu_item['page_id']:array()));
											?>
										</select>
									</div>
								</li>
                                <li>
                                        <label for="page-url">Или  URL</label>
                                        <div class="input text <?php if(isset($errors['url'])) echo "fail";?>">
                                            <input type="text" id="page-url" name="url" class="url_slug" value="<?php if(isset($menu_item['url'])) echo $menu_item['url'];?>"/>
                                            <?php if(isset($errors['url']) and $errors['url']=="no_url") { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                                            <?php if(isset($errors['url']) and $errors['url']=="error_url") { ;?><p class="error">недопустимый URL</p><?php } ?>
                                        </div>
                                </li>
								<li>
									<label>Родительский пункт меню</label>
									<div class="input">
										<select class="select" name="parent">
											<option value="0">Корень</option>
                                            <?php 
												function list_menus_inp($tree_menus, $menu_item, $sel=0, $parent=0, $nbsp="") {
													$list = "";
													if(isset($tree_menus["tree"][ $menu_item['menu_id'] ][$parent]) and is_array($tree_menus["tree"][ $menu_item['menu_id'] ][$parent])) {
														foreach($tree_menus["tree"][ $menu_item['menu_id'] ][$parent] as $page_id) {
															if( $menu_item['id']!=$page_id) {
																$list .= '<option value="'.$page_id.'"';
																if($page_id == $sel) $list .= ' selected="true"';
																$list .= ">".$nbsp.$tree_menus["all"][$page_id]['title']."</option>";
																$list .= list_menus_inp($tree_menus, $menu_item, $sel, $page_id, $nbsp."&nbsp;&nbsp;");
															}
														}
													}
													return $list;
												}
												echo list_menus_inp($tree_menus, $menu_item, $menu_item['parent']);
											?>
										</select>
									</div>
								</li>
							</ul>
							
							<ul class="form-lines narrow right">
								<li>
									<label>Статус</label>
									<div class="input">
										<select class="select" name="enabled">
											<option value="1" <?php if(isset($menu_item['enabled']) and $menu_item['enabled']==1) echo "selected";?>>Опубликована</option>
											<option value="0" <?php if(isset($menu_item['enabled']) and $menu_item['enabled']==0) echo "selected";?>>Скрыта</option>
										</select>
									</div>
								</li>
								<li>
									<label for="page-position">Позиция</label>
									<div class="input text">
										<input type="text" id="page-position" name="sort" value="<?php if(isset($menu_item['sort'])) echo $menu_item['sort'];?>"/>
									</div>
								</li>
								<li>
									<label>Меню</label>
									<div class="input">
										<select class="select" name="menu_id">
											<?php  foreach($menus as $menu) {  ?>
                                            <option value="<?php echo $menu['id'];?>" <?php if(isset($menu_item['menu_id']) and $menu_item['menu_id']==$menu['id']) echo "selected";?>><?php echo $menu['name']; ?></option>
                                            <?php } ?>
										</select>
									</div>
								</li>
							</ul>
							
							<div class="clear"></div>
							
						
					</div><!-- .tab-content end -->
										
				</div><!-- .tabs end -->
				
				<div class="bt-set clip">
                	<div class="left">
						<span class="btn standart-size blue hide-icon">
                        	<button class="ajax_submit" data-success-name="Cохранено">
                                <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <i>Сохранить</i></span>
                            </button>
						</span>
                        <span class="btn standart-size blue hide-icon">
							<button class="submit_and_exit">
								<span>Сохранить и выйти</span>
							</button>
						</span>
                   </div>
					<?php if(isset($menu_item['id']) and $menu_item['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="pages" data-text="Вы действительно хотите удалить эту ссылку?" data-url="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=delete&id=<?php echo $menu_item['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить ссылку</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>
                <script>
					$(function() {
						$('select[name="page_id"]').change(function() {
							if(!$('#page-caption').val().length && $(this).val()>0) {
								var name = $(this).find('option:selected').text();
								$('#page-caption').val( trim(name) );
							}
						});
					});
				</script>