				<h1><img class="ordercall-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Заказанные звонки</h1>
                                
				<?php
					if(count($list_calls)>0) {
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
								<th>Тема</th>
								<th>Время</th>
								<th>Телефон</th>
								<th>	Контактное лицо</th>
								<th>Сообщение</th>
								<th>Дата</th>
								<th>Отработал</th>
								<th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        	<?php foreach($list_calls as $call) { ?>
							<tr <?php echo ($call['is_new'] ? 'class="is_new"' : '');?>>
                            	<?php if($site->admins->get_level_access($module)==2) { ?>
								<td>
									<input type="checkbox" name="check_item[]" value="<?php echo $call['id'];?>"/>
								</td>
                                <?php } ?>
								<td>
                                	<?php echo $call['subject'];?>
                                </td>
								<td>
									<?php echo $call['besttime'];?>
								</td>
								<td>
									<?php echo $call['phone'];?>
                                </td>
								<td>
									<?php echo $call['name'];?>
                                </td>
								<td>
									<?php echo $call['message'];?>
                                </td>
                                <td>
                                		<?php echo date('H:i d.m.Y', $call['date_add']);?>
                                </td>
								<td><?php echo ($call['aid'] ? $call['admin_name'] : '') ?></td>
								<td>
                           			<?php if($site->admins->get_level_access($module)==2) { ?>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=delete&id=<?php echo $call['id'];?><? echo $link_added_query;?>" class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить эту запись?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
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
								<th>Тема</th>
								<th>Время</th>
								<th>Телефон</th>
								<th>	Контактное лицо</th>
								<th>Сообщение</th>
								<th>Дата</th>
								<th>Отработал</th>
								<th>&nbsp;</th>
							</tr>
						</tfoot>
					</table>
				</div>
                	
                    <?php $site->tpl->display('paging'); ?>
                	
					<?php if($site->admins->get_level_access($module)==2) { ?>
                   <div class="combo">
                        <span class="btn gray">
                            <button>Обработать отмеченные</button>
                        </span>
                        <button class="dicon arrdown">меню</button>
                        <ul>
                            <li><a href="#" data-active="completed">Обработать отмеченные</a></li>
                            <li><a href="#" data-active="delete">Удалить отмеченные</a></li>
                        </ul>
                        <input type="hidden" name="do_active" value="completed">
                        <input type="hidden" name="group_actions" value="0">
                    </div>
                    <?php } ?>
				</form>
				<?php } else {?>
				<h3>По заданными критериям ничего не найдено</h3>
                <?php } ?>
				
                <script>
					$(function() {
						update_newcount_module("ordercall", <?php echo intval($site->ordercall->get_count_calls( array("is_new"=>1) )); ?>);
					});
				</script>