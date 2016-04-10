<div class="product-table images <?php if(!isset($limit_photos) or $limit_photos>1) {?>sortable<?php } ?>">
					<table>
						<thead>
							<tr>
								<th>Фото</th>
								<th>Превью</th>
								<th>Название</th>
								<?php if(!isset($limit_photos) or $limit_photos>1) {?><th>Позиция</th><?php } ?>
								<th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        <?php 
							$sort_photo_new = 1;
							if(isset($content_photos) and count($content_photos)>0) {
								foreach($content_photos as $content_photo) {
									if($content_photo['sort']>$sort_photo_new) $sort_photo_new = $content_photo['sort'];
						?>
							<tr>
								<td >
                                	<?php if($module=="catalog" and $action=="edit_product"){ ?>
									<a href="<?php echo $content_photos_dir."super/".$content_photo['picture'];?>" target="_blank"><img src="<?php echo $content_photos_dir."big/".$content_photo['picture'];?>" alt=""/></a>
                                	<?php } else { ?>
									<a href="<?php echo $content_photos_dir."big/".$content_photo['picture'];?>" target="_blank"><img src="<?php echo $content_photos_dir."big/".$content_photo['picture'];?>" alt=""/></a>
                                	<?php } ?>
                                </td>
								<td >
                                	<div class="preview_image">
                                    	<?php if( ($module=="catalog" and $action=="edit_product") or ($module=="news" and $action=="edit") ){ ?>
										<img src="<?php echo $content_photos_dir."normal/".$content_photo['picture'];?>" alt="">
                                        <?php } else { ?>
										<img src="<?php echo $content_photos_dir."small/".$content_photo['picture'];?>" alt="">
                                		<?php } ?>
                                    </div>
                                    <div class="file_new_preview">
                                        <span>изменить превью</span>
                                        <input type="file" accept="image/jpeg,image/png,image/gif" class="upload_preview" name="new_preview" data-url="<?php echo DIR_ADMIN; ?>ajax_update_image_preview.php?module=<?php echo $module;?>&id=<?php echo $content_photo['id']; ?>&action=<?php echo (isset($content_photos_update_preview_action) ? $content_photos_update_preview_action : "update_image_preview") ?>">
									</div>
                                </td>
								<td>
                                	<div class="input text">
									<input type="text" name="name_pictures[<?php echo $content_photo['id'];?>]" value="<?php echo $content_photo['name'];?>">
                                    </div>
								</td>
                                <?php if(!isset($limit_photos) or $limit_photos>1) {?>
								<td>
									<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
								</td>
                                <?php } ?>
								<td>
									<a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&id=<?php echo $content_photo['id']; ?>&action=<?php echo (isset($content_photos_delete_action) ? $content_photos_delete_action : "delete_image") ?>" class="delete-confirm delete-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это изображение?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
                                </td>
							</tr>
                          <?php
								}
								$sort_photo_new++;
							}
						  ?>
							<?php if(!isset($limit_photos) or $limit_photos>count($content_photos)) { ?>
							<tr class="addPhoto">
								<td>
                                	<div class="input_smart_file">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Файл изображения</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
                                        <input type="file" accept="image/jpeg,image/png,image/gif" name="picture">
                                    </div>
								</td>
								<td>
                                	<div class="input_smart_file small-size">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Файл превью</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
										<input type="file" accept="image/jpeg,image/png,image/gif" name="picture_prev">
                                    </div>
								</td>
 								<td>
                                	<div class="input text always_visible">
									<input type="text" name="new_name_picture" value="">
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_type') { ;?><p class="error">неверный тип файла</p><?php } ?>
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_size') { ;?><p class="error">слишком большой файл</p><?php } ?>
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_upload') { ;?><p class="error">папка загрузки недоступна для записи или недостаточно места</p><?php } ?>
                                    	<?php if(isset($errors['photo']) and $errors['photo']=='error_internal') { ;?><p class="error">внутренняя ошибка сервера</p><?php } ?>
                                    </div>
								</td>
                               <?php if(!isset($limit_photos) or $limit_photos>1) {?>
								<td>
                                    <input type="hidden" name="sort_photo_new" value="<?php echo $sort_photo_new; ?>">
								</td>
                                <?php } ?>
								<td>&nbsp;									
								</td>
							</tr>
                            <?php 
								if(!isset($limit_photos) or $limit_photos>1) {
									$uniq_id_upload = rand(100, 100000);
								?>
                            <tr id="for_multy_uploader_<?php echo $uniq_id_upload;?>">
                            	<td colspan="5">
                                	<div class="multy_uploader" id="container_multy_uploader_<?php echo $uniq_id_upload;?>">
                                        Вы можете выбрать несколько файлов одновременно<br>
                                        <span class="btn standart-size">
                                                    <a href="#" class="button pickfiles" id="pickfiles_<?php echo $uniq_id_upload;?>">
                                                        <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файлы</span>
                                                    </a>
                                        </span>
                                        <div class="filelist" id="filelist_<?php echo $uniq_id_upload;?>">
                                        
                                        </div>
                                    </div>
                                    <script>
										$(function() {
											$(".button.pickfiles").click(function(event) {
												event.preventDefault();
											});
																				
											var uploader = new plupload.Uploader({
												runtimes : 'html5,flash,html4',
												browse_button : 'pickfiles_<?php echo $uniq_id_upload;?>',
												container: 'container_multy_uploader_<?php echo $uniq_id_upload;?>',
												max_file_size : '10mb',
												url : '<?php echo DIR_ADMIN; ?>ajax_add_image.php',
												resize: false,
												multipart: true,
												multipart_params: {
													for_id: "<?php echo $content_photos_for_id;?>",
													session_id: "<?php echo session_id();?>",
													module: "<?php echo $module;?>",
													action: "<?php echo (isset($content_photos_add_action) ? $content_photos_add_action : "add_image") ?>"
												},
												flash_swf_url : '<?php echo $dir_js;?>plupload/plupload.flash.swf',
												filters : [
													{title : "Image files", extensions : "jpg,jpeg,gif,png"}
												]
											});
											
											uploader.bind('Init', function(up, params) {
												if(params.runtime=="html4") $("#for_multy_uploader_<?php echo $uniq_id_upload;?>").hide();
											});
											
											uploader.init();
											
											uploader.bind('FilesAdded', function(up, files) {
												$.each(files, function(i, file) {
													$('#filelist_<?php echo $uniq_id_upload;?>').append(
														'<div class="file" id="' + file.id + '">' +
														'<span class="fileName">'+file.name + ' (' + plupload.formatSize(file.size) + ') </span>' +
														'<span class="percentage"></span>'+
														'<div class="fileProgress"><div class="fileProgressBar"></div></div>'+
														'</div>');
												});
												up.refresh();
												uploader.start();
											});
											
											uploader.bind('UploadProgress', function(up, file) {
												$('#' + file.id + " .percentage").html(" - "+file.percent + "%");
												$('#' + file.id + " .fileProgressBar").stop().animate({width: file.percent + "%"}, 200);
											});
											
											uploader.bind('FileUploaded', function(up, file, info) {
												var response = JSON.parse(info.response);
												 if(response.success) {
													 $('#' + file.id ).hide();
													 $("#for_multy_uploader_<?php echo $uniq_id_upload;?>").closest("table").find("tr.addPhoto").before(
													 			'<tr>'+
																'<td >'+
																	'<img src="<?php echo $content_photos_dir. ( ( ($module=="catalog" and ($action=="edit_product" or $action=="add_product")) or $module=="news") ? "big/" : "normal/") ;?>'+response.image+'" alt=""/>'+
																'</td>'+
																'<td >'+
																	'<div class="preview_image">'+
																		'<img src="<?php echo $content_photos_dir.( (($module=="catalog" and ($action=="edit_product" or $action=="add_product")) or $module=="news" ) ? "normal/" : "small/");?>'+response.image+'" alt=""/>'+
																	'</div>'+
																	'<div class="file_new_preview">'+
																		'<span>изменить превью</span>'+
																		'<input type="file" accept="image/jpeg,image/png,image/gif" class="upload_preview" name="new_preview" data-url="<?php echo DIR_ADMIN; ?>ajax_update_image_preview.php?module=<?php echo $module;?>&id='+response.image_id+'&action=<?php echo (isset($content_photos_update_preview_action) ? $content_photos_update_preview_action : "update_image_preview") ?>">'+
																	'</div>'+
																'</td>'+
																'<td>'+
																	'<div class="input text">'+
																	'<input type="text" name="name_pictures['+response.image_id+']" value="">'+
																	'</div>'+
																'</td>'+
																'<td>'+
																	'<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>'+
																'</td>'+
																'<td>'+
																	'<a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&id='+response.image_id+'&action=<?php echo (isset($content_photos_delete_action) ? $content_photos_delete_action : "delete_image") ?>" class="delete-confirm delete-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить это изображение?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>'+
																'</td>'+
															'</tr>'
													 );
												 }
												 else {
													 $('#' + file.id ).addClass("error").append('<div class="fileError">'+response.error+'</div>')
												 }
											});
											
											uploader.bind('Error', function(up, args) {
												$('#' + args.file.id ).addClass("error").append('<div class="fileError">'+args.message+'</div>')
											});
										});
									</script>
                                </td>
                            </tr>
                            <?php 
									}
								} 
							?>
						</tbody>
					</table>
</div>