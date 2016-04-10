			<h1><img class="catalog-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <?php if(isset($category_t['id']) and $category_t['id']>0) { ?>Редактировать<?php } else { ?>Добавить<?php } ?> категорию</h1>

                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit_category" method="post" enctype="multipart/form-data">
                <?php if(isset($category_t['id'])) { ?><input type="hidden" name="id" value="<?php echo $category_t['id'];?>"><?php } ?>
				
				<div class="tabs">
					<ul class="bookmarks">
						<li <?php if($tab_active=="main")  { ?>class="active"<?php } ?>><a href="#" data-name="main">Содержание</a></li>
						<li <?php if($tab_active=="seo")  { ?>class="active"<?php } ?>><a href="#" data-name="seo">SEO</a></li>
					</ul>

					<div class="tab-content">
											
							<ul class="form-lines wide left">
								<li>
									<label for="page-caption">Название</label>
									<div class="input text <?php if(isset($errors['title'])) echo "fail";?>">
										<input type="text" id="page-caption" name="title" <?php if(!isset($category_t['id']) or $category_t['id']<1) { ?>class="title_for_slug"<?php } ?> value="<?php if(isset($category_t['title'])) echo $category_t['title'];?>"/>
	                                    <?php if(isset($errors['title'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
                                <!--
								<li>
									<label for="page-title-full">Полное название</label>
									<div class="input text ">
										<input type="text" id="page-title-full" name="title_full" value="<?php if(isset($category_t['title_full'])) echo $category_t['title_full'];?>"/>
									</div>
								</li>
                                -->
								<li>
									<label>Родительская категория</label>
									<div class="input">
										<select class="select" name="parent">
											<option value="0">Корень</option>
                                            <?php 
												function list_categs_inp($tree_categories, $category_t, $sel=0, $parent=0, $nbsp="") {
													$list = "";
													if(isset($tree_categories["tree"][$parent]) and is_array($tree_categories["tree"][$parent])) {
														foreach($tree_categories["tree"][$parent] as $category_id) {
															if($category_t['id']!=$category_id) {
																$list .= '<option value="'.$category_id.'"';
																if($category_id == $sel) $list .= ' selected="true"';
																$list .= ">".$nbsp.$tree_categories["all"][$category_id]['title']."</option>";
																$list .= list_categs_inp($tree_categories, $category_t, $sel, $category_id, $nbsp."&nbsp;&nbsp;");
															}
														}
													}
													return $list;
												}
												echo list_categs_inp($tree_categories, $category_t, $category_t['parent']);
											?>
										</select>
									</div>
								</li>
                               <li>
									<label for="page-url">URL <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title='имя файла должно содержать только латинские символы и символы "_", "-", ".".' /></label>
									<div class="input text <?php if(isset($errors['url'])) echo "fail";?>">
										<input type="text" id="page-url" name="url" class="url_slug" value="<?php if(isset($category_t['url'])) echo $category_t['url'];?>"/>
	                                    <?php if(isset($errors['url']) and $errors['url']=="no_url") { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
	                                    <?php if(isset($errors['url']) and $errors['url']=="error_url") { ;?><p class="error">недопустимый URL</p><?php } ?>
									</div>
								</li>
								<li>
									<label>Картинка</label>
                                    <?php if(isset($category_t['img']) and $category_t['img']!="") { ?>
                                    <div class="one_image">
	                                    <input type="hidden" name="img" value="<?php if(isset($category_t['img'])) echo $category_t['img'];?>"/>
										<img src="<?php echo $content_photos_dir."normal/".$category_t['img'];?>" alt=""><br>
                                        <a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&id=<?php echo $category_t['id']; ?>&action=delete_category_image" class="delete-confirm delete-one-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это изображение?" title="Удалить">Удалить изображение</a>
                                    </div>
                                    <?php } ?>
									<div class="input input_smart_file">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файл</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
                                        <input type="file" accept="image/jpeg,image/png,image/gif" name="picture">
                                    </div>
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_type') { ;?><p class="error">неверный тип файла</p><?php } ?>
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_size') { ;?><p class="error">слишком большой файл</p><?php } ?>
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_upload') { ;?><p class="error">папка загрузки недоступна для записи или недостаточно места</p><?php } ?>
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_internal') { ;?><p class="error">внутренняя ошибка сервера</p><?php } ?>
								</li>
							</ul>
							
							<ul class="form-lines narrow right">
								<li>
									<label>Статус</label>
									<div class="input">
										<select class="select" name="enabled">
											<option value="1" <?php if(isset($category_t['enabled']) and $category_t['enabled']==1) echo "selected";?>>Опубликована</option>
											<option value="0" <?php if(isset($category_t['enabled']) and $category_t['enabled']==0) echo "selected";?>>Скрыта</option>
										</select>
									</div>
								</li>

								<li>
									<label for="page-viewed">Просмотров</label>
									<div class="input text">
										<input type="text" id="page-viewed" name="viewed" value="<?php if(isset($category_t['viewed'])) echo $category_t['viewed'];?>"/>
                                        <input type="hidden" id="page-position" name="sort" value="<?php if(isset($category_t['sort'])) echo $category_t['sort'];?>"/>
									</div>
								</li>
							</ul>
							
							<div class="clear"></div>

							<label>Описание</label>
							<div class="frame editor">
								<textarea name="body" id="body"><?php if(isset($category_t['body'])) echo $category_t['body'];?></textarea>
                                <script>
									CKEDITOR.replace( 'body', {height: 500} );
								</script>
							</div>
						
					</div><!-- .tab-content end -->
					
					<div class="tab-content ">
						<ul class="form-lines wide">
							<li>
									<label for="page-meta-title">Заголовок страницы</label>
									<div class="input text ">
										<input class="seo-input" type="text" id="page-meta-title" name="meta_title" value="<?php if(isset($category_t['meta_title'])) echo $category_t['meta_title'];?>"/>
									</div>
							</li>
							<li>
								<label>Описание страницы (meta description)</label>
								<div class="input textarea">
									<textarea class="seo-input" cols="30" rows="10" name="meta_description"><?php if(isset($category_t['meta_description'])) echo $category_t['meta_description'];?></textarea>
								</div>
								<p class="small">рекомендуется не больше 250 символов</p>
							</li>
							<li>
								<label>Ключевые слова (meta keywords)</label>
								<div class="input textarea">
									<textarea class="seo-input" cols="30" rows="10" name="meta_keywords"><?php if(isset($category_t['meta_keywords'])) echo $category_t['meta_keywords'];?></textarea>
								</div>
								<p class="small">все слова пишутся через запятую, слова должны встречаться в тексте, рекомендуется не больше 10 слов</p>
							</li>
						</ul>
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
					<?php if(isset($category_t['id']) and $category_t['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить эту категорию?" data-url="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=delete_category&id=<?php echo $category_t['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить категорию</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>