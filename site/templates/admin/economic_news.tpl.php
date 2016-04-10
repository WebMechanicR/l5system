				<?php if($site->admins->get_level_access($module)==2) { ?>
                                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=add" class="button ajax_link" data-module="<?php echo $module;?>">
							<span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Добавить новость</span>
						</a>
					</span>
				</div>
                <?php } ?>	
				<h1><img class="news-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/>Экономический календарь</h1>
                                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>" method="get">
                <div class="section_filtres" style="margin-top:10px;">
                	<div class="input text">
							<input type="text" name="name" value="<?php if(isset($name)) echo $name;?>" placeholder="Название"/>
					</div>
			
                            <span class="btn standart-size hide-icon">
                        	<button class="ajax_submit" >
                                <span>Найти</span>
                            </button>
					</span>
                </div>
                </form>
                                <br/>
                                <h3>Новостей всего: <?php echo $economic_news_count; ?></h3>
                                <br/>
				<?php
					if(count($list_economic_news)>0) {
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
								<th style="width:400px" class="header <?php if($sort_by=="name") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=name&sort_dir=<?php echo ( ($sort_by=="name" and $sort_dir=="asc") ? "desc" : "asc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Название <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                                                <th>Валюта</th>
                                                                <th class="header <?php if($sort_by=="is_approved") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=is_approved&sort_dir=<?php echo ( ($sort_by=="is_approved" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Утвержден <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="matched_with") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=matched_with&sort_dir=<?php echo ( ($sort_by=="matched_with" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Совпадает с <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                                                <th class="header <?php if($sort_by=="date_add") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=date_add&sort_dir=<?php echo ( ($sort_by=="date_add" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Дата добавления<img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="enabled") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=enabled&sort_dir=<?php echo ( ($sort_by=="enabled" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Статус <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="num_events") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=num_events&sort_dir=<?php echo ( ($sort_by=="num_events" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Событий <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                                                
                                                                <th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        	<?php foreach($list_economic_news as $economic_news) { ?>
							<tr class="<?php echo $economic_news['enabled'] ? '' : 'disable ';?> <?php echo $economic_news['matched_with'] ? 'green_background' : ' ';?> <?php echo $economic_news['is_approved'] ? '' : 'is_new';?>">
                            	<?php if($site->admins->get_level_access($module)==2) { ?>
								<td>
									<input type="checkbox" name="check_item[]" value="<?php echo $economic_news['id'];?>"/>
								</td>
                                <?php } ?>
								<td>
                                	<?php if($site->admins->get_level_access($module)==2) { ?>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $economic_news['id'];?>" class="ajax_link" data-module="<?php echo $module;?>"><?php echo $economic_news['name'];?></a>
									<?php } else { echo $economic_news['name']; } ?>
                                </td>
                                <td>
                                    <?php echo $economic_news['currency']; ?>
                                </td>
                                <td>
                                    <?php echo $economic_news['is_approved'] ? 'Да' : 'Нет';?>
                                </td>
                                <td>
                                    <?php
                                        if($economic_news['matched_with'] and $news_name = $this->economic_news->get_calendar_news($economic_news['matched_with'])){
                                             ?>
                                                <a href="<?php echo DIR_ADMIN; ?>?module=economic_news&action=edit&id=<?php echo $economic_news['matched_with']; ?>"><?php echo $news_name['name']; ?></a>
                                            <?php
                                        }
                                        else{
                                            echo 'Нет';
                                        }
                                    ?>
                                </td>
                                <td>
                                		<?php echo date('d.m.Y H:i:s', $economic_news['date_add']);?>
                                </td>
                                <td>
                                	<?php echo $economic_news['enabled'] ? 'Опубликовано' : 'Скрыто';?>
                                </td>
                                <td>
                                	<?php echo $economic_news['num_events'];?>
                                </td>
								<td class="nowrap">
 									<?php if($site->admins->get_level_access($module)==2) { ?>
                                                                            <a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $economic_news['id'];?>" class="ajax_link" data-module="<?php echo $module;?>" title="Редактировать"><img src="<?php echo $dir_images;?>icon.png" class="eicon edit-s" alt="icon"/></a>
                                                                            <a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=delete&id=<?php echo $economic_news['id'];?><? echo $link_added_query;?>" class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить эту новость?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
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
								<th style="width:400px" class="header <?php if($sort_by=="name") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=name&sort_dir=<?php echo ( ($sort_by=="name" and $sort_dir=="asc") ? "desc" : "asc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Название <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                                                <th>Валюта</th>
                                                                <th class="header <?php if($sort_by=="is_approved") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=is_approved&sort_dir=<?php echo ( ($sort_by=="is_approved" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Утвержден <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="matched_with") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=matched_with&sort_dir=<?php echo ( ($sort_by=="matched_with" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Совпадает с <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                                                <th class="header <?php if($sort_by=="date_add") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=date_add&sort_dir=<?php echo ( ($sort_by=="date_add" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Дата добавления<img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="enabled") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=enabled&sort_dir=<?php echo ( ($sort_by=="enabled" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Статус <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
								<th class="header <?php if($sort_by=="num_events") { echo ($sort_dir=="asc" ? "headerSortUp" : "headerSortDown");} ?>"><a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&sort_by=num_events&sort_dir=<?php echo ( ($sort_by=="num_events" and $sort_dir=="desc") ? "asc" : "desc"); ?>" class="ajax_link" data-module="<?php echo $module;?>">Событий <img src="<?php echo $dir_images;?>icon.png" alt="icon"/></a></th>
                                                                <th>&nbsp;</th>
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
                            <li><a href="#" data-active="delete">Удалить отмеченные</a></li>
                            <li><a href="#" data-active="approve">Утвердить отмеченные</a></li>
                        </ul>
                        <input type="hidden" name="do_active" value="hide">
                        <input type="hidden" name="group_actions" value="0">
                    </div>
                    <?php } ?>
				</form>
				<?php } else {?>
				<h3>По заданными критериям новостей не найдено</h3>
                <?php } ?>