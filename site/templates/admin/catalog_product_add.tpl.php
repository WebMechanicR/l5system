<?php $site->tpl->display('list_revisions'); ?>
                
				<h1><img class="page-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <?php if(isset($product['id']) and $product['id']>0) { ?>Редактировать<?php } else { ?>Добавить<?php } ?> товар</h1>

                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit_product" method="post" enctype="multipart/form-data">
                <?php if(isset($product['id'])) { ?><input type="hidden" name="id" value="<?php echo $product['id'];?>"><?php } ?>
				
				<div class="tabs">
					<ul class="bookmarks">
						<li <?php if($tab_active=="main")  { ?>class="active"<?php } ?>><a href="#" data-name="main">Основные параметры</a></li>
						<li <?php if($tab_active=="photo")  { ?>class="active"<?php } ?>><a href="#" data-name="photo">Фото</a></li>
						<li <?php if($tab_active=="files")  { ?>class="active"<?php } ?>><a href="#" data-name="files">Файлы</a></li>
						<li <?php if($tab_active=="seo")  { ?>class="active"<?php } ?>><a href="#" data-name="seo">SEO</a></li>
						<li <?php if($tab_active=="other")  { ?>class="active"<?php } ?>><a href="#" data-name="other">Другие поля</a></li>
					</ul>

					<div class="tab-content">
											
							<ul class="form-lines wide left">
								<li>
									<label for="page-caption">Название</label>
									<div class="input text <?php if(isset($errors['name'])) echo "fail";?>">
										<input type="text" id="page-caption" name="name" <?php if(!isset($product['id']) or $product['id']<1) { ?>class="title_for_slug"<?php } ?> value="<?php if(isset($product['name'])) echo $product['name'];?>"/>
	                                    <?php if(isset($errors['name'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
								<li>
									<label>Категория</label>
									<div class="input <?php if(isset($errors['categories'])) echo "fail";?>">
										<select class="select" name="categ">
                                            <?php 
												function list_categs_inp_def($tree_categories, $sel=0, $parent=0, $nbsp="") {
													$list = "";
													if(isset($tree_categories["tree"][$parent]) and is_array($tree_categories["tree"][$parent])) {
														foreach($tree_categories["tree"][$parent] as $category_id) {
																$list .= '<option value="'.$category_id.'"';
																if($category_id == $sel) $list .= ' selected="true"';
																$list .= ">".$nbsp.$tree_categories["all"][$category_id]['title']."</option>";
																$list .= list_categs_inp_def($tree_categories, $sel, $category_id, $nbsp."&nbsp;&nbsp;");
														}
													}
													return $list;
												}
												echo list_categs_inp_def($tree_categories, $product['categ']);
											?>
										</select>
	                                    <?php if(isset($errors['categories'])) { ?><p class="error">должа быть выбрана категория</p><?php } ?>
									</div>
								</li>
								<?php if($site->settings->name_of_mainpage_block1) { ?>
                                <li>
                                    <label><input type="checkbox" name="show_in_block1" value="1" <?php if(isset($product['show_in_block1']) and $product['show_in_block1']==1) echo "checked";?> />Показывать в блоке &quot;<?php echo $site->settings->name_of_mainpage_block1; ?>&quot; на главной</label>
								</li>
								  <?php } ?>
                                  <?php if($site->settings->name_of_mainpage_block2) { ?>
                                  <li>
                                      <label><input type="checkbox" name="show_in_block2" value="1" <?php if(isset($product['show_in_block2']) and $product['show_in_block2']==1) echo "checked";?> />Показывать в блоке &quot;<?php echo $site->settings->name_of_mainpage_block2; ?>&quot; на главной</label>
								</li>
                                <?php } ?>
                                <li>
                                    <label>Краткое описание</label>
                                    <div class="frame small_editor">
                                        <textarea name="brief_description" id="brief_description"><?php if(isset($product['brief_description'])) echo $product['brief_description'];?></textarea>
                                        <script>
                                            CKEDITOR.replace( 'brief_description', {height: 150} );
                                        </script>
                                    </div>
                                </li>

							</ul>
							
							<ul class="form-lines narrow right">
								<li>
									<label for="articul">Артикул</label>
									<div class="input text">
										<input type="text" id="articul" name="articul" value="<?php if(isset($product['articul'])) echo $product['articul'];?>"/>
									</div>
								</li>
								<li>
								<label for="price">Текущая цена</label><br>
									<div class="input text">
										<input type="text" id="price" name="price" value="<?php if(isset($product['price']) and $product['price']>0) echo number_format($product['price'], F::count_nums_point($product['price']), '.', '');?>"/>
									</div>
								</li>
								<li>
									<label for="last_price">Старая цена<img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title='указывается возле текущей цены в зачеркнутом виде' /></label>
									<div class="input text">
										<input type="text" id="last_price" name="last_price" value="<?php if(isset($product['last_price']) and $product['last_price']>0) echo number_format($product['last_price'], F::count_nums_point($product['last_price']), '.', '');?>"/>
									</div>
								</li>
								<li>
									<label>Видимость</label>
									<div class="input">
										<select class="select" name="enabled">
											<option value="1" <?php if(isset($product['enabled']) and $product['enabled']==1) echo "selected";?>>Опубликован</option>
											<option value="0" <?php if(isset($product['enabled']) and $product['enabled']==0) echo "selected";?>>Скрыт</option>
										</select>
									</div>
								</li>
								<li>
									<label for="page-viewed">Просмотров</label>
									<div class="input text">
										<input type="text" id="page-viewed" name="viewed" value="<?php if(isset($product['viewed'])  and $product['viewed']>0) echo $product['viewed'];?>"/>
									</div>
								</li>
								<li>
									<label><input type="checkbox" name="novelty" value="1" <?php if(isset($product['novelty']) and $product['novelty']==1) echo "checked";?> /> Новинка</label>
								</li>
                                <!--
                                <li>
									<label><input type="checkbox" name="special" value="1" <?php if(isset($product['special']) and $product['special']==1) echo "checked";?> /> Спецпредложение</label>
								</li>
                                -->
                                <li>
									<label><input type="checkbox" name="is_hit" value="1" <?php if(isset($product['is_hit']) and $product['is_hit']==1) echo "checked";?> /> Хит продаж</label>
								</li>
							</ul>
							
							<div class="clear"></div>
						
							<label>Текст</label>
							<div class="frame editor">
								<textarea name="description" id="description"><?php if(isset($product['description'])) echo $product['description'];?></textarea>
                                <script>
									CKEDITOR.replace( 'description', {height: 500} );
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
										<input class="seo-input" type="text" id="page-meta-title" name="meta_title" value="<?php if(isset($product['meta_title'])) echo $product['meta_title'];?>"/>
									</div>
							</li>
							<li>
								<label>Описание страницы (meta description)</label>
								<div class="input textarea">
									<textarea class="seo-input" cols="30" rows="10" name="meta_description"><?php if(isset($product['meta_description'])) echo $product['meta_description'];?></textarea>
								</div>
								<p class="small">рекомендуется не больше 250 символов</p>
							</li>
							<li>
								<label>Ключевые слова (meta keywords)</label>
								<div class="input textarea">
									<textarea class="seo-input" cols="30" rows="10" name="meta_keywords"><?php if(isset($product['meta_keywords'])) echo $product['meta_keywords'];?></textarea>
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
										<input type="text" id="page-url" name="url" class="url_slug" value="<?php if(isset($product['url'])) echo $product['url'];?>"/>
	                                    <?php if(isset($errors['url']) and $errors['url']=="no_url") { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
	                                    <?php if(isset($errors['url']) and $errors['url']=="error_url") { ;?><p class="error">недопустимый URL</p><?php } ?>
									</div>
							</li>
                                                        <?php if($site->settings->name_of_related_products) { ?>
							<li>
                                <label><?php echo $site->settings->name_of_related_products; ?></label>
                                <div class="product-table related_products sortable">
                                <table>
                                    <tbody>
                                    <?php 
                                        if(isset($complect_products) and count($complect_products)>0) {
                                            foreach($complect_products as $analog_product) {
                                    ?>
                                        <tr>
                                            <td class="img">
                                            	<?php if($analog_product['img']) { ?><img src="<?php echo $content_photos_dir."small/".$analog_product['img'];?>" alt=""><?php } ?>
                                                <input type="hidden" name="complect_products[]" value="<?php echo $analog_product['id']; ?>">
                                            </td>
                                            <td class="name">
                                                <?php echo $analog_product['name'];?>
                                            </td>
											<td>
												<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
											</td>
                                            <td>
                                                <a href="#" class="delete-inline" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
                                            </td>
                                        </tr>
                                      <?php
                                            }
                                        }
                                      ?>
                                        <tr id="new_complect_product" style="display:none;">
                                            <td class="img">
                                            	<input type="hidden" name="complect_products[]" value=''>
                                            </td>
                                            <td class="name">
                                                
                                            </td>
											<td>
												<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
										    </td>
                                            <td>
                                                <a href="#" class="delete-inline" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
                                            </td>
                                        </tr>
                                        <tr class="addNew">
                                            <td colspan="2">
     											<div class="input text always_visible">
                                                    <input type="text" id="complect_products" name="" value="" placeholder="Введите название товара, чтобы добавить его" />
                                                </div>
											</td>
                                            <td>&nbsp;
																				
                                            </td>
											<td>&nbsp;
																				
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            </li>
                                                        <?php } ?>
						</ul>
                        <ul class="form-lines narrow right">

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
					<?php if(isset($product['id']) and $product['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="pages" data-text="Вы действительно хотите удалить этот товар?" data-url="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=delete_product&id=<?php echo $product['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить товар</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>
				 <script>
					$(function() {
						// Добавление связанных товаров
						var new_complect_product = $('#new_complect_product').clone(true);
						new_complect_product.removeAttr('id');
						$('#new_complect_product').remove().removeAttr('id');
						
						$("input#complect_products").autocomplete({
							serviceUrl:'<?php echo DIR_ADMIN; ?>ajax_search_products.php',
							minChars:1,
							noCache: false, 
							<?php if(isset($product['id']) and $product['id']>0) { ?>params: { not_id: <?php echo $product['id']; ?> },<?php } ?>
							onSelect:
								function(suggestion){
									new_item = new_complect_product.clone();
									new_item.find('td.name').html(suggestion.data.name);
									new_item.find('input[name*="complect_products"]').val(suggestion.data.id);
									if(suggestion.data.img) new_item.find('td.img').prepend("<img align=absmiddle src='<?php echo $content_photos_dir."small/";?>"+suggestion.data.img+"'>");
									$("#complect_products").val('').blur();
									$("#complect_products").closest("table").find("tr.addNew").before(new_item);
									new_item.show();
								},
							formatResult: function (suggestion, currentValue) {
								var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
								var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
						
								return (suggestion.data.img?"<img align=absmiddle src='<?php echo $content_photos_dir."small/";?>"+suggestion.data.img+"' width='35'> ":'') + suggestion.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
							}
					
						});
						
						// Удаление основного товара
						$(document).on("click", ".delete_main_product", function() {
							$('input[name="product_parent"]').val('');
							 $('#for_parent_product').fadeOut(200, function() { 
							 	$(this).empty().show();
								$("#parent_product").closest('.input').show();							 
							 });
							 return false;
						});
						
						//привязка основного товара
						$("input#parent_product").autocomplete({
							serviceUrl:'<?php echo DIR_ADMIN; ?>ajax_search_products.php',
							minChars:1,
							noCache: false, 
							<?php if(isset($product['id']) and $product['id']>0) { ?>params: { not_id: <?php echo $product['id']; ?> },<?php } ?>
							onSelect:
								function(suggestion){
									$('#for_parent_product').html('<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit_product&id='+suggestion.data.id+'" target="_blank">'+suggestion.data.name+'</a> &nbsp;&nbsp;<a href="#" class="delete_main_product dotted_link" >удалить</a>');
									$('input[name="product_parent"]').val(suggestion.data.id);
									$("#parent_product").val('').blur().closest('.input').hide();
								},
							formatResult: function (suggestion, currentValue) {
								var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
								var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
						
								return (suggestion.data.img?"<img align=absmiddle src='<?php echo $content_photos_dir."small/";?>"+suggestion.data.img+"' width='35'> ":'') + suggestion.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
							}
					
						});
					});
				</script>
