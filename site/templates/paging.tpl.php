<?php 

if($total_pages_num>1) { 
	$visible_pages = $site->settings->num_links;
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
	if(strstr($_SERVER['HTTP_USER_AGENT'],"Mac"))  $key="Alt";
	else $key="Ctrl";
?>
						<ul class="paging">
                                                        <li class="prev <?php if($p<=1) { ?>current-page<?php } ?>">
								<?php if($p>1) { ?>
									<a href="<? echo SITE_URL.str_replace("%p%", $p-1, $paging_url);?>">предыдущая</a>
                                <?php }  ?>
							</li>
                                                        <li <?php if ($p==1) { ?>class="current-page"<?php } ?>><?php if ($p==1) { ?><span>1</span><?php } else { ?><a href="<? echo SITE_URL.str_replace("%p%", 1, $paging_url);?>">1</a><?php } ?></li>

							<?php 
							for($i=max($page_from, 2); $i<=$page_to; $i++) { 
							//Для крайних страниц "окна" выводим троеточие, если окно не возле границы навигации
								if (($i == $page_from and $i!=2) or ($i == $page_to and $i != $total_pages_num-1)) { ?>
                                                        <li><span>...</span></li>
                                <?php } 
								else { ?>
                                                        <li <?php if ($p==$i) { ?>class="current-page"<?php } ?>><?php if ($p==$i) { ?><span><?php echo $i; ?></span><?php } else { ?><a href="<? echo SITE_URL.str_replace("%p%", $i, $paging_url);?>"><?php echo $i; ?></a><?php } ?></li>
                            <?php 
								} 
							} 
							?>
							<li <?php if ($p==$total_pages_num) { ?>class="current-page"<?php } ?>><?php if ($p==$total_pages_num) { ?><span><?php echo $total_pages_num; ?></span><?php } else { ?><a href="<? echo SITE_URL.str_replace("%p%", $total_pages_num, $paging_url);?>"><?php echo $total_pages_num; ?></a><?php } ?></li>
							
                                                        <li class="next <?php if($p>=$total_pages_num) { ?>current-page<?php } ?>">
							<?php if($p<$total_pages_num) { ?>								
								<a href="<? echo SITE_URL.str_replace("%p%", $p+1, $paging_url);?>">следующая</a>
                                                        <?php }?>
                                                        </li>
						</ul>
						
<?php } ?>
