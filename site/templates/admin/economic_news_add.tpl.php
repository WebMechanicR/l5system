				
                
				<h1><img class="news-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <?php if(isset($economic_news['id']) and $economic_news['id']>0) { ?>Редактировать<?php } else { ?>Добавить<?php } ?> новость</h1>

                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=edit" method="post" enctype="multipart/form-data">
                <?php if(isset($economic_news['id'])) { ?><input type="hidden" name="id" value="<?php echo $economic_news['id'];?>"><?php } ?>
				
				<div class="tabs">
					<ul class="bookmarks">
						<li <?php if($tab_active=="main")  { ?>class="active"<?php } ?>><a href="#" data-name="main">Содержание</a></li>
					</ul>

					<div class="tab-content">
											
							<ul class="form-lines wide left">
								<li>
									<label for="page-caption">Название</label>
									<div class="input text <?php if(isset($errors['name'])) echo "fail";?>">
										<input type="text" id="page-caption" name="name" <?php if(!isset($economic_news['id']) or $economic_news['id']<1) { ?>class="title_for_slug"<?php } ?> value="<?php if(isset($economic_news['name'])) echo $economic_news['name'];?>"/>
                                                                                <?php if(isset($errors['name'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
									</div>
								</li>
                                                                <?php if(isset($economic_news['matched_with']) and $economic_news['matched_with'] and $news_name = $this->economic_news->get_calendar_news($economic_news['matched_with'])) { 
                                                                    $news_name = $news_name['name'];
                                                                ?>
                                                                <li>
                                                                    <label>Совпадает с:
                                                                        <?php if(isset($economic_news['matched_with']) and $economic_news['matched_with']) { ?>
                                                                            <a href="<?php echo DIR_ADMIN; ?>?module=economic_news&action=edit&id=<?php echo $economic_news['matched_with']; ?>"><?php echo $news_name; ?></a>
                                                                            |
                                                                            <a href="<?php echo DIR_ADMIN; ?>?module=economic_news&action=edit&id=<?php echo $economic_news['id']; ?>&apply_matching=1">Подтвердить совпадение</a>
                                                                            |
                                                                            <a href="<?php echo DIR_ADMIN; ?>?module=economic_news&action=edit&id=<?php echo $economic_news['id']; ?>&cancel_matching=1">Отвязать</a>
                                                                            
                                                                            <br/>
                                                                        <?php } ?>
                                                                    </label>
                                                                    <div class="input text <?php if(isset($errors['mathced_with'])) echo "fail";?>">
                                                                        <input type="text" id = "new_matched_with" name="new_matched_with" value="" placeholder="Начните вводить название"/>
                                                                    </div>
                                                                </li>
                                                                <?php } ?>
                                                                <li>
									<label>Альтернативные название (разделитель ||)</label>
									<div class="input text">
										<input type="text"  name="alternative_names" value="<?php if(isset($economic_news['alternative_names'])) echo $economic_news['alternative_names'];?>"/>
									</div>
								</li>
                                                                <li>
                                                                    <label>События (<?php echo $events?count($events).' событий':'нет событий'; ?>)</label>
                                                                    <?php if($events) { ?>
                                                                    <div class="product-table phones">
                                                                            <table>
                                                                                <thead>
                                                                                <th>Время</th>
                                                                                <th>Сила влияния</th>
                                                                                <th>Фактически</th>
                                                                                <th>Дополнение к</th>
                                                                                </thead>
                                                                              <tbody>
                                                                                <?php 
                                                                                foreach($events as $event) {                                                                                    ?>
                                                                                    <tr>
                                                                                      <td class="phone_type">
                                                                                        <?php echo date('d.m.Y H:i', $event['moment']); ?>
                                                                                      </td>
                                                                                      <td class="phone_type">
                                                                                         <?php echo $event['act']?$event['act'].': ':''; ?><?php echo $event['strength']; ?>%
                                                                                      </td>
                                                                                      <td class="phone_type">
                                                                                         <?php echo $event['st_act']?$event['st_act'].': ':''; ?><?php echo $event['st_strength']; ?>%
                                                                                      </td>
                                                                                      <td class="phone_type">
                                                                                         <?php echo $event['st_currency']; ?>
                                                                                      </td>
                                                                                    </tr>
                                                                                <?php
                                                                                   }
                                                                                ?>
                                                                              </tbody>
                                                                            </table>
                                                                          </div>
                                                                    <?php } ?>
                                                                </li>
                                                                <li>
									<label>ID в источнике</label>
									<div class="input text">
										<input type="text"  name="name_in_source" value="<?php if(isset($economic_news['name_in_source'])) echo $economic_news['name_in_source'];?>"/>
									</div>
								</li>
                                                                <li>
									<label>Источник</label>
									<div class="input text">
										<input type="text"  name="source" value="<?php if(isset($economic_news['source'])) echo $economic_news['source'];?>"/>
									</div>
								</li>
                                                                <li>
									<label>Валюта</label>
									<div class="input text">
										<input type="text"  name="currency" value="<?php if(isset($economic_news['currency'])) echo $economic_news['currency'];?>"/>
									</div>
								</li>
                                                                <li>
									<label>Страна</label>
									<div class="input text">
										<input type="text"  name="country" value="<?php if(isset($economic_news['country'])) echo $economic_news['country'];?>"/>
									</div>
								</li>
							</ul>
							
							<ul class="form-lines narrow right">
								<li>
									<label>Статус</label>
									<div class="input">
										<select class="select" name="enabled">
											<option value="1" <?php if(isset($economic_news['enabled']) and $economic_news['enabled']==1) echo "selected";?>>Опубликована</option>
											<option value="0" <?php if(isset($economic_news['enabled']) and $economic_news['enabled']==0) echo "selected";?>>Скрыта</option>
										</select>
									</div>
								</li>
                                                                <li>
									<label>Метод интерпретации</label>
									<div class="input">
										<select class="select" name="act_applying_method">
											<option value="such" <?php if(isset($economic_news['act_applying_method']) and $economic_news['act_applying_method']=='such') echo "selected";?>>Прямой</option>
                                                                                        <option value="against" <?php if(isset($economic_news['act_applying_method']) and $economic_news['act_applying_method']=='against') echo "selected";?>>Обратный</option>    
                                                                                        <option value="indefinite" <?php if(isset($economic_news['act_applying_method']) and $economic_news['act_applying_method']=='indefinite') echo "selected";?>>Непоследовательный эффект</option>
                                                                                        <option value="more_indefinite" <?php if(isset($economic_news['act_applying_method']) and $economic_news['act_applying_method']=='more_indefinite') echo "selected";?>>Неопределенный</option>
                                                                                </select>
									</div>
								</li>
                                                                <li>
                                                                    <label>Дата добавления</label>
                                                                    <div class="input date">
                                                                        <input type="text" name="date" value="<?php if(isset($economic_news['date_add'])) echo date('d.m.Y H:i:s', $economic_news['date_add']);?>" />
                                                                    </div>
                                                                </li>
                                                                <li>
									<label><input type="checkbox" name="is_approved" value="1" <?php if(isset($economic_news['is_approved']) and $economic_news['is_approved']==1) echo "checked"; ?> />Утвержден</label>
								</li>
                                                                
							</ul>
							
							<div class="clear"></div>
							

							<label>Описание</label>
							<div class="frame editor">
								<textarea name="body" id="body"><?php if(isset($economic_news['body'])) echo $economic_news['body'];?></textarea>
                                <script>
									CKEDITOR.replace( 'body', {height: 500} );
								</script>
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
					<?php if(isset($economic_news['id']) and $economic_news['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить эту новость?" data-url="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=delete&id=<?php echo $economic_news['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить новость</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
                <input type="hidden" name="tab_active" value="<?php echo $tab_active;?>">
				</form>