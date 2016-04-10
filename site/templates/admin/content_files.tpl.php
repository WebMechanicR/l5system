<div class="product-table files sortable">
					<table>
						<thead>
							<tr>
								<th class="for_file">Файл</th>
								<th>Размер</th>
								<th>Название</th>
								<?php if(!isset($limit_files) or $limit_files>1) {?><th>Позиция</th><?php } ?>
								<th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
                        <?php 
							$sort_file_new = 1;
							if(isset($content_files) and count($content_files)>0) {
								foreach($content_files as $content_file) {
									if($content_file['sort']>$sort_file_new) $sort_file_new = $content_file['sort'];
						?>
							<tr>
								<td >
									<a href="<?php echo $content_files_dir.$content_file['file'];?>" target="_blank"><img src="<?php echo $dir_images;?>icon.png" class="file-icon file-<?php echo $content_file['type'];?>" alt="icon"/></a>
								</td>
								<td >
									<?php
										$size = round($content_file['size']/1024,2);
										if($size>1000) $size = str_replace(",",".",round($size/1024,2))." МБ";
										else $size = str_replace(",",".", $size)." КБ";
										echo $size;
									?>
								</td>
								<td>
                                	<div class="input text">
									<input type="text" name="name_files[<?php echo $content_file['id'];?>]" value="<?php echo $content_file['name'];?>">
                                    </div>
								</td>
                               <?php if(!isset($limit_files) or $limit_files>1) {?>
								<td>
									<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>
								</td>
                                <?php } ?>
								<td>
									<a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&id=<?php echo $content_file['id']; ?>&action=<?php echo (isset($content_files_delete_action) ? $content_files_delete_action : "delete_file") ?>" class="delete-confirm delete-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот файл?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>
								</td>
							</tr>
                          <?php
								}
								$sort_file_new++;
							}
						  ?>
							<?php if(!isset($limit_files) or $limit_files>count($content_files)) { ?>
							<tr class="addPhoto">
								<td colspan="2">
                                	<div class="input_smart_file">
                                            <span class="btn standart-size">
                                                <span class="button">
                                                    <span><img class="bicon plus-s" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выбрать файл</span>
                                                </span>
                                            </span>
                                        <span class="file_name"></span>
                                        <input type="file" name="file">
                                    </div>
								</td>
 								<td>
                                	<div class="input text always_visible">
									<input type="text" name="new_name_file" value="">
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_type') { ;?><p class="error">неверный тип файла</p><?php } ?>
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_size') { ;?><p class="error">слишком большой файл</p><?php } ?>
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_upload') { ;?><p class="error">папка загрузки недоступна для записи или недостаточно места</p><?php } ?>
                                    	<?php if(isset($errors['file']) and $errors['file']=='error_internal') { ;?><p class="error">внутренняя ошибка сервера</p><?php } ?>
                                    </div>
								</td>
                                <?php if(!isset($limit_files) or $limit_files>1) {?>
								<td>
                                    <input type="hidden" name="sort_file_new" value="<?php echo $sort_file_new; ?>">
								</td>
                                <?php } ?>
								<td>&nbsp;									
								</td>
							</tr>
                            <?php 
								if(!isset($limit_files) or $limit_files>1) {
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
												url : '<?php echo DIR_ADMIN; ?>ajax_add_file.php',
												resize: false,
												multipart: true,
												multipart_params: {
													for_id: "<?php echo $content_files_for_id;?>",
													session_id: "<?php echo session_id();?>",
													module: "<?php echo $module;?>",
													action: "<?php echo (isset($content_files_add_action) ? $content_files_add_action : "add_file") ?>"
												},
												flash_swf_url : '<?php echo $dir_js;?>plupload/plupload.flash.swf'
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
																	'<a href="<?php echo $content_files_dir;?>'+response.file_name+'" target="_blank"><img src="<?php echo $dir_images;?>icon.png" class="file-icon file-'+response.file_type+'" alt="icon"/></a>'+
																'</td>'+
																'<td>'+response.file_size+'</td>'+
																'<td>'+
																	'<div class="input text">'+
																	'<input type="text" name="name_files['+response.file_id+']" value="">'+
																	'</div>'+
																'</td>'+
																'<td>'+
																	'<img src="<?php echo $dir_images;?>icon.png" class="eicon lines-s" alt="icon"/>'+
																'</td>'+
																'<td>'+
																	'<a href="<?php echo DIR_ADMIN; ?>ajax_delete_image.php?module=<?php echo $module;?>&id='+response.file_id+'&action=<?php echo (isset($content_files_delete_action) ? $content_files_delete_action : "delete_file") ?>" class="delete-confirm delete-image" data-module="<?php echo $module;?>" data-text="Вы действительно хотите удалить этот файл?" title="Удалить"><img src="<?php echo $dir_images;?>icon.png" class="eicon del-s" alt="icon"/></a>'+
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