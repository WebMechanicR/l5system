		<h1><img class="news-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/>События экономического календаря</h1>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=events" method="get">
                    <div class="section_filtres">
                        <div class="input">
                            <select class="select" name="unmatched">
                                <option value="0">Все</option>
                                <option value="1" <?php if(isset($unmatched) and $unmatched == 1) echo "selected"; ?>>Не соответствующие</option>
                            </select>
                        </div>
                        <span class="input_sub_str" >Дата с </span>
                        <div class="input date for_price">
                            <input type="text" name="date_from" value="<?php if(isset($date_from)) echo $date_from;?>"/>
                        </div>
                        <span class="input_sub_str" > по </span>
                                            <div class="input date for_price">
                            <input type="text" name="date_to" value="<?php if(isset($date_to)) echo $date_to;?>" />
                        </div>
                        <span class="btn standart-size hide-icon">
                             <button class="ajax_submit" >
                                 <span>Найти</span>
                             </button>
                        </span>
                    </div>
                </form>
                                <br/>
                                <h3>Событий всего: <?php echo $economic_events_count; ?></h3>
                                <br/>
				<?php
					if(count($list_events)>0) {
				?>
               
   				<div class="product-table">
					<table>
						<thead>
							<tr>
                                                            <th>Новость</th>
                                                            <th>Валюта</th>
                                                            <th>Время</th>
                                                            <th>Действие</th>
                                                            <th>Наступление</th>
                                                            <th>Фактически</th>
                                                            <th>Дополнение к</th>
							</tr>
                                                </thead>
						<tbody>
                        	<?php foreach($list_events as $event) { ?>
							<tr class="<?php echo abs(time() - $event['moment']) > 15 * 60 ? '' : 'is_new';?>">
                                                            <td>
                                                               <?php 
                                                               if(isset($event['news_name'])) {
                                                                   ?>
                                                                        <a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $event['news_id'];?>" class="ajax_link" data-module="<?php echo $module;?>" >
                                                                            <?php echo $event['news_name'].' ('.$event['news_currency'].')'; ?>
                                                                        </a>
                                                                  <?php
                                                               }
                                                               else
                                                                   'Неизвестно';
                                                               ?>
                                                            </td>
                                                            <td>
                                                                <?php echo $event['currency']; ?>
                                                            </td>
                                                            <td>
                                                                <?php echo date('d.m.Y H:i:s', $event['moment']); ?>
                                                            </td>
                                                            <td>
                                                                <?php echo $event['act'].' '.$event['strength'].'%'; ?>
                                                            </td>
                                                            <td>
                                                                <?php echo $event['happened']?'Да':'Нет'; ?>
                                                            </td>
                                                            <td>
                                                                <?php if($event['st_act']) echo $event['st_act'].' '.$event['st_strength'].'%'; ?>
                                                            </td>
                                                            <td>
                                                                <?php echo $event['st_currency']; ?>
                                                            </td>
							</tr>
                            <?php } ?>
						</tbody>
						<tfoot>
							<tr>
                                                            <th>Новость</th>
                                                            <th>Валюта</th>
                                                            <th>Время</th>
                                                            <th>Действие</th>
                                                            <th>Наступление</th>
                                                            <th>Фактически</th>
                                                            <th>Дополнение к</th>
							</tr>
						</tfoot>
					</table>
				</div>
                	
                    <?php $site->tpl->display('paging'); ?>
                	
			
				<?php } else {?>
				<h3>По заданными критериям новостей не найдено</h3>
                <?php } ?>