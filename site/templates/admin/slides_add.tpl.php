				<?php $site->tpl->display('list_revisions'); ?>
                
				<h1><img class="slides-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <?php if(isset($slide['id']) and $slide['id']>0) { ?>Редактировать<?php } else { ?>Добавить<?php } ?> слайд</h1>

                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit" method="post" enctype="multipart/form-data">
                <?php if(isset($slide['id'])) { ?><input type="hidden" name="id" value="<?php echo $slide['id'];?>"><?php } ?>
				
				<div class="tabs">
					<ul class="bookmarks">
						<li class="active"><a href="#" data-name="main">Содержание</a></li>
					</ul>

					<div class="tab-content">
											
							<ul class="form-lines wide left">
								<li>
									<label for="page-caption">Заголовок</label>
									<div class="input text <?php if(isset($errors['title'])) echo "fail";?>">
										<input type="text" id="page-caption" name="title" value="<?php if(isset($slide['title'])) echo $slide['title'];?>"/>
	                                    <?php if(isset($errors['title'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
                                <li>
									<label for="page-desc">Краткое описание</label>
									<div class="input text">
										<input type="text" id="page-desc" name="desc" value="<?php if(isset($slide['description'])) echo $slide['description'];?>"/>
									</div>
								</li>
								<li>
									<label for="page-url">Ссылка</label>
									<div class="input text">
										<input type="text" id="page-url" name="url" value="<?php if(isset($slide['url'])) echo $slide['url'];?>"/>
									</div>
								</li>
								<li>
                                    <label>Изображение</label>
                                    <?php if(isset($slide['img']) and $slide['img']!="") { ?>
                                    <div class="one_image">
	                                    <input type="hidden" name="img" value="<?php if(isset($slide['img'])) echo $slide['img'];?>"/>
											<img src="<?php echo $content_photos_dir."normal/".$slide['img'];?>" alt=""><br>
                                            <a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&id=<?php echo $slide['id']; ?>&action=delete_image" class="delete-confirm delete-one-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это изображение?" title="Удалить">Удалить изображение</a>
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
											<option value="1" <?php if(isset($slide['enabled']) and $slide['enabled']==1) echo "selected";?>>Опубликована</option>
											<option value="0" <?php if(isset($slide['enabled']) and $slide['enabled']==0) echo "selected";?>>Скрыта</option>
										</select>
									</div>
                                    <input type="hidden" name="sort" value="<?php if(isset($slide['sort'])) echo $slide['sort'];?>"/>
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
					<?php if(isset($slide['id']) and $slide['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот слайд?" data-url="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=delete&id=<?php echo $slide['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить слайд</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>