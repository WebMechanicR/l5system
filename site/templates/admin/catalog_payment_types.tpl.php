				<h1><img class="catalog-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Типы оплаты</h1>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=payment_types" method="post">
				<div class="product-table garanties sortable">
					<table>
						<thead>
							<tr>
								<th>Название</th>
                                <th>Позиция</th>
								<th>&nbsp;</th>
							</tr>
						</thead>
                        
						<tbody>
                        <?php 
							foreach($payment_types as $payment_type) { 
							?>
							<tr class="update_onfly">
								<td>
                                	<div class="input text">
										<input type="text" name="payment_type_name[<?php echo $payment_type['id']; ?>]" value="<?php echo $payment_type['name']; ?>"/>
									</div>
								</td>
                                <td>
                                	<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
                               </td>
								<td>
									<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=payment_types&del_id=<?php echo $payment_type['id']; ?>" class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот тип оплаты?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
								</td>
							</tr>
						<?php } ?>	
							<tr>
								<td>
                                	<div class="input text always_visible">
										<input type="text" name="new_payment_type_name" value=""/>
									</div>
								</td>
								<td><input type="hidden" name="new_payment_type_sort" value="<?php echo count($payment_types)+1; ?>">
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