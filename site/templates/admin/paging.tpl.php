<?php 

if($total_pages_num>1) { 
	$visible_pages = $site->settings->admin_num_links;
	$page_from = 1;

	//Если выбранная пользователем страница дальше середины "окна" - начинаем вывод уже не с первой
	if ($p > floor($visible_pages/2)) {
		$page_from = max(1, $p-floor($visible_pages/2)-1);
	}	
	
	//Если выбранная пользователем страница близка к концу навигации - начинаем с "конца-окно" 
	if ($p > $total_pages_num-ceil($visible_pages/2)) {
		$page_from = max(1, $total_pages_num-$visible_pages-1);
	}
	
	//До какой страницы выводить - выводим всё окно, но не более общего количества страниц 
	$page_to = min($page_from+$visible_pages, $total_pages_num-1);
?>
				<div class="right for_paging">
                        <ul class="paging">
                        	<?php if($p>1) { ?>
                            <li class="first"><a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&p=<?php echo $p-1; ?><? echo $paging_added_query;?>" class="ajax_link" data-module="<?php echo $module;?>">&#8249;</a></li>
                            <?php } ?>
							<li><?php if ($p==1) { ?><span>1</span><?php } else { ?><a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&p=1<? echo $paging_added_query;?>" class="ajax_link" data-module="<?php echo $module;?>">1</a><?php } ?></li>
							<?php 
							for($i=max($page_from, 2); $i<=$page_to; $i++) { 
								//Для крайних страниц "окна" выводим троеточие, если окно не возле границы навигации
								if (($i == $page_from and $i!=2) or ($i == $page_to and $i != $total_pages_num-1)) { ?>
                                <li><a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&p=<?php echo $i; ?><? echo $paging_added_query;?>" class="ajax_link" data-module="<?php echo $module;?>">...</a></li>
                                <?php } 
								else { ?>
                            	<li><?php if ($p==$i) { ?><span><?php echo $i; ?></span><?php } else { ?><a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&p=<?php echo $i; ?><? echo $paging_added_query;?>" class="ajax_link" data-module="<?php echo $module;?>"><?php echo $i; ?></a><?php } ?></li>
                            <?php 
								} 
							} 
							?>
							<li><?php if ($p==$total_pages_num) { ?><span><?php echo $total_pages_num; ?></span><?php } else { ?><a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&p=<?php echo $total_pages_num; ?><? echo $paging_added_query;?>" class="ajax_link" data-module="<?php echo $module;?>"><?php echo $total_pages_num; ?></a><?php } ?></li>
                            <?php if($p<$total_pages_num) { ?>
                            <li class="last"><a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&p=<?php echo $p+1; ?><? echo $paging_added_query;?>" class="ajax_link" data-module="<?php echo $module;?>">&#8250;</a></li>
                            <?php } ?>
                       </ul>
                    </div>
<?php } ?>