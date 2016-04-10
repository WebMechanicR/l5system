				<h1><img class="menus-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Типы меню</h1>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>" method="post">
				<div class="product-table garanties sortable">
					<table>
						<thead>
							<tr>
								<th>Название</th>
								<th>ID</th>
                                <th>Позиция</th>
								<th>&nbsp;</th>
							</tr>
						</thead>
                        
						<tbody>
                        <?php 
							foreach($menus as $menu) { 
							?>
							<tr class="update_onfly">
								<td>
                                	<div class="input text">
										<input type="text" name="menu_name[<?php echo $menu['id']; ?>]" value="<?php echo $menu['name']; ?>"/>
									</div>
								</td>
                                <td><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=menu_items&menu_id=<?php echo $menu['id'];?>" class="ajax_link" data-module="<?php echo $module;?>" title="Редактировать пункты меню"><?php echo $menu['id']; ?></a></td>
                                <td>
                                	<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
                               </td>
								<td>
                                	<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=menu_items&menu_id=<?php echo $menu['id'];?>" class="ajax_link" data-module="<?php echo $module;?>" title="Редактировать пункты меню"><img src="<?php echo $dir_images;?>icon.png" class="eicon subpage-s" alt="icon"/></a>
									<?php if($menu['id']>=1) { ?><a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=index&del_id=<?php echo $menu['id']; ?>" class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это меню?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a><?php } ?>
								</td>
							</tr>
						<?php } ?>	
							<tr>
								<td>
                                	<div class="input text always_visible">
										<input type="text" name="new_menu_name" value=""/>
									</div>
								</td>
                                <td></td>
								<td><input type="hidden" name="new_menu_sort" value="<?php echo count($menus)+1; ?>">
								</td>
								<td>&nbsp;
								</td>
							</tr>
						</tbody>
					</table>
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
				</form>