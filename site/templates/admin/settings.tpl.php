
				<h1><img class="tools-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Настройки</h1>

                <form action="<?php echo DIR_ADMIN; ?>?module=settings&action=edit" method="post" enctype="multipart/form-data">
                    <input type ="hidden" name="settings_flag" value="1"/>
                <?php if(isset($page_t['id'])) { ?><input type="hidden" name="id" value="<?php echo $page_t['id'];?>"><?php } ?>

				<div class="tabs">
					<ul class="bookmarks">
						<li <?php if($tab_active=="main")  { ?>class="active"<?php } ?>><a href="#" data-name="main">Основные</a></li>
						<li <?php if($tab_active=="header")  { ?>class="active"<?php } ?>><a href="#" data-name="header">Шапка и подвал</a></li>
						<li <?php if($tab_active=="images")  { ?>class="active"<?php } ?>><a href="#" data-name="images">Фон, логотип, favicon</a></li>
						<li <?php if($tab_active=="seo")  { ?>class="active"<?php } ?>><a href="#" data-name="seo">SEO</a></li>
						<li <?php if($tab_active=="codes")  { ?>class="active"<?php } ?>><a href="#" data-name="codes">Виджеты и счетчики</a></li>
						<li <?php if($tab_active=="system")  { ?>class="active"<?php } ?>><a href="#" data-name="system">Системные</a></li>
					</ul>

					<div class="tab-content">
							<ul class="form-lines wide">
								<li>
									<label for="site_title">Название компании</label>
									<div class="input text">
										<input type="text" id="site_title" name="site_title" value="<?php echo $site->settings->site_title;?>"/>
									</div>
								</li>
								<li>
									<label for="site_brief_description">Описание деятельности компании</label>
									<div class="input text">
										<input type="text" id="site_brief_description" name="site_brief_description" value="<?php echo $site->settings->site_brief_description;?>"/>
									</div>
								</li>
                                                                <li>
									<label for="site_description">Текст в футере под копирайтом</label>
                                                                        <div class="input textarea">
                                                                            <textarea cols="30" rows="10" name="site_description"><?php echo $site->settings->site_description; ?></textarea>
                                                                        </div>
								</li>
                               <li>
									<label for="description_on_main">Описание компании на главной</label>
                                                                        <div class="small_editor">
                                                                            <textarea cols="30" rows="10" id ="description_on_main" name="description_on_main"><?php echo $site->settings->description_on_main; ?></textarea>
                                                                        </div>
                                                                        <script>
                                                                            CKEDITOR.replace( 'description_on_main', {height: 500} );
                                                                    </script>
								</li>
						</ul>

					</div>

					<div class="tab-content">

							<ul class="form-lines wide">
								<li>
									<label for="site_phone">Телефоны</label>
									<div class="input text">
										<input type="text" id="site_phone2" name="site_phone" value="<?php echo $site->settings->site_phone;?>"/>
									</div>
								</li>
								<li>
									<label for="site_email">Email</label>
									<div class="input text">
										<input type="text" id="site_email2" name="site_email" value="<?php echo $site->settings->site_email;?>"/>
									</div>
								</li>
								<li>
									<label for="vk_link">Вконтакте</label>
									<div class="input text">
										<input type="text" id="vk_link" name="vk_link" value="<?php echo $site->settings->vk_link;?>"/>
									</div>
								</li>
                                <li>
									<label for="facebook_link">Facebook</label>
									<div class="input text">
										<input type="text" id="facebook_link" name="facebook_link" value="<?php echo $site->settings->facebook_link;?>"/>
									</div>
								</li>
                                <li>
									<label for="twitter_link">Twitter</label>
									<div class="input text">
										<input type="text" id="twitter_link" name="twitter_link" value="<?php echo $site->settings->twitter_link;?>"/>
									</div>
								</li>
                                <li>
									<label for="google_link">Google</label>
									<div class="input text">
										<input type="text" id="google_link" name="google_link" value="<?php echo $site->settings->google_link;?>"/>
									</div>
								</li>
						</ul>
					</div>
                    
					<div class="tab-content">
						<ul class="form-lines wide left">
                                <li>
                                <label>Фоновое изображение на сайте</label>
                                    <?php if($site->settings->site_background) { ?>
                                    <div class="one_image">

                                        <?php if($site->settings->site_background) echo '<img src="'.SITE_URL.URL_IMAGES."img/big/".$site->settings->site_background.'" style = "max-width: 700px" alt=""><br>'; ?>
                                        <a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&action=delete_background" class="delete-confirm delete-one-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это изображение?" title="Удалить">Удалить изображение</a>
                                    </div>
                                    <?php } ?>
                                    <div class="input input_smart_file">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файл</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
                                        <input type="file" accept="image/jpeg,image/png" name="picture_background">
                                    </div>
                                        <?php if(isset($errors['background']) and $errors['background']=='error_type') { ;?><p class="error">неверный тип файла (только JPEG или PNG)</p><?php } ?>
                                        <?php if(isset($errors['background']) and $errors['background']=='error_size') { ;?><p class="error">слишком большой файл</p><?php } ?>
                                        <?php if(isset($errors['background']) and $errors['background']=='error_upload') { ;?><p class="error">папка загрузки недоступна для записи или недостаточно места</p><?php } ?>
                                        <?php if(isset($errors['background']) and $errors['background']=='error_internal') { ;?><p class="error">внутренняя ошибка сервера</p><?php } ?>
                                </li>
                                <li>
                                <label>Логотип</label>
                                    <?php if($site->settings->site_logo) { ?>
                                    <div class="one_image">

                                        <?php if($site->settings->site_logo) echo '<img src="'.SITE_URL.URL_IMAGES."img/big/".$site->settings->site_logo.'" alt=""><br>'; ?>
                                        <a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&action=delete_logo" class="delete-confirm delete-one-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это изображение?" title="Удалить">Удалить изображение</a>
                                    </div>
                                    <?php } ?>
                                    <div class="input input_smart_file">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файл</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
                                        <input type="file" accept="image/jpeg,image/png" name="picture_logo">
                                    </div>
                                        <?php if(isset($errors['logo']) and $errors['logo']=='error_type') { ;?><p class="error">неверный тип файла (только JPEG, PNG, GIF)</p><?php } ?>
                                        <?php if(isset($errors['logo']) and $errors['logo']=='error_size') { ;?><p class="error">слишком большой файл</p><?php } ?>
                                        <?php if(isset($errors['logo']) and $errors['logo']=='error_upload') { ;?><p class="error">папка загрузки недоступна для записи или недостаточно места</p><?php } ?>
                                        <?php if(isset($errors['logo']) and $errors['logo']=='error_internal') { ;?><p class="error">внутренняя ошибка сервера</p><?php } ?>
                                </li>
                              <li>
                              <label>Водяной знак для изображений на сайте</label>
                                    <?php if($site->settings->site_watermark) { ?>
                                    <div class="one_image">

                                        <?php if($site->settings->site_watermark) echo '<img src="'.SITE_URL.URL_IMAGES."img/big/".$site->settings->site_watermark.'" alt=""><br>'; ?>
                                        <a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&action=delete_watermark" class="delete-confirm delete-one-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это изображение?" title="Удалить">Удалить изображение</a>
                                    </div>
                                    <?php } ?>
                                            <div class="input input_smart_file">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файл</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
                                        <input type="file" accept="image/jpeg,image/png" name="picture">
                                    </div>
                                        <?php if(isset($errors['watermark']) and $errors['watermark']=='error_type') { ;?><p class="error">неверный тип файла (только JPEG или PNG)</p><?php } ?>
                                        <?php if(isset($errors['watermark']) and $errors['watermark']=='error_size') { ;?><p class="error">слишком большой файл</p><?php } ?>
                                        <?php if(isset($errors['watermark']) and $errors['watermark']=='error_upload') { ;?><p class="error">папка загрузки недоступна для записи или недостаточно места</p><?php } ?>
                                        <?php if(isset($errors['watermark']) and $errors['watermark']=='error_internal') { ;?><p class="error">внутренняя ошибка сервера</p><?php } ?>
                                </li>
                                <li>
                                  <label>Favicon (.ico)</label>
                                  <?php if($site->settings->favicon) { ?>
                                  <div class="one_image">
                                    <?php if($site->settings->favicon) echo '<img src="'.SITE_URL.URL_FILES.$site->settings->favicon.'?'.rand().'" alt=""><br>'; ?>
                                    <a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&action=delete_favicon" class="delete-confirm delete-one-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить favicon?" title="Удалить">Удалить favicon</a> </div>
                                  <?php } ?>
                                  <div class="input input_smart_file"> <span class="btn standart-size"> <span class="button"> <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файл</span> </span> </span> <span class="file_name"></span>
                                    <input type="file" name="favicon">
                                  </div>
                                  <?php if(isset($errors['favicon']) and $errors['favicon']=='error_type') { ;?>
                                  <p class="error">неверный тип файла (только ICO)</p>
                                  <?php } ?>
                                  <?php if(isset($errors['favicon']) and $errors['favicon']=='error_size') { ;?>
                                  <p class="error">слишком большой файл</p>
                                  <?php } ?>
                                  <?php if(isset($errors['favicon']) and $errors['favicon']=='error_upload') { ;?>
                                  <p class="error">папка загрузки недоступна для записи или недостаточно места</p>
                                  <?php } ?>
                                  <?php if(isset($errors['favicon']) and $errors['favicon']=='error_internal') { ;?>
                                  <p class="error">внутренняя ошибка сервера</p>
                                  <?php } ?>
                                </li>
						</ul>
                        
                        <ul class="form-lines narrow right">
								<li>
									<label>Тип фона</label>
									<div class="input">
										<select class="select" name="bg_type_scroll">
											<option value="0" <?php if($site->settings->bg_type_scroll==0) echo "selected";?>>Скроллируемый</option>
											<option value="1" <?php if($site->settings->bg_type_scroll==1) echo "selected";?>>Фиксированный</option>
										</select>
									</div>
								</li>
								<li>
									<div class="input">
										<select class="select" name="bg_type_size">
											<option value="0" <?php if($site->settings->bg_type_size==0) echo "selected";?>>Реальный размер</option>
											<option value="1" <?php if($site->settings->bg_type_size==1) echo "selected";?>>100% ширина</option>
											<option value="2" <?php if($site->settings->bg_type_size==2) echo "selected";?>>Cover</option>
											<option value="3" <?php if($site->settings->bg_type_size==3) echo "selected";?>>Мозаика</option>
										</select>
									</div>
								</li>
								<li>
									<label>Цветовая схема</label>
									<div class="input">
										<select class="select" name="color_theme">
											<option value="" <?php if($site->settings->color_theme=='') echo "selected";?>>Серая</option>
											<option value="blue" <?php if($site->settings->color_theme=='blue') echo "selected";?>>Синяя</option>
											<option value="brown" <?php if($site->settings->color_theme=='brown') echo "selected";?>>Коричневая</option>
											<option value="red" <?php if($site->settings->color_theme=='red') echo "selected";?>>Красная</option>
										</select>
									</div>
								</li>
                        </ul>
                        
                        <div class="clear"></div>
					</div>

					<div class="tab-content ">
						<ul class="form-lines wide">
 								<li>
									<label for="meta_title">Заголовок главной страницы (meta title)</label>
									<div class="input text">
										<input class="seo-input" type="text" id="meta_title" name="meta_title" value="<?php echo $site->settings->meta_title;?>"/>
									</div>
								</li>
                             <li>
                                  <label>Описание главной страницы (meta description)</label>
                                  <div class="input textarea">
                                      <textarea class="seo-input" cols="30" rows="10" name="meta_description"><?php echo $site->settings->meta_description; ?></textarea>
                                  </div>
                                  <p class="small">рекомендуется не больше 250 символов</p>
                              </li>
                              <li>
                                  <label>Ключевые слова главной страницы (meta keywords)</label>
                                  <div class="input textarea">
                                      <textarea class="seo-input" cols="30" rows="10" name="meta_keywords"><?php echo $site->settings->meta_keywords;?></textarea>
                                  </div>
                                  <p class="small">все слова пишутся через запятую, слова должны встречаться в тексте, рекомендуется не больше 10 слов</p>
                              </li>
						</ul>
					</div>


					<div class="tab-content ">
						<ul class="form-lines wide">
                              <li>
                                <label>Код скрытых счетчиков</label>
                                  <div class="input textarea">
                                      <textarea cols="30" rows="10" name="counters_code"><?php echo $site->settings->counters_code;?></textarea>
                                  </div>
                            </li>
                            <li>
                                <label>Код в &lt;head&gt;&lt;/head&gt; <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title="Например, код верификации сайта для яндекса или google"/></label>
                                  <div class="input textarea">
                                      <textarea cols="30" rows="10" name="head_code"><?php echo $site->settings->head_code;?></textarea>
                                  </div>
                            </li>
                            <li>
                                <label>Код в начале &lt;body&gt; <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title="Например, код подключения виджета facebook или twitter"/></label>
                                  <div class="input textarea">
                                      <textarea cols="30" rows="10" name="body_top_code"><?php echo $site->settings->body_top_code;?></textarea>
                                  </div>
                            </li>
                              <li>
                                <label>Код виджета 1</label>
                                  <div class="input textarea">
                                      <textarea cols="30" rows="10" name="widget_code1"><?php echo $site->settings->widget_code1;?></textarea>
                                  </div>
                            </li>
                              <li>
                                <label>Код виджета 2</label>
                                  <div class="input textarea">
                                      <textarea cols="30" rows="10" name="widget_code2"><?php echo $site->settings->widget_code2;?></textarea>
                                  </div>
                            </li>
                              <li>
                                <label>Код виджета 3</label>
                                  <div class="input textarea">
                                      <textarea cols="30" rows="10" name="widget_code3"><?php echo $site->settings->widget_code3;?></textarea>
                                  </div>
                            </li>
                               <li>
									<label>Дополнительный текст в правой колонке</label>
                                    <div class="small_editor">
                                        <textarea cols="30" rows="10" id ="text_sidebar" name="text_sidebar"><?php echo $site->settings->text_sidebar; ?></textarea>
                                    </div>
                                    <script>
                                        CKEDITOR.replace( 'text_sidebar', {height: 200} );
                                	</script>
								</li>
						</ul>
					</div>

					<div class="tab-content ">
						<ul class="form-lines wide left">
							<li>
									<label for="limit_num">Количество записей на странице</label>
									<div class="input text ">
										<input type="text" id="limit_num" name="limit_num" value="<?php echo $site->settings->limit_num;?>"/>
									</div>
							</li>
                            <li>
									<label for="num_links">Количество ссылок в пагинаторе</label>
									<div class="input text ">
										<input type="text" id="num_links" name="num_links" value="<?php echo $site->settings->num_links;?>"/>
									</div>
							</li>
                            <li>
									<label for="limit_admin_num">Количество записей на странице в админке</label>
									<div class="input text ">
										<input type="text" id="limit_admin_num" name="limit_admin_num" value="<?php echo $site->settings->limit_admin_num;?>"/>
									</div>
							</li>
                            <li>
									<label for="admin_num_links">Количество ссылок в пагинаторе в админке</label>
									<div class="input text ">
										<input type="text" id="admin_num_links" name="admin_num_links" value="<?php echo $site->settings->admin_num_links;?>"/>
									</div>
                                                                        
							</li>
                            <li>
                                <label for="slide_delay">Пауза между сменой слайдов на главной в секундах.</label>
                                <div class="input text ">
                                    <input type="text" id="slide_delay" name="slide_delay" value="<?php echo $site->settings->slide_delay; ?>"/>
                                </div>
                            </li>
                            <li>
                                <label for="name_of_mainpage_block1">Название первого блока товаров на главной</label>
                                <div class="input text ">
                                    <input type="text" id="name_of_mainpage_block1" name="name_of_mainpage_block1" value="<?php echo $site->settings->name_of_mainpage_block1; ?>"/>
                                </div>
                            </li>
                            <li>
                                <label for="name_of_mainpage_block2">Название второго блока товаров на главной</label>
                                <div class="input text ">
                                    <input type="text" id="name_of_mainpage_block2" name="name_of_mainpage_block2" value="<?php echo $site->settings->name_of_mainpage_block2; ?>"/>
                                </div>
                            </li>
                            <li>
                                <label for="name_of_related_products">Название связи между товарами</label>
                                <div class="input text ">
                                    <input type="text" id="name_of_related_products" name="name_of_related_products" value="<?php echo $site->settings->name_of_related_products; ?>"/>
                                </div>
                            </li>
                            <li>
                                <label for="name_of_other_products">Название блока товаров из этой же категории (воводится снизу на странице товара)</label>
                                <div class="input text ">
                                    <input type="text" id="name_of_other_products" name="name_of_other_products" value="<?php echo $site->settings->name_of_other_products; ?>"/>
                                </div>
                            </li>
                         </ul>
                         
                         
                        <ul class="form-lines narrow right">
                            <li>
									<label><input type="checkbox" name="off_news" value="1" <?php if($site->settings->off_news==1) echo "checked";?> /> Выключить новости</label>
							</li>
						</ul>
                        <div class="clear"></div>
					</div>
                                   
				</div>

				<div class="bt-set clip">
                	<div class="left">
						<span class="btn standart-size blue hide-icon">
                        	<button class="ajax_submit" data-success-name="Cохранено">
                                <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <i>Сохранить</i></span>
                            </button>
						</span>
                   </div>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>