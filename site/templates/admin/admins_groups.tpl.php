				<h1><img class="admins-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Группы администраторов</h1>
                <form action="<?php echo DIR_ADMIN; ?>?module=admins&action=groups" method="post">
				<div class="product-table admins">
					<table>
						<thead>
							<tr >
								<th class="name_modules">&nbsp;</th>
								<?php 
									$allowed = array();
                                	foreach($admin_classes as $admin_class) { 
                                   	 $allowed[$admin_class['id']] = unserialize($admin_class['allowed']);
                                ?>
                                	<th  class="name_group update_onfly">
                                	<div class="input text">
										<input type="text" name="class_name[<?php echo $admin_class['id']; ?>]" value="<?php echo $admin_class['name']; ?>"/>
									</div>
									</th>
                                    <th  class="name_del">
                                        <a href="<?php echo DIR_ADMIN; ?>?module=admins&action=groups&del_id=<?php echo $admin_class['id']; ?>" class="delete-confirm" data-module="admins" data-text="Вы действительно хотите удалить эту группу администраторов?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
                                    </th>
								<?php } ?>
                                <?php if(count($admin_classes)<5) { ?>
								<th>
                                	<div class="input text always_visible">
										<input type="text" name="new_class_name" value="" placeholder="Добавить новую" />
									</div>
								</th>
								<?php } ?>
							</tr>
						</thead>
                        
						<tbody>
                            <?php  foreach($modules as $t_module) { ?>
                            <tr>
									<td><?php echo $t_module['name'];?></td>
                                	<?php  foreach($admin_classes as $admin_class) {  ?>
                                    <td colspan="2" class="update_onfly">
                                        <div class="input for_select 
                                        <?php if( isset( $allowed[ $admin_class['id'] ][ $t_module['id'] ] ) and $allowed[ $admin_class['id'] ][ $t_module['id'] ]==1) echo "only_read"; 
                                                    elseif( isset( $allowed[ $admin_class['id'] ][ $t_module['id'] ] ) and $allowed[ $admin_class['id'] ][ $t_module['id'] ]==2) echo "full_access"; 
                                                    else echo "closed"; ?>
                                        ">
                                        <select class="select" name="class_allowed[<?php echo $admin_class['id']; ?>][<?php echo $t_module['id']; ?>]">
                                            <option value="0" <?php if( isset( $allowed[ $admin_class['id'] ][ $t_module['id'] ] ) and $allowed[ $admin_class['id'] ][ $t_module['id'] ]==0) echo "selected"; ?>>Закрыт</option>
                                            <option value="1" <?php if( isset( $allowed[ $admin_class['id'] ][ $t_module['id'] ] ) and $allowed[ $admin_class['id'] ][ $t_module['id'] ]==1) echo "selected"; ?>>Чтение</option>
                                            <option value="2" <?php if( isset( $allowed[ $admin_class['id'] ][ $t_module['id'] ] ) and $allowed[ $admin_class['id'] ][ $t_module['id'] ]==2) echo "selected"; ?>>Запись</option>
                                        </select>
                                        </div>
                                    </td>
									<?php } ?>
                                    <?php if(count($admin_classes)<5) { ?>
                                    <td >
                                        <div class="input for_select closed">
                                        <select class="select" name="new_class_allowed[<?php echo $t_module['id']; ?>]">
                                            <option value="0">Закрыт</option>
                                            <option value="1">Чтение</option>
                                            <option value="2">Запись</option>
                                        </select>
                                        </div>
                                    </td>
									<?php } ?>
                            </tr>
							<?php } ?>
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
                <script>
					$(function() {
						$('.admins .for_select select').change(function() {
							var for_select = $(this).closest('.for_select');
							$(for_select).removeClass('closed full_access only_read');
							if($(this).val()==1) $(for_select).addClass('only_read');
							else if($(this).val()==2) $(for_select).addClass('full_access');
							else $(for_select).addClass('closed');
						});
						
					});
				</script>