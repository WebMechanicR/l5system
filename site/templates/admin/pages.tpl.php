				<?php if($site->admins->get_level_access("pages")==2) { ?>
                <div class="bt-set right">
					<span class="btn standart-size">
						<a href="<?php echo DIR_ADMIN; ?>?module=pages&action=add" class="button ajax_link" data-module="pages">
							<span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Добавить страницу</span>
						</a>
					</span>
				</div>
                <?php } ?>	
				
				<h1><img class="page-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Страницы сайта</h1>
				<?php
					if(count($tree_pages["tree"])>0) {
						function get_list_aux($tree_pages, $dir_images, $site, $parent=0) {
							$t_aux_page = "";
							if(isset($tree_pages["tree"][$parent]) and is_array($tree_pages["tree"][$parent])) {
								if($parent>0) $t_aux_page .= '<ul>';
								foreach($tree_pages["tree"][$parent] as $page_id) {
									$t_aux_page .= '<li id="items_'.$page_id.'" ';
									if(!$tree_pages["all"][$page_id]['nesting']) $t_aux_page .= ' class="mjs-nestedSortable-no-nesting"';
                                    $t_aux_page .= '><div class="sortable_line '.($tree_pages["all"][$page_id]['enabled'] ? '' : 'disable').'">';
									if($site->admins->get_level_access("pages")==2) {
										$t_aux_page .= '<div class="for_check">
														<input type="checkbox" name="check_item[]" value="'.$page_id.'" />
													</div>
													<div class="for_sort">
														<img src="'.$dir_images.'icon.png" class="eicon lines-s" alt="icon"/>
													</div>';
									}
                                   $t_aux_page .= '<div class="for_name">
                                                    <img class="picon" src="'.$dir_images.'icon.png" alt="icon"/> ';
													
                                  if($site->admins->get_level_access("pages")==2) $t_aux_page .= '<a href="'.DIR_ADMIN.'?module=pages&action=edit&id='.$page_id.'" class="ajax_link" data-module="pages">'.$tree_pages["all"][$page_id]['title'].'</a>';
                                  else $t_aux_page .= $tree_pages["all"][$page_id]['title'];
								  
								  $t_aux_page .= '</div>
                                                <div class="for_status">
                                                    '.($tree_pages["all"][$page_id]['enabled'] ? 'Опубликовано' : 'Скрыто').'
                                                </div>';
												
										$t_aux_page .= '<div class="for_options">
														<a href="'.SITE_URL.$tree_pages["all"][$page_id]['full_link'].'/" target="_blank" title="Посмотреть на сайте"><img src="'.$dir_images.'icon.png" class="eicon link-s" alt="icon"/></a>';
									if($site->admins->get_level_access("pages")==2) {		
										$t_aux_page .= '<a href="'.DIR_ADMIN.'?module=pages&action=edit&id='.$page_id.'" class="ajax_link" data-module="pages" title="Редактировать"><img src="'.$dir_images.'icon.png" class="eicon edit-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=pages&action=duplicate&id='.$page_id.'" class="ajax_link" data-module="pages" title="Создать копию"><img src="'.$dir_images.'icon.png" class="eicon copy-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=pages&action=add&parent='.$page_id.'" class="ajax_link" data-module="pages" title="Добавить подстраницу"><img src="'.$dir_images.'icon.png" class="eicon subpage-s" alt="icon"/></a>
														<a href="'.DIR_ADMIN.'?module=pages&action=delete&id='.$page_id.'" class="delete-confirm" data-module="pages" data-text="Вы действительно хотите удалить эту страницу?" title="Удалить"><img src="'.$dir_images.'icon.png" class="eicon del-s" alt="icon"/></a>';
									}
										$t_aux_page .= '</div>
											</div>';
                                     
									
									$t_aux_page .= get_list_aux($tree_pages, $dir_images, $site, $page_id);
									$t_aux_page .= '</li>';
								}
								if($parent>0) $t_aux_page .= '</ul>';
							}
							return $t_aux_page;
						}

						
				?>
                <form action="<?php echo DIR_ADMIN; ?>?module=pages&action=group_actions" method="post">
				<div class="pages-table <?php if($site->admins->get_level_access("pages")!=2) { ?>not_editable<?php } ?>">
					<table>
						<thead>
							<tr>
                            	<?php if($site->admins->get_level_access("pages")==2) { ?>
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
                                	<ul class="sortable_pages <?php if($site->admins->get_level_access("pages")!=2) { ?>not_editable<?php } ?>">
                                    	<?php echo get_list_aux($tree_pages, $dir_images, $site); ?> 
                                    </ul>
                                </td>
                            </tr>
                        </tbody>
 						<tfoot>
							<tr>
                            	<?php if($site->admins->get_level_access("pages")==2) { ?>
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
					<?php if($site->admins->get_level_access("pages")==2) { ?>
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
					<?php if($site->admins->get_level_access("pages")==2) { ?>
                    <script>
                        $(function() {
                            $( ".sortable_pages" ).on( "sortupdate", function( event, ui ) {
                                var page_id = ui.item.attr('id').match(/(.+)[-=_](.+)/);
                                var data = $('.sortable_pages').nestedSortable('serialize')+'&update_page_id='+page_id[2];
                                $( ".sortable_pages" ).nestedSortable( "disable" );
                                $.post('<?php echo DIR_ADMIN; ?>?module=pages&action=update_sort', data, function() {
                                        $( ".sortable_pages" ).nestedSortable( "enable" );
                                });
                            });
                        });
                    </script>
                    <?php } ?>

				<?php } ?>
