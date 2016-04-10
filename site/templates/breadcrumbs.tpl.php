<ul class="breadcrumbs">
                    <li><a href="<?php echo SITE_URL; ?>">Главная</a></li>
                <?php 
					if(!isset($page_t) and isset($page_url) and $page_url!='') {
						$page_t = $site->pages->get_page_withcache($page_url);
					}
					
					function print_breadcrumbs_parent_pages($tree_pages, $parent) {
						$ar_pages = array();
						while($parent) {
							$ar_pages[] = '<li><a href="'.SITE_URL.$tree_pages["all"][$parent]['full_link'].'/">'.$tree_pages["all"][$parent]['title'].'</a></li>';
							$parent = $tree_pages["all"][$parent]['parent'];  
						}
                                                $len = count($ar_pages);
                                                for($i = $len - 1; $i >= 0; $i--)
                                                            echo $ar_pages[$i];
					}

					function print_breadcrumbs_parent_categs($tree_categories, $catalog_full_link, $parent) {
						$ar_pages = array();
						while($parent) {
							$ar_pages[] = '<li><a href="'.SITE_URL.$catalog_full_link.'/'.$tree_categories["all"][$parent]['full_link'].'/">'.$tree_categories["all"][$parent]['title'].'</a></li>';
							$parent = $tree_categories["all"][$parent]['parent'];
						}
                                                $len = count($ar_pages);
                                                    for($i = $len - 1; $i >= 0; $i--)
                                                            echo $ar_pages[$i];
					}
                                if(isset($page_t['id'])) print_breadcrumbs_parent_pages($tree_pages, $tree_pages["all"][ $page_t['id'] ]['parent']);
				switch($module) {
					case "catalog":
                                        if($action=="index"){
                                            if(!isset($category) or !$category){
                                                
                                            }
                                            else{
					?>
                                                <li><a href="<?php echo SITE_URL.$catalog_full_link; ?>">Каталог товаров</a></li>
                                                <?php print_breadcrumbs_parent_categs($tree_categories, $catalog_full_link, $category['parent']); ?>
                    <?php
                                            }
						}
						elseif($action=="show_product"){
					?>
                                                <li><a href="<?php echo SITE_URL.$catalog_full_link; ?>">Каталог товаров</a></li>
                    <?php   print_breadcrumbs_parent_categs($tree_categories, $catalog_full_link, $category['parent']);  
                            echo '<li><a href="'.SITE_URL.$catalog_full_link.'/'.$tree_categories["all"][$category['id']]['full_link'].'/">'.$category['title'].'</a></li>'; 
						}
					break;
					case "news":
						if($action == "index"){
						}
						else{
							?>
								<li><a href="<?php echo SITE_URL.$site->pages->get_full_link_module('news'); ?>/">Новости</a></li>
							<?php   
						}
					break;
				}
				?>
</ul>