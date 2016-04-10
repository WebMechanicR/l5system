				<?php if($site->admins->get_level_access("menus")==2) { ?>
                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=add&menu_id=<?php echo $menu_id;?>" class="button ajax_link" data-module="menus">
							<span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Добавить ссылку</span>
						</a>
					</span>
				</div>
                <?php } ?>	
				
				<h1><img class="menus-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Пункты меню &laquo;<?php echo $type_menu['name'];?>&raquo;</h1>
				<?php
					$t_tree_menus = (isset($tree_menus["tree"][$menu_id]) ? $tree_menus["tree"][$menu_id] :  array());
					if(count($t_tree_menus)>0) {
						function get_list_aux($tree_menus, $t_tree_menus, $menu_id, $dir_images, $site, $parent=0) {
							$t_aux_page = "";
							if(isset($t_tree_menus[$parent]) and is_array($t_tree_menus[$parent])) {
								if($parent>0) $t_aux_page .= '<ul>';
								foreach($t_tree_menus[$parent] as $page_id) {
									$t_aux_page .= '<li id="items_'.$page_id.'" ';
                                    $t_aux_page .= '><div class="sortable_line '.($tree_menus["all"][$page_id]['enabled'] ? '' : 'disable').'">';
										$t_aux_page .= '<div class="for_check">
														<input type="checkbox" name="check_item[]" value="'.$page_id.'" />
													</div>
													<div class="for_sort">
														<img src="'.$dir_images.'icon.png" class="eicon lines-s" alt="icon"/>
													</div>';
                                   $t_aux_page .= '<div class="for_name">
                                                    <img class="picon" src="'.$dir_images.'icon.png" alt="icon"/> ';
													
                                  $t_aux_page .= '<a href="'.DIR_ADMIN.'?module=menus&action=edit&id='.$page_id.'" class="ajax_link" data-module="menus">'.$tree_menus["all"][$page_id]['title'].'</a>';
								  
								  $t_aux_page .= '</div>
                                                <div class="for_status">
                                                    '.($tree_menus["all"][$page_id]['enabled'] ? 'Опубликовано' : 'Скрыто').'
                                                </div>';
												
										$t_aux_page .= '<div class="for_options">';
										$t_aux_page .= '<a href="'.DIR_ADMIN.'?module=menus&action=edit&menu_id='.$menu_id.'&id='.$page_id.'" class="ajax_link" data-module="menus" title="Редактировать"><img src="'.$dir_images.'icon.png" class="eicon edit-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=menus&action=duplicate&menu_id='.$menu_id.'&id='.$page_id.'" class="ajax_link" data-module="menus" title="Создать копию"><img src="'.$dir_images.'icon.png" class="eicon copy-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=menus&action=add&menu_id='.$menu_id.'&parent='.$page_id.'" class="ajax_link" data-module="menus" title="Добавить подстраницу"><img src="'.$dir_images.'icon.png" class="eicon subpage-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=menus&action=delete&menu_id='.$menu_id.'&id='.$page_id.'" class="delete-confirm" data-module="menus" data-text="Вы действительно хотите удалить эту ссылку?" title="Удалить"><img src="'.$dir_images.'icon.png" class="eicon del-s" alt="icon"/></a>';
										$t_aux_page .= '</div>
											</div>';
                                     
									
									$t_aux_page .= get_list_aux($tree_menus, $t_tree_menus, $menu_id, $dir_images, $site, $page_id);
									$t_aux_page .= '</li>';
								}
								if($parent>0) $t_aux_page .= '</ul>';
							}
							return $t_aux_page;
						}

						
				?>
                <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=group_actions&menu_id=<?php echo $menu_id;?>" method="post">
				<div class="pages-table <?php if($site->admins->get_level_access("menus")!=2) { ?>not_editable<?php } ?>">
					<table>
						<thead>
							<tr>
                            	<?php if($site->admins->get_level_access("menus")==2) { ?>
								<th class="check">
									<input type="checkbox"/>
								</th>
								<th class="sort"></th>
                                <?php } ?>
								<th class="name">Наименование  <a href="#" class="collapse_pages collapse_pages_expand dotted_link">развернуть все</a> <a href="#" class="collapse_pages collapse_pages_collapse dotted_link">свернуть все</a></th>
								<th class="status">Статус</th>
								<th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        	<tr>
                            	<td colspan="6">
                                	<ul class="sortable_pages <?php if($site->admins->get_level_access("menus")!=2) { ?>not_editable<?php } ?>">
                                    	<?php echo get_list_aux($tree_menus, $t_tree_menus, $menu_id, $dir_images, $site); ?> 
                                    </ul>
                                </td>
                            </tr>
                        </tbody>
 						<tfoot>
							<tr>
                            	<?php if($site->admins->get_level_access("menus")==2) { ?>
								<th class="check">
									<input type="checkbox"/>
								</th>
								<th class="sort"></th>
                                <?php } ?>
								<th class="name">Наименование  <a href="#" class="collapse_pages collapse_pages_expand dotted_link">развернуть все</a> <a href="#" class="collapse_pages collapse_pages_collapse dotted_link">свернуть все</a></th>
								<th class="status">Статус</th>
								<th>&nbsp;</th>
							</tr>
						</tfoot>
                       </table>
				</div>
					<?php if($site->admins->get_level_access("menus")==2) { ?>
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
					<?php if($site->admins->get_level_access("menus")==2) { ?>
                    <script>
                        $(function() {
                            $( ".sortable_pages" ).on( "sortupdate", function( event, ui ) {
                                var page_id = ui.item.attr('id').match(/(.+)[-=_](.+)/);
                                var data = $('.sortable_pages').nestedSortable('serialize')+'&update_menu_item_id='+page_id[2];
                                $( ".sortable_pages" ).nestedSortable( "disable" );
                                $.post('<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=update_sort&manu_id=<?php echo $menu_id;?>', data, function() {
                                        $( ".sortable_pages" ).nestedSortable( "enable" );
                                });
                            });
                        });
                    </script>
                    <?php } ?>

				<?php } ?>
