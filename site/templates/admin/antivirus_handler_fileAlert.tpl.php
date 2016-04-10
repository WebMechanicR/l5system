<h1><img class="security-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Защита файловой системы</h1>

<?php if($difference){ 
			if(isset($sendInfo['code']) and ($sendInfo['code'] == 500)):
?>
				<h3 style = "color: red">В настоящий момент невозможно связаться с сервером разработчиков, поэтому угрозы не были отправлены. Отмеченные вами файлы помещены в список угроз.</h3><br/><br/>
			<?php endif; ?>
<h3>Обнаружены потенциальные угрозы в файловой системе. Пожалуйста, отметьте соответствующие файлы, если они изменены вами, или отправьте их в список угроз.</h3>
 <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=group_actions" method="post">
   				<div class="product-table">
					<table>
						<thead>
							<tr>
								<th>
									<input type="checkbox"/>
								</th>
								<th>Имя файла</th>
								<th>Дата модификации</th>
							</tr>
						</thead>
						<tbody>
                        	<?php foreach($difference as $key => $file) { ?>
							<tr>
								<td>
									<input type="checkbox" name="check_item[]" value="<?php echo $key; ?>"/>
								</td>
								<td>
									<?php echo wordwrap($file['name'], 80, '<br/>', true); ?>
								</td>
                                <td>
                                		<?php echo date("d-m-Y H:i:s", @filemtime($_SERVER['DOCUMENT_ROOT'].$file['name']));?>
                                </td>
							</tr>
                            <?php } ?>
						</tbody>
						<tfoot>
							<tr>
								<th>
									<input type="checkbox"/>
								</th>
                            	<th>Имя файла</th>
								<th>Дата модификации</th>
							</tr>
						</tfoot>
					</table>
				</div>
                <div class="combo">
                    <span class="btn gray">
                        <button>Игнорировать</button>
                    </span>
                    <button class="dicon arrdown">меню</button>
                    <ul>
                        <li><a href="#" data-active="ignore_file_alert">Игнорировать</a></li>
                        <li><a href="#" data-active="tick_files_as_alert">Отметить как угроза</a></li>
                    </ul>
                        <input type="hidden" name="do_active" value="ignore_file_alert">
                        <input type="hidden" name="group_actions" value="0">
                </div>
				</form>
<?php
}else{
?>
<h2><?php echo ($site->request->method('post'))?"Потенциальные угрозы обработаны":"Никаких подозрительных файлов не найдено."; ?></h2>
<script>
					$(function() {
						update_newcount_module("antivirus", <?php echo (intval($site->antivirus->GetNumNotices(true)) + count($site->antivirus->GetAlerts(true)))?"' ! '":"0";?>);
					});
</script>
<?php } ?>