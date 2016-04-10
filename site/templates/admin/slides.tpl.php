                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=add" class="button ajax_link" data-module="<?php echo $module;?>">
							<span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Добавить слайд</span>
						</a>
					</span>
				</div>
				<h1><img class="slides-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Слайды на главной</h1>
                <?php
					if(count($list_slides)>0) {
				?>

                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>" method="post">
				<div class="product-table slides sortable">
					<table>
						<thead>
							<tr>
								<th>
									<input type="checkbox"/>
								</th>
								<th>Название</th>
								<th>Картинка</th>
								<th>Статус</th>
                                <th>Позиция</th>
								<th>&nbsp;</th>
							</tr>
						</thead>
                        
						<tbody>
                        <?php 
							foreach($list_slides as $slide) { 
							?>
							<tr class="update_onfly <?php echo $slide['enabled'] ? '' : 'disable';?>">
                            	<td>
									<input type="checkbox" name="check_item[]" value="<?php echo $slide['id'];?>"/>
                                    <input type="hidden" name="slide_name[<?php echo $slide['id']; ?>]" value="<?php echo $slide['title']; ?>"/>
								</td>
								<td>
                                	<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $slide['id'];?>" class="ajax_link" data-module="<?php echo $module;?>"><?php echo $slide['title'];?></a>
								</td>
								<td>
									<?php if($slide['img']!="") { ?><img src="<?php echo $content_photos_dir."small/".$slide['img'];?>" alt=""/><?php } ?>
								</td>
                                <td>
                                	<?php echo $slide['enabled'] ? 'Опубликовано' : 'Скрыто';?>
                                </td>
                                <td>
                                	<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
                               </td>
								<td>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=edit&id=<?php echo $slide['id'];?>" class="ajax_link" data-module="<?php echo $module;?>" title="Редактировать"><img src="<?php echo $dir_images;?>icon.png" class="eicon edit-s" alt="icon"/></a>
									<a href="<?php echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=duplicate&id=<?php echo $slide['id'];?>" class="ajax_link" data-module="<?php echo $module;?>" title="Создать копию"><img src="<?php echo $dir_images;?>icon.png" class="eicon copy-s" alt="icon"/></a>
									<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=delete&id=<?php echo $slide['id']; ?>" class="delete-confirm" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот слайд?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
								</td>
							</tr>
						<?php } ?>	
							
						</tbody>
						<tfoot>
							<tr>
								<th>
									<input type="checkbox"/>
								</th>
								<th>Название</th>
								<th>Картинка</th>
								<th>Статус</th>
                                <th>Позиция</th>
								<th>&nbsp;</th>
							</tr>
						</tfoot>
					</table>
				</div>
                
                   <div class="combo">
                        <span class="btn gray">
                            <button>Скрыть отмеченные</button>
                        </span>
                        <button class="dicon arrdown">меню</button>
                        <ul>
                            <li><a href="#" data-active="hide">Скрыть отмеченные</a></li>
                            <li><a href="#" data-active="show">Опубликовать отмеченные</a></li>
                            <li><a href="#" data-active="delete">Удалить отмеченные</a></li>
                        </ul>
                        <input type="hidden" name="do_active" value="hide">
                        <input type="hidden" name="group_actions" value="0">
                    </div>
				</form>
				<?php } ?>