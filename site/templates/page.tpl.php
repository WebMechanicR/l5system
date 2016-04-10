<!-- main holder -->
<div class="main-holder">
    <!-- main content wrapper -->
    <div class="content-wrap">
        <!-- main content -->
        <div class="content">
            <?php $site->tpl->display('breadcrumbs'); ?>

            <h1><?php if(!empty($page_t['title_first'])) { echo $page_t['title_first']; } else {echo $page_t['title'];} ?></h1>
            <?php echo $page_t['body']; ?>
 
             <?php
                if($page_t['images']){
                    ?>  
                        <!-- images list -->
                        <div class="img-list">
                            <?php
                                foreach($page_t['images'] as $item){
                                    ?>
                                            <li><a href="<?php echo $pages_photos_dir.'big/'.$item['picture']; ?>" class="fb-gallery" data-fancybox-group="gallery" title="<?php echo $item['name']; ?>"><img src="<?php echo $pages_photos_dir.'small/'.$item['picture']; ?>" alt="<?php echo $item['name']; ?>"></a></li>
                                    <?php
                                }
                            ?>
                        </div>
                        <!-- images list end -->  
                    <?php
                }
            ?>
            
                       <?php if(isset($page_t['files']) and count($page_t['files'])>0) { ?>
                         	<div class="documents">
                            <h2>Файлы</h2>
                            <ul class="element-list">
                                <?php foreach($page_t['files'] as $file) {  ?>
                                <li>
                                    <figure><a href="<?php echo $pages_files_dir.$file['file']; ?>"><i class="icon-file file-<?php echo strtolower($file['type']); ?>"></i></a></figure>
                                    <div class="description">
                                        <h4><a href="<?php echo $pages_files_dir.$file['file']; ?>"><?php echo $file['name']; ?></a></h4>
                                        <div>
                                            <time datetime="<?php echo date('d.m.Y', $file['date_add']); ?>"><?php echo date('d.m.Y', $file['date_add']); ?></time>
                                            <?php
                                                    $size = round($file['size'] / 1024, 2);
                                                    if ($size > 1000)
                                                        $size = str_replace(",", ".", round($size / 1024, 2)) . " MB";
                                                    else
                                                        $size = str_replace(",", ".", $size) . " KB";
                                             ?>
                                            <span><?php echo strtoupper($file['type']); ?>,  <?php echo $size; ?></span>
                                        </div>
                                    </div>
                                </li>
                                <?php } ?>
                            </ul>
                            </div>
						<?php } ?>	

       </div>
        <!-- main content end -->
    </div>
    <!-- main content wrapper end -->

    <!-- sidebar -->
    <?php
    $parentPage;
    $current = $page_t['id'];
    while(isset($tree_pages['all'][intval($current)])){
        $page = $tree_pages['all'][intval($current)];
        if($page['parent'] == 0){   
             $parentPage = $page;
             break;
        }
        $current = $page['parent'];
    }
    ?>
    
    <aside class="sidebar"> <?php
            function get_pages_menu($tree_pages, $parent, $page_url, $current) {
                global $site;
                $result = "";
                if (isset($tree_pages['tree'][$parent])) {
                    $result = "<ul ".($current == $parent?"class='sidebar-menu'":"").">";
                        
                    foreach ($tree_pages['tree'][$parent] as $id) {
                        $page = $tree_pages['all'][$id];
                        if ($page['full_link'] != $page_url) {
                            $result .= '
                                                                                              <li>
                                                                                                  <a href="' . SITE_URL . $page['full_link'] . '/">' . $page['title'] . '</a>
                                                                                                  ' . get_pages_menu($tree_pages, $id, $page_url, $current) . '
                                                                                              </li>
                                                                                          ';
                    } else {
                            $result .= '
                                                                                              <li class="active">
                                                                                                  <span>' . $page['title'] . '</span>
                                                                                                  ' . get_pages_menu($tree_pages, $id, $page_url, $current) . '
                                                                                              </li>
                                                                                          ';
                        }
                    }
                    $result .= "</ul>";
                }

                return $result;
            }
        ?>
        <?php $tree = get_pages_menu($tree_pages, $current, $page_url, $current); ?>
        <?php if($tree): ?>
        <h3><?php echo $parentPage['title']; ?></h3>
       
	<?php echo $tree; ?>
        <?php endif; ?>
        
        <?php $site->display('sidebar_blocks');?>
    </aside>
    <!-- sidebar -->
</div>