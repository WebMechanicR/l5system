				<?php if($site->admins->get_level_access($module)==2) { ?>
                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=add_product&category_id=<?php echo $category_id;?>" class="button ajax_link" data-module="<?php echo $module;?>">
							<span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Добавить товар</span>
						</a>
					</span>
				</div>
                <?php } ?>	
				
				<h1><img class="catalog-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Товары</h1>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=products" method="get">
                <div class="section_filtres" style="margin-top:10px;">
					<div class="input text">
							<input type="text" name="articul" value="<?php if(isset($articul)) echo $articul;?>" placeholder="Артикул"/>
					</div>
                	<div class="input text">
							<input type="text" name="name" value="<?php if(isset($name)) echo $name;?>" placeholder="Название"/>
					</div>
				</div>
                <div class="section_filtres" style="margin-top:10px;">
                	<div class="input category">
										<select class="select" name="category_id">
                                        	<option value="0">Категория</option>
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
												echo list_categs_inp_def($tree_categories, $category_id);
											?>
										</select>
					</div>
                    <span class="btn standart-size hide-icon">
                        	<button class="ajax_submit" >
                                <span>Найти</span>
                            </button>
					</span>
                </div>
                </form>
                
				<?php
					if(count($list_products)>0) {
				?>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=group_actions_product<? echo $link_added_query;?><? echo $filtres_query;?>" method="post">
   				<div class="product-table sortable">
					<table>
						<thead>
							<tr>
                            	<?php if($site->admins->get_level_access($module)==2) { ?>
								<th>
									<input type="checkbox"/>
								</th>
								<th class="header <?php if($sort_by=="articul") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=articul&sort_dir=<?php echo ( ($sort_by=="articul" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Артикул <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                <?php } ?>
								<th class="header <?php if($sort_by=="name") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=name&sort_dir=<?php echo ( ($sort_by=="name" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Название <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="price") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=price&sort_dir=<?php echo ( ($sort_by=="price" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Цена, руб <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th>Фото</th>
								<th class="header <?php if($sort_by=="enabled") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=enabled&sort_dir=<?php echo ( ($sort_by=="enabled" and $sort_dir=="desc") ? "asc" : "desc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Статус <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                <th>Позиция</th>
								<th style="width:200px;">&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        	<?php foreach($list_products as $product) { ?>
							<tr class="update_onfly_sort <?php echo $product['enabled'] ? '' : 'disable';?>">
                            	<?php if($site->admins->get_level_access($module)==2) { ?>
								<td>
									<input type="checkbox" name="check_item[]" value="<?php echo $product['id'];?>"/>
                                     <input type="hidden" name="sort[<?php echo $product['id']; ?>]" value="<?php echo $product['sort']; ?>"/>
								</td>
                                <?php } ?>
								<td>
									<?php echo $product['articul']; ?>
								</td>
								<td>
                                	<?php if($site->admins->get_level_access($module)==2) { ?>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit_product&id=<?php echo $product['id'];?>" class="ajax_link" data-module="<?php echo $module;?>"><?php echo $product['name'];?></a>
									<?php } else { echo $product['name']; } ?>
                                </td>
								<td>
									<div class="input text">
										<input type="text" class="update_ajax_field" data-url="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=update_product_field&field=price" name="products_price[<?php echo $product['id'];?>]" value="<?php if($product['price']>0) echo number_format($product['price'], F::count_nums_point($product['price']), '.', ''); ?>"/>
									</div>
								</td>
								<td>
									<?php if($product['img']!="") { ?><img src="<?php echo $content_photos_dir."small/".$product['img'];?>" alt="" style="max-width:100px;"/><?php } ?>
								</td>
                                <td>
                                	<?php echo $product['enabled'] ? 'Опубликовано' : 'Скрыто';?>
                                </td>
                                <td>
                                	<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
                               </td>
								<td>
 									<?php if($product['categ']) { ?><a href="<?php echo SITE_URL.$catalog_full_link."/".$tree_categories['all'][$product['categ']]['full_link']."/".$product['url'];?>.htm" target="_blank" title="Посмотреть на сайте"><img src="<?php echo $dir_images;?>icon.png" class="eicon link-s" alt="icon"/></a><?php } ?>
                           			<?php if($site->admins->get_level_access($module)==2) { ?>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit_product&id=<?php echo $product['id'];?>" class="ajax_link" data-module="<?php echo $module;?>" title="Редактировать"><img src="<?php echo $dir_images;?>icon.png" class="eicon edit-s" alt="icon"/></a>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=duplicate_product&id=<?php echo $product['id'];?><? echo $link_added_query;?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>" title="Создать копию"><img src="<?php echo $dir_images;?>icon.png" class="eicon copy-s" alt="icon"/></a>
                                    <a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=delete_product&id=<?php echo $product['id'];?><? echo $link_added_query;?><? echo $filtres_query;?>" class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот товар?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
									<?php } ?>
								</td>
							</tr>
                            <?php } ?>
						</tbody>
						<tfoot>
							<tr>
                            	<?php if($site->admins->get_level_access($module)==2) { ?>
								<th>
									<input type="checkbox"/>
								</th>
                                <?php } ?>
								<th class="header <?php if($sort_by=="articul") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=articul&sort_dir=<?php echo ( ($sort_by=="articul" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Артикул <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="name") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=name&sort_dir=<?php echo ( ($sort_by=="name" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Название <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="price") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=price&sort_dir=<?php echo ( ($sort_by=="price" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Цена, руб <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th>Фото</th>
								<th class="header <?php if($sort_by=="enabled") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=products&sort_by=enabled&sort_dir=<?php echo ( ($sort_by=="enabled" and $sort_dir=="desc") ? "asc" : "desc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Статус <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                <th>Позиция</th>
								<th style="width:200px;">&nbsp;</th>
							</tr>
						</tfoot>
					</table>
				</div>
                	
                    <?php $site->tpl->display('paging'); ?>
                	
					<?php if($site->admins->get_level_access($module)==2) { ?>
                   <div class="combo">
                        <span class="btn gray">
                            <button>Скрыть отмеченные</button>
                        </span>
                        <button class="dicon arrdown">меню</button>
                        <ul>
                            <li><a href="#" data-active="hide">Скрыть отмеченные</a></li>
                            <li><a href="#" data-active="show">Опубликовать отмеченные</a></li>
                            <li><a href="#" data-active="movetocateg" data-added-field="moveto_categ">Переместить в категорию</a></li>
                            <li><a href="#" data-active="delete">Удалить отмеченные</a></li>
                        </ul>
                        <input type="hidden" name="do_active" value="hide">
                        <input type="hidden" name="group_actions" value="0">
                    </div>
                    
                    <div class="added_field_combo" id="moveto_categ">
                            <div class="input category">
                                                <select class="select" name="category_to">
                                                    <?php 
                                                        echo list_categs_inp_def($tree_categories);
                                                    ?>
                                                </select>
                            </div>
                            <span class="btn standart-size hide-icon">
                        	<button >
                                <span>Переместить</span>
                            </button>
                            </span>
					</span>
                    </div>
                    <?php } ?>
				</form>
				<?php }  else { ?>
				<h3>По заданными критериям товаров не найдено</h3>
                <?php } ?>