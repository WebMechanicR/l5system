
<!-- sidebar -->
<aside class="sidebar">
    <h3>Каталог товаров</h3>
    <?php
    $catalog_full_link = $site->pages->get_full_link_module('catalog'); 
    function get_list_categories($tree_categories, $catalog_full_link, $parent=0) {
		$t_aux_page = "";
		if(isset($tree_categories["tree"][$parent]) and is_array($tree_categories["tree"][$parent])) {
			foreach($tree_categories["tree"][$parent] as $page_id) {
				if($tree_categories["all"][$page_id]['enabled']) {
					$t_aux_page .= '<li>'
                                                . '<a href="'.SITE_URL.$catalog_full_link.'/'.$tree_categories["all"][$page_id]['full_link'].'/" title="'.$tree_categories["all"][$page_id]['title'].'">'.$tree_categories["all"][$page_id]['title'].'</a>'
                                                .(isset($tree_categories['tree'][$page_id])?'<ul>'.get_list_categories($tree_categories, $catalog_full_link, $page_id).'</ul>':'')
                                                . '</li>'."\n";
				}
			}
		}
		return $t_aux_page;
	}
    ?>
    <!-- catalog menu -->
    <ul class="catalog-menu">
        <?php echo get_list_categories($tree_categories, $catalog_full_link); ?>
    </ul>
    <!-- catalog menu -->
    
    <?php $site->display('sidebar_blocks');?>
</aside>
<!-- sidebar -->