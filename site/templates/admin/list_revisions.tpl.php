			<?php if(isset($list_revisions) and count($list_revisions)>0) { ?>
                <!-- Top panel start -->
				<div class="top-panel">
					<!-- Document carousel start -->
					<ul class="doc-carousel">
                    <?php if(isset($from_revision) and $from_revision>0) { ?>
					  <li>
						<figure>
						  <a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=<?php echo $action;?>&id=<? echo $list_revisions[0]['for_id']; ?>" class="ajax_link" data-module="<?php echo $module;?>"><img class="doc-ico" src="<?php echo $dir_images;?>icon.png" alt="doc"/></a>
						  <figcaption>
									<time>Актуальная версия</time>
							</figcaption>
						  </figure>
						</li>
                    <?php } ?>
					<?php foreach($list_revisions as $revision) { ?>
						<li>
							<figure>
							  <a href="<? echo DIR_ADMIN;?>?module=<?php echo $module;?>&action=<?php echo $action;?>&id=<? echo $revision['for_id']; ?>&from_revision=<? echo $revision['id']; ?>" class="ajax_link" data-module="<?php echo $module;?>"><img class="doc-ico" src="<?php echo $dir_images;?>icon.png" alt="doc"/></a>
								<figcaption>
									<time><?php echo date('H:i d-m-Y', $revision['date_add']); ?></time>
								</figcaption>
							</figure>
					  </li>
					<?php } ?>
					</ul>
					<!-- Document carousel end -->
					
					<div class="clip">
						<div class="right">
							<span>История версий</span>
							<img class="sicon" src="<?php echo $dir_images;?>icon.png" alt="arrow"/>
						</div>
						<p class="txtctr"><?php if(isset($from_revision) and $from_revision>0) { ?>Доступна более свежая версия документа<?php } else { ?>Доступны ранние версии документа.<?php } ?></p>
					</div>
					
				</div>
  				<!-- Top panel end -->
				<?php	} ?>
