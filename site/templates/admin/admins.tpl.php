				<?php if($site->admins->get_level_access("admins")==2) { ?>
                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=admins&action=add" class="button ajax_link" data-module="admins">
							<span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Добавить админа</span>
						</a>
					</span>
				</div>
                <?php } ?>	
				<h1><img class="admins-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Администраторы</h1>
                <?php if(count($admins)>0) { ?>
                <div class="product-table admins">
					<table>
						<thead>
							<tr>
								<th>Логин</th>
								<th>Имя</th>
								<th>Класс прав</th>
								<th>Дата назначения</th>
								<?php if($site->admins->get_level_access("admins")==2) { ?><th>&nbsp;</th><?php } ?>	
							</tr>
						</thead>
                        
						<tbody>
                        <?php
							foreach($admins as $t_admin) { ?>
							<tr>
								<td>
									<?php if($site->admins->get_level_access("admins")==2 and $t_admin['id']!=$site->admins->aid()) { ?><a href="<?php echo DIR_ADMIN; ?>?module=admins&action=edit&id=<?php echo $t_admin['id']; ?>" title="Редактировать" class="ajax_link" data-module="admins"><?php echo $t_admin['login']; ?></a>
                                    <?php } else { echo $t_admin['login']; } ?>
								</td>
								<td>
									<?php if($site->admins->get_level_access("admins")==2 and $t_admin['id']!=$site->admins->aid()) { ?><a href="<?php echo DIR_ADMIN; ?>?module=admins&action=edit&id=<?php echo $t_admin['id']; ?>" title="Редактировать" class="ajax_link" data-module="admins"><?php echo $t_admin['name']; ?></a>
                                    <?php } else { echo $t_admin['name']; } ?>
								</td>
								<td>
									<?php echo $t_admin['class_name']; ?>
								</td>
								<td>
									<?php echo date('d.m.Y', $t_admin['date_set']); ?>
								</td>
                                <?php if($site->admins->get_level_access("admins")==2) { ?>
								<td>
                                	<?php if($t_admin['id']!=$site->admins->aid()) { ?>
                                	<a href="<?php echo DIR_ADMIN; ?>?module=admins&action=edit&id=<?php echo $t_admin['id']; ?>" title="Редактировать" class="ajax_link" data-module="admins"><img src="<?php echo $dir_images;?>icon.png" class="eicon edit-s" alt="icon"/></a>
									<a href="<?php echo DIR_ADMIN; ?>?module=admins&action=delete&id=<?php echo $t_admin['id']; ?>" class="delete-confirm" data-module="admins" data-text="Вы действительно хотите удалить этого администратора?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
                                    <?php } ?>
								</td>
                                <?php } ?>
							</tr>
						<?php } ?>	
						</tbody>
					</table>
				</div>
				<?php } ?>