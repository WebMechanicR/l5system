                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit&id=<?php echo $order['id'];?>&print=1" class="button hide-icon" target="_blank">
							<span>Распечатать</span>
						</a>
					</span>
				</div>
    			<h1><img class="orders-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Заказ №<?php echo $order['id']; ?></h1>
                <?php 
					$ar_order_statuses = array("Новый", "В обработке", "Выполнен", "Отменен");
				?>

                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit" method="post" enctype="multipart/form-data">
                <?php if(isset($order['id'])) { ?><input type="hidden" name="id" value="<?php echo $order['id'];?>"><?php } ?>
				
				<div class="tabs">
					<ul class="bookmarks">
						<li <?php if($tab_active=="main")  { ?>class="active"<?php } ?>><a href="#" data-name="main">Детали заказа</a></li>
						<li <?php if($tab_active=="products")  { ?>class="active"<?php } ?>><a href="#" data-name="products">Товары</a></li>
					</ul>

					<div class="tab-content">
											
							<ul class="form-lines wide left">
								<li>
									<label for="page-caption">ФИО</label>
									<div class="input text <?php if(isset($errors['name'])) echo "fail";?>">
										<input type="text" id="page-caption" name="name" value="<?php echo $order['name'];?>"/>
	                                    <?php if(isset($errors['name'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
								<li>
									<label for="page-email">E-mail</label>
									<div class="input text  <?php if(isset($errors['email'])) echo "fail";?>">
										<input type="text" id="page-email" name="email" value="<?php if(isset($order['email'])) echo $order['email'];?>"/>
 										<?php if(isset($errors) and isset($errors['email']) and $errors['email']=="no_email") { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
 										<?php if(isset($errors) and isset($errors['email']) and $errors['email']=="err_email") { ;?><p class="error">неверный email</p><?php } ?>
									</div>
								</li>
								<li>
									<label for="page-phone">Телефон с кодом города</label>
									<div class="input text <?php if(isset($errors['phone'])) echo "fail";?>">
										<input type="text" id="page-phone" name="phone" value="<?php echo $order['phone'];?>"/>
	                                    <?php if(isset($errors['phone'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
								<li>
									<label for="page-contacts">Другие контакты</label>
									<div class="input textarea">
                                    	<textarea id="page-contacts" name="contacts"><?php if(isset($order['contacts'])) echo F::br2nl($order['contacts']);?></textarea>
									</div>
								</li>
                                <?php if(isset($order['file_rekvisits']) and $order['file_rekvisits']!="") { ?>
								<li>
									<label>Реквизиты организации</label>
                                    <div class="one_image">
										<a href="<?php echo $content_files_dir.$order['file_rekvisits'];?>" target="_blank">Посмотреть</a><br>
                                    </div>
								</li>
                                <?php } ?>
								<li>
									<label for="page-delivery">Способ доставки</label>
									<div class="input">
										<select id="page-delivery" class="select" name="delivery_id">
											<option value="0">---</option>
											<?php foreach($deliveries as $delivery) { ?>
                                            <option value="<?php echo $delivery['id']; ?>"  <?php if( isset($order['delivery_id']) and $order['delivery_id']==$delivery['id']) echo "selected"; ?>><?php echo $delivery['name'];?></option>
                                            <?php } ?>
										</select>
	                                    <?php if(isset($errors) and isset($errors['delivery'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
								<li>
									<label for="page-payment_type">Тип оплаты</label>
									<div class="input">
										<select id="page-payment_type" class="select" name="payment_type_id">
											<option value="0">---</option>
											<?php foreach($payment_types as $payment_type) { ?>
                                            <option value="<?php echo $payment_type['id']; ?>"  <?php if( isset($order['payment_type_id']) and $order['payment_type_id']==$payment_type['id']) echo "selected"; ?>><?php echo $payment_type['name'];?></option>
                                            <?php } ?>
										</select>
	                                    <?php if(isset($errors) and isset($errors['payment_type'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
								<li>
									<label for="page-address">Адрес доставки</label>
									<div class="input textarea <?php if(isset($errors) and isset($errors['address'])) echo "fail";?>">
                                    	<textarea id="page-address" name="address"><?php if(isset($order['address'])) echo F::br2nl($order['address']);?></textarea>
                                        <?php if(isset($errors) and isset($errors['address'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>	
									</div>
								</li>
								<li>
									<label for="page-comment">Примечания покупателя к заказу</label>
									<div class="input textarea">
                                    	<textarea id="page-comment" name="comment" readonly><?php if(isset($order['comment'])) echo F::br2nl($order['comment']);?></textarea>
									</div>
								</li>
								<li>
									<label for="page-admin_comment">Примечания администратора</label>
									<div class="input textarea">
                                    	<textarea id="page-admin_comment" name="admin_comment"><?php if(isset($order['admin_comment'])) echo F::br2nl($order['admin_comment']);?></textarea>
									</div>
								</li>
								<li>
									<label>Счет</label>
                                    <?php if(isset($order['file_invoice']) and $order['file_invoice']!="") { ?>
                                    <div class="one_image">
	                                    <input type="hidden" name="file_invoice" value="<?php if(isset($order['file_invoice'])) echo $order['file_invoice'];?>"/>
										<a href="<?php echo $invoices_files_dir.$order['file_invoice'];?>" target="_blank">Посмотреть</a><br>
                                        <a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&id=<?php echo $order['id']; ?>&action=delete_file" class="delete-confirm delete-one-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот файл?" title="Удалить">Удалить файл</a>
                                    </div>
                                    <?php } ?>
									<div class="input input_smart_file">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файл</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
                                        <input type="file" name="file">
                                    </div>
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_type') { ;?><p class="error">неверный тип файла</p><?php } ?>
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_size') { ;?><p class="error">слишком большой файл</p><?php } ?>
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_upload') { ;?><p class="error">папка загрузки недоступна для записи или недостаточно места</p><?php } ?>
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_internal') { ;?><p class="error">внутренняя ошибка сервера</p><?php } ?>
								</li>
							</ul>
							
							<ul class="form-lines narrow right">
								<li>
									<label for="page-status">Статус</label>
									<div class="input ">
										<select name="status" class="select" >
                                            <?php foreach($ar_order_statuses as $status_id=>$t_status) { ?>
											<option value="<?php echo $status_id; ?>"  <?php if($status_id==$order['status']) echo "selected"; ?>><?php echo $t_status;?></option>
                                            <?php } ?>
										</select>
									</div>
								</li>
                                                                
								<li>
									<label for="page-aid">Ответственный менеджер</label>
									<div class="input ">
										<select name="aid" class="select" >
                                        	<option value="0" >----</option>
                                            <?php foreach($list_admins as $t_admin) { ?>
											<option value="<?php echo $t_admin['id']; ?>"  <?php if($t_admin['id']==$order['aid']) echo "selected"; ?>><?php echo $t_admin['name'];?></option>
                                            <?php } ?>
										</select>
									</div>
								</li>
								<li>
									<label >Дата и время</label>
									<div class="info_text ">
										<strong><?php echo date('H:i d.m.Y', $order['date_add']);?></strong>
									</div>
								</li>
								<li>
									<label >Количество товаров</label>
									<div class="info_text ">
										<strong><?php echo $order['amount'];?> шт.</strong>
									</div>
								</li>
								<li>
									<label >Стоимость товаров</label>
									<div class="info_text ">
										<strong><?php echo F::number_format($order['total_price']); ?> руб.</strong>
									</div>
								</li>
							</ul>
							
							<div class="clear"></div>
														
						
					</div><!-- .tab-content end -->
					
					<!-- .tab-content end -->
					<!-- .tab-content end -->
					<div class="tab-content">
                        <div class="product-table  order_products ">
                                            <table>
                                                <thead>
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Название</th>
                                                        <th style="text-align:center;">Фото</th>
                                                        <th>Цена в заказе</th>
                                                        <th>Цена текущая</th>
                                                        <th>Количество</th>
                                                        <th>Стоимость</th>
                                                        <th>&nbsp;</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php 
                                                    $count = 0;
                                                    foreach($order_products['products'] as $product) { ?>
                                                    <tr class="product_line">
                                                        <td><?php echo $product['id']; ?></td>
                                                        <td>
                                                            <?php if($site->admins->get_level_access($module)==2) { ?>
                                                            <a href="<?php echo DIR_ADMIN;?>?module=catalog&action=edit_product&id=<?php echo $product['id'];?>" target="_blank"><?php echo $product['name'];?></a>
                                                            <?php } else { echo $product['name']; } ?>
                                                        </td>
                                                        <td style="text-align:center">
                                                            <?php if($product['img']!="") { ?><img src="<?php echo $content_photos_dir."small/".$product['img'];?>" alt=""/><?php } ?>
                                                        </td>
                                                        <td>
                                                            <div class="input text">
                                                                <input type="hidden" name="products[<?php echo $count;?>][id]" value="<?php echo $product['id'];?>">
                                                                <input type="text" class="price_product" name="products[<?php echo $count;?>][price]" value="<?php echo $product['price_order'];?>">
                                                            </div>
                                                        </td>
                                                        <td><?php echo F::number_format($product['price']); ?> руб.</td>
                                                        <td>
                                                        	<div class="input text">
                                                            <input type="text" class="amount_product" name="products[<?php echo $count;?>][amount]" value="<?php if($product['amount']>0) echo $product['amount'];?>">
                                                            </div>
                                                        </td>
                                                        <td class="cost_product"><?php echo F::number_format(($product['price_order'])*$product['amount']); ?> руб.</td>
                                                        <td>
                                                            <a href="#" class="delete-inline" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
                                                        </td>
                                                    </tr>
                                                    <?php 
                                                    $count++;
                                                            } ?>
                                                    <tr class="addNew">
                                                    <td colspan="7">
                                                        <div class="input text always_visible" style="display:block; width:100%;">
                                                            <input type="text" id="together_products" name="replace" value="" placeholder="Введите название товара, чтобы добавить его" style="width:851px;" />
                                                        </div>
                                                    </td>
                                                    <td>&nbsp;									
                                                    </td>
                                                   </tr>
                                                </tbody>
                                            </table>
                                        </div>                        
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
					<?php if(isset($order['id']) and $order['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот заказ?" data-url="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=delete&id=<?php echo $order['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>
                        <script>					
					$(function() {
                                                
                                                $(document).on('change', ".order_products tr.product_line input, #cost_delivery, #use_balls, #balls_discount", calcl_cart);
                                            
						// Добавление товара к заказу
						var new_id = 1;
						$("input#together_products").autocomplete({
							serviceUrl:'<?php echo DIR_ADMIN; ?>ajax_search_products.php',
							minChars:1,
							noCache: false, 
							onSelect:
								function(suggestion){
									new_item = '<tr class="product_line" >'
                                                      +' <td>'+suggestion.data.id+'</td>'
                                                      +' <td><a href="<?php echo DIR_ADMIN;?>?module=catalog&action=edit_product&id='+suggestion.data.id+'" target="_blank">'+suggestion.data.name+'</a></td>'
                                                      +' <td style="text-align:center">';
								  if(suggestion.data.img) new_item += "<img align=absmiddle src='<?php echo $content_photos_dir."small/";?>"+suggestion.data.img+"'>";			
                                   new_item += '  </td>'
                                                      +'  <td>'
                                                      +'  	<div class="input text">'
													  +'   <input type="hidden" name="products_new['+new_id+'][id]" value="'+suggestion.data.id+'">'
                                                      +'      <input type="text" class="price_product" name="products_new['+new_id+'][price]" value="'+suggestion.data.price+'">'
                                                      +'      </div>'
                                                      +'  </td>'
                                                      +'<td>'+suggestion.data.price+' руб.</td>'
                                                      +'  <td>'
                                                      +'  	<div class="input text">'
                                                      +'     <input type="text" class="amount_product" name="products_new['+new_id+'][amount]" value="1">'
                                                      +'      </div>'
                                                      +'  </td>'
                                                      +'  <td class="cost_product">'+myNumberFormat(suggestion.data.price)+' руб.</td>'
                                                      +'  <td>'
                                                      +'      <a href="#" class="delete-inline" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>'
                                                      +'  </td></tr>';
									$("#together_products").closest("table").find("tr.addNew").before(new_item);
									new_id++;
									calcl_cart();
								},
							formatResult: function (suggestion, currentValue) {
								var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
								var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
						
								return (suggestion.data.img?"<img align=absmiddle src='<?php echo $content_photos_dir."small/";?>"+suggestion.data.img+"' width='35'> ":'') + suggestion.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
							}
					
						});
					});
				</script>          