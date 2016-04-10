<?php $site->tpl->display('list_revisions'); ?>
                
				<h1><img class="page-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <?php if(isset($page_t['id']) and $page_t['id']>0) { ?>Редактировать<?php } else { ?>Добавить<?php } ?> страницу</h1>

                <form action="<?php echo DIR_ADMIN; ?>?module=pages&action=edit" method="post" enctype="multipart/form-data">
                <?php if(isset($page_t['id'])) { ?><input type="hidden" name="id" value="<?php echo $page_t['id'];?>"><?php } ?>
				
				<div class="tabs">
					<ul class="bookmarks">
						<li <?php if($tab_active=="main")  { ?>class="active"<?php } ?>><a href="#" data-name="main">Содержание</a></li>
						<li <?php if($tab_active=="photo")  { ?>class="active"<?php } ?>><a href="#" data-name="photo">Фото</a></li>
						<li <?php if($tab_active=="files")  { ?>class="active"<?php } ?>><a href="#" data-name="files">Файлы</a></li>
						<li <?php if($tab_active=="seo")  { ?>class="active"<?php } ?>><a href="#" data-name="seo">SEO</a></li>
						<li <?php if($tab_active=="other")  { ?>class="active"<?php } ?>><a href="#" data-name="other">Другие поля</a></li>
					</ul>

					<div class="tab-content">
											
							<ul class="form-lines wide left">
								<li>
									<label for="page-caption">Заголовок страницы</label>
									<div class="input text <?php if(isset($errors['title'])) echo "fail";?>">
										<input type="text" id="page-caption" name="title" <?php if(!isset($page_t['id']) or $page_t['id']<1) { ?>class="title_for_slug"<?php } ?> value="<?php if(isset($page_t['title'])) echo $page_t['title'];?>"/>
	                                    <?php if(isset($errors['title'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
								<li>
									<label for="subcaption">Полный заголовок страницы <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title="Если указан, будет выведен в качестве заголовка h1 страницы, а поле Заголовок страницы будет использовано только в названии страницы в меню."/></label>
									<div class="input text">
										<input type="text" id="subcaption" name="title_first" value="<?php if(isset($page_t['title_first'])) echo $page_t['title_first'];?>"/>
									</div>
								</li>
								<li>
									<label>Родительская страница</label>
									<div class="input">
										<select class="select" name="parent">
											<option value="0">Корень</option>
                                            <?php 
												function list_pages_inp($tree_pages, $page_t, $sel=0, $parent=0, $nbsp="") {
													$list = "";
													if(isset($tree_pages["tree"][$parent]) and is_array($tree_pages["tree"][$parent])) {
														foreach($tree_pages["tree"][$parent] as $page_id) {
															if($tree_pages["all"][$page_id]['nesting'] and $page_t['id']!=$page_id) {
																$list .= '<option value="'.$page_id.'"';
																if($page_id == $sel) $list .= ' selected="true"';
																$list .= ">".$nbsp.$tree_pages["all"][$page_id]['title']."</option>";
																$list .= list_pages_inp($tree_pages, $page_t, $sel, $page_id, $nbsp."&nbsp;&nbsp;");
															}
														}
													}
													return $list;
												}
												echo list_pages_inp($tree_pages, $page_t, $page_t['parent']);
											?>
										</select>
									</div>
								</li>
							</ul>
							
							<ul class="form-lines narrow right">
								<li>
									<label>Статус страницы</label>
									<div class="input">
										<select class="select" name="enabled">
											<option value="1" <?php if(isset($page_t['enabled']) and $page_t['enabled']==1) echo "selected";?>>Опубликована</option>
											<option value="0" <?php if(isset($page_t['enabled']) and $page_t['enabled']==0) echo "selected";?>>Скрыта</option>
										</select>
									</div>
								</li>
								<input type="hidden" id="page-position" name="sort" value="<?php if(isset($page_t['sort'])) echo $page_t['sort'];?>"/>
							</ul>
							
							<div class="clear"></div>
							
							<label>Содержимое страницы</label>
							<div class="frame editor">
								<textarea name="body" id="body"><?php if(isset($page_t['body'])) echo $page_t['body'];?></textarea>
                                <script>
									CKEDITOR.replace( 'body', {height: 500} );
								</script>
							</div>
							
						
					</div><!-- .tab-content end -->
					
					<div class="tab-content">
						<?php $site->tpl->display('content_photos'); ?>
					</div><!-- .tab-content end -->
                    
					<div class="tab-content">
						<?php $site->tpl->display('content_files'); ?>
					</div><!-- .tab-content end -->
                    
					<div class="tab-content ">
						<ul class="form-lines wide">
							<li>
									<label for="page-meta-title">Заголовок страницы</label>
									<div class="input text ">
										<input class="seo-input" type="text" id="page-meta-title" name="meta_title" value="<?php if(isset($page_t['meta_title'])) echo $page_t['meta_title'];?>"/>
									</div>
							</li>
							<li>
								<label>Описание страницы (meta description)</label>
								<div class="input textarea">
									<textarea class="seo-input" cols="30" rows="10" name="meta_description"><?php if(isset($page_t['meta_description'])) echo $page_t['meta_description'];?></textarea>
								</div>
								<p class="small">рекомендуется не больше 250 символов</p>
							</li>
							<li>
								<label>Ключевые слова (meta keywords)</label>
								<div class="input textarea">
									<textarea class="seo-input" cols="30" rows="10" name="meta_keywords"><?php if(isset($page_t['meta_keywords'])) echo $page_t['meta_keywords'];?></textarea>
								</div>
								<p class="small">все слова пишутся через запятую, слова должны встречаться в тексте, рекомендуется не больше 10 слов</p>
							</li>
						</ul>
					</div><!-- .tab-content end -->
					<div class="tab-content">
						<ul class="form-lines wide left">
							<li>
									<label for="page-url">URL <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title='имя файла должно содержать только латинские символы и символы "_", "-", ".".' /></label>
									<div class="input text <?php if(isset($errors['url'])) echo "fail";?>">
										<input type="text" id="page-url" name="url" class="url_slug" value="<?php if(isset($page_t['url'])) echo $page_t['url'];?>"/>
	                                    <?php if(isset($errors['url']) and $errors['url']=="no_url") { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
	                                    <?php if(isset($errors['url']) and $errors['url']=="error_url") { ;?><p class="error">недопустимый URL</p><?php } ?>
									</div>
							</li>
							<li>
									<label for="topage">Ссылка на другую страницу <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title="Если указана, то при открытии данной страницы произойдет автоматический редирект на указанную."/></label>
									<div class="input text">
										<input type="text" id="topage" name="topage" value="<?php if(isset($page_t['topage'])) echo $page_t['topage'];?>"/>
									</div>
							</li>
								<li>
									<label>Модуль</label>
									<div class="input">
										<select class="select" name="module">
											<option value="">----</option>
                                            <?php foreach($modules as $t_module) { ?>
											<option value="<?php echo $t_module['id']; ?>"  <?php if( isset($page_t['module']) and $page_t['module']==$t_module['id']) echo "selected"; ?>><?php echo $t_module['name'];?></option>
                                            <?php } ?>
										</select>
									</div>
								</li>
						</ul>
                        <ul class="form-lines narrow right">
							<li>
									<label><input type="checkbox" name="nomenu" value="1" <?php if(isset($page_t['nomenu']) and $page_t['nomenu']==1) echo "checked";?> /> Не показывать в меню</label>
							</li>
							<li>
									<label><input type="checkbox" name="nohead" value="1" <?php if(isset($page_t['nohead']) and $page_t['nohead']==1) echo "checked";?> /> Отключить шаблон <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title="Не будет добавляться шапка и подвал страницы, работает как самостоятельная страница. "/></label>
							</li>
                            <li>
									<label>Шаблон</label>
									<div class="input">
										<select class="select" name="template">
											<option value="" <?php if(isset($page_t['template']) and $page_t['template']=="") echo "selected";?>>Стандартный</option>
											<?php
												$templateNames = $site->pages->GetRussianNamesOfTpl();
												foreach($templateNames as $val){
											?>
											<option value="<?php echo $val['real']; ?>" <?php if(isset($page_t['template']) and $page_t['template']==$val['real']) echo "selected";?>><?php echo $val['found']; ?></option>
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
					<?php if(isset($page_t['id']) and $page_t['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="pages" data-text="Вы действительно хотите удалить эту страницу?" data-url="<?php echo DIR_ADMIN; ?>?module=pages&action=delete&id=<?php echo $page_t['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить страницу</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>