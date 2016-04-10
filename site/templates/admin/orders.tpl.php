				<h1><img class="orders-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Заказы</h1>
				<?php
						$ar_order_statuses = array("Новый", "В обработке", "Выполнен", "Отменен");
				?>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=index" method="get">
                <div class="section_filtres">
                	<div class="input text">
							<input type="text" name="order_id" value="<?php if(isset($order_id) and $order_id) echo $order_id;?>" placeholder="Номер заказа"/>
					</div>
					<div class="input text">
							<input type="text" name="order_name" value="<?php if(isset($order_name)) echo $order_name;?>" placeholder="ФИО"/>
					</div>  
					<div class="input">
										<select name="status" class="select" >
                                        	<option value="-1">Статус</option>
                                            <?php foreach($ar_order_statuses as $status_id=>$t_status) { ?>
											<option value="<?php echo $status_id; ?>"  <?php if($status==$status_id) echo "selected"; ?>><?php echo $t_status;?></option>
                                            <?php } ?>
										</select>
					</div>
				</div>
				<div class="section_filtres">
                    <span class="input_sub_str" >Дата с </span>
					<div class="input date for_price">
                        <input type="text" name="date_from" value="<?php if(isset($date_from)and $date_from>0) echo date('d.m.Y', $date_from);?>" />
                    </div>
                    <span class="input_sub_str" > по </span>
					<div class="input date for_price">
                        <input type="text" name="date_to" value="<?php if(isset($date_to) and $date_to>0) echo date('d.m.Y', $date_to);?>" />
                    </div>
					
                    <span class="btn standart-size hide-icon">
                        	<button class="ajax_submit" >
                                <span>Найти</span>
                            </button>
					</span>
                </div>
                </form>

				<?php
					if(count($list_orders)>0) {
				?>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=group_actions<? echo $link_added_query;?>" method="post">
   				<div class="product-table">
					<table>
						<thead>
							<tr>
                            	<?php if($site->admins->get_level_access($module)==2) { ?>
								<th>
									<input type="checkbox"/>
								</th>
                                <?php } ?>
								<th class="header <?php if($sort_by=="id") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=id&sort_dir=<?php echo ( ($sort_by=="id" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">ID <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="name") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=name&sort_dir=<?php echo ( ($sort_by=="name" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">ФИО <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th>Email</th>
								<th>Телефон</th>
								<th class="header <?php if($sort_by=="total_price") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=total_price&sort_dir=<?php echo ( ($sort_by=="total_price" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Сумма, руб. <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="status") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=status&sort_dir=<?php echo ( ($sort_by=="status" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Статус <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="date_add") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=date_add&sort_dir=<?php echo ( ($sort_by=="date_add" and $sort_dir=="desc") ? "asc" : "desc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Дата <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                                                
                                                                <th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        	<?php foreach($list_orders as $news) { ?>
							<tr>
                            	<?php if($site->admins->get_level_access($module)==2) { ?>
								<td>
									<input type="checkbox" name="check_item[]" value="<?php echo $news['id'];?>"/>
								</td>
                                <?php } ?>
								<td>
                                	<?php if($site->admins->get_level_access($module)==2) { ?>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $news['id'];?>" class="ajax_link" data-module="<?php echo $module;?>"><?php echo $news['id'];?></a>
									<?php } else { echo $news['id']; } ?>
                                </td>
								<td>
                                	<?php if($site->admins->get_level_access($module)==2) { ?>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $news['id'];?>" class="ajax_link" data-module="<?php echo $module;?>"><?php echo $news['name'];?></a>
									<?php } else { echo $news['name']; } ?>
                                </td>
								<td>
									<?php echo $news['email']; ?>
                                </td>
                                <td>
                                	<?php echo $news['phone']; ?>
                                </td>
                                <td>
                                	<?php echo F::number_format($news['total_price']); ?>
                                </td>
                                <td>
                                	<?php echo $ar_order_statuses[$news['status']]; ?>
                                </td>
                                <td>
                                		<?php echo date('H:i d.m.Y', $news['date_add']);?>
                                </td>
                                
								<td>
                           			<?php if($site->admins->get_level_access($module)==2) { ?>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $news['id'];?>" class="ajax_link" data-module="<?php echo $module;?>" title="Открыть"><img src="<?php echo $dir_images;?>icon.png" class="eicon edit-s" alt="icon"/></a>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=delete&id=<?php echo $news['id'];?><? echo $link_added_query;?><? echo $filtres_query;?>" class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этого поставщика?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
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
								<th class="header <?php if($sort_by=="id") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=id&sort_dir=<?php echo ( ($sort_by=="id" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">ID <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="name") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=name&sort_dir=<?php echo ( ($sort_by=="name" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">ФИО <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th>Email</th>
								<th>Телефон</th>
								<th class="header <?php if($sort_by=="name") { echo ($sort_dir=="total_price" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=total_price&sort_dir=<?php echo ( ($sort_by=="total_price" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Сумма <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="status") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=status&sort_dir=<?php echo ( ($sort_by=="status" and $sort_dir=="asc") ? "desc" : "asc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Статус <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="date_add") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=date_add&sort_dir=<?php echo ( ($sort_by=="date_add" and $sort_dir=="desc") ? "asc" : "desc"); ?><? echo $filtres_query;?>" class="ajax_link" data-module="<?php echo $module;?>">Дата <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								
                                                                <th>&nbsp;</th>
							</tr>
						</tfoot>
					</table>
				</div>
                	
                    <?php $site->tpl->display('paging'); ?>
                	
					<?php if($site->admins->get_level_access($module)==2) { ?>
                   <div class="combo">
                        <span class="btn gray">
                            <button>Удалить отмеченные</button>
                        </span>
                        <input type="hidden" name="do_active" value="delete">
                        <input type="hidden" name="group_actions" value="0">
                    </div>
                    <?php } ?>
				</form>
				<?php }  else { ?>
				<h3>По заданными критериям ничего не найдено</h3>
                <?php } ?>				
               <script>
					$(function() {
						update_newcount_module("orders", <?php echo intval($site->orders->get_count_orders( array("status"=>0, "paid" => 1) )); ?>);
					});
				</script>