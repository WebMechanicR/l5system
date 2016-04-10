				<?php if($site->admins->get_level_access("catalog")==2) { ?>
                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=add_category" class="button ajax_link" data-module="catalog">
							<span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Добавить категорию</span>
						</a>
					</span>
				</div>
                <?php } ?>	
				
				<h1><img class="catalog-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Категории</h1>
				<?php
				
					if(count($tree_categories["tree"])>0) {
						function get_list_categs($tree_categories, $dir_images, $site, $parent=0) {
							$t_aux_page = "";
							if(isset($tree_categories["tree"][$parent]) and is_array($tree_categories["tree"][$parent])) {
								if($parent>0) $t_aux_page .= '<ul>';
								foreach($tree_categories["tree"][$parent] as $category_id) {
									$t_aux_page .= '<li id="items_'.$category_id.'"><div class="sortable_line '.($tree_categories["all"][$category_id]['enabled'] ? '' : 'disable').'">';
									if($site->admins->get_level_access("catalog")==2) {
										$t_aux_page .= '<div class="for_check">
														<input type="checkbox" name="check_item[]" value="'.$category_id.'" />
													</div>
													<div class="for_sort">
														<img src="'.$dir_images.'icon.png" class="eicon lines-s" alt="icon"/>
													</div>';
									}
                                   $t_aux_page .= '<div class="for_name">
                                                    <img class="picon" src="'.$dir_images.'icon.png" alt="icon"/> ';
													
                                  if($site->admins->get_level_access("catalog")==2) $t_aux_page .= '<a href="'.DIR_ADMIN.'?module=catalog&action=products&category_id='.$category_id.'" class="ajax_link" data-module="catalog">'.$tree_categories["all"][$category_id]['title'].'</a>';
                                  else $t_aux_page .= $tree_categories["all"][$category_id]['title'];
								  
								  $t_aux_page .= '</div>
                                                <div class="for_status">
                                                    '.($tree_categories["all"][$category_id]['enabled'] ? 'Опубликовано' : 'Скрыто').'
                                                </div>';
												
										$t_aux_page .= '<div class="for_options">
														<a href="'.SITE_URL.$site->pages->get_full_link_module("catalog")."/".$tree_categories["all"][$category_id]['full_link'].'/" target="_blank" title="Посмотреть на сайте"><img src="'.$dir_images.'icon.png" class="eicon link-s" alt="icon"/></a>';
									if($site->admins->get_level_access("catalog")==2) {		
										$t_aux_page .= '<a href="'.DIR_ADMIN.'?module=catalog&action=edit_category&id='.$category_id.'" class="ajax_link" data-module="catalog" title="Редактировать"><img src="'.$dir_images.'icon.png" class="eicon edit-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=catalog&action=duplicate_category&id='.$category_id.'" class="ajax_link" data-module="catalog" title="Создать копию"><img src="'.$dir_images.'icon.png" class="eicon copy-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=catalog&action=add_category&parent='.$category_id.'" class="ajax_link" data-module="catalog" title="Добавить подкатегорию"><img src="'.$dir_images.'icon.png" class="eicon subpage-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=catalog&action=delete_category&id='.$category_id.'" class="delete-confirm" data-module="catalog" data-text="Вы действительно хотите удалить эту категорию?" title="Удалить"><img src="'.$dir_images.'icon.png" class="eicon del-s" alt="icon"/></a>';
									}
										$t_aux_page .= '</div>
											</div>';
                                     
									
									$t_aux_page .= get_list_categs($tree_categories, $dir_images, $site, $category_id);
									$t_aux_page .= '</li>';
								}
								if($parent>0) $t_aux_page .= '</ul>';
							}
							return $t_aux_page;
						}

						
				?>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=group_actions_category" method="post">
				<div class="pages-table <?php if($site->admins->get_level_access("catalog")!=2) { ?>not_editable<?php } ?>">
					<table>
						<thead>
							<tr>
                            	<?php if($site->admins->get_level_access("catalog")==2) { ?>
								<th class="check">
									<input type="checkbox"/>
								</th>
								<th class="sort"></th>
                                <?php } ?>
								<th class="name">Наименование <a href="#" class="collapse_pages collapse_pages_expand dotted_link">развернуть все</a> <a href="#" class="collapse_pages collapse_pages_collapse dotted_link">свернуть все</a></th>
								<th class="status">Статус</th>
								<th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        	<tr>
                            	<td colspan="6">
                                	<ul class="sortable_pages <?php if($site->admins->get_level_access("catalog")!=2) { ?>not_editable<?php } ?>">
                                    	<?php echo get_list_categs($tree_categories, $dir_images, $site); ?> 
                                    </ul>
                                </td>
                            </tr>
                        </tbody>
						<tfoot>
							<tr>
                            	<?php if($site->admins->get_level_access("catalog")==2) { ?>
								<th class="check">
									<input type="checkbox"/>
								</th>
								<th class="sort"></th>
                                <?php } ?>
								<th class="name">Наименование <a href="#" class="collapse_pages collapse_pages_expand dotted_link">развернуть все</a> <a href="#" class="collapse_pages collapse_pages_collapse dotted_link">свернуть все</a></th>
								<th class="status">Статус</th>
								<th>&nbsp;</th>
							</tr>
						</tfoot>
                        </table>
				</div>
					<?php if($site->admins->get_level_access("catalog")==2) { ?>
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
                    <?php } ?>
                </form>
					<?php if($site->admins->get_level_access("catalog")==2) { ?>
                    <script>
                        $(function() {
                            $( ".sortable_pages" ).on( "sortupdate", function( event, ui ) {
                                var category_id = ui.item.attr('id').match(/(.+)[-=_](.+)/);
                                var data = $('.sortable_pages').nestedSortable('serialize')+'&update_category_id='+category_id[2];
                                $( ".sortable_pages" ).nestedSortable( "disable" );
                                $.post('<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=update_sort_category', data, function() {
                                        $( ".sortable_pages" ).nestedSortable( "enable" );
                                });
                            });
                        });
                    </script>
                    <?php } ?>

				<?php } ?>
