<h1><img class="security-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Монитор запросов</h1>

<?php if($injections){ 
			if(isset($sendInfo['code']) and ($sendInfo['code'] == 500)):
?>
				<h3 style = "color: red">В настоящий момент невозможно связаться с сервером разработчиков, поэтому угрозы не были отправлены. Отмеченные вами пункты помещены в список угроз.</h3><br/><br/>
			<?php endif; ?>
<h3>Были предприняты попытки атаковать вашу систему посредством инъекции. Если это ваши действия, то проигнорируйте соответствующие пункты. Иначе, отправьте их в список угроз.</h3>
 <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=group_actions" method="post">
   				<div class="product-table">
					<table>
						<thead>
							<tr>
								<th>
									<input type="checkbox"/>
								</th>
								<th>№</th>
								<th>IP адрес</th>
								<th>Объект</th>
								<th>Тип</th>
								<th>Зафиксировано</th>
								<th style = 'width: 200px'>URL</th>
								<th>Содержание</th>
							</tr>
						</thead>
						<tbody>
                        	<?php foreach($injections as $injection) { ?>
							<tr>
								<td>
									<input type="checkbox" name="check_item[]" value="<?php echo $injection['id']; ?>"/>
								</td>
								<td>
									<?php echo $injection['id']; ?>
								</td>
								<td>
									<?php echo $injection['ip']; ?>
								</td>
								<td>
									<?php echo $injection['object']; ?>
								</td>
								<td>
									<?php echo $injection['type']; ?>
								</td>
								<td>
                                	<?php echo date("d-m-Y H:i:s", $injection['time']);?>
                                </td>
								<td>
									<?php echo wordwrap($injection['url'], 45, "<br/>", true); ?>
								</td>
								<td>
									<a href="javascript: $('#alertContent_<?php echo $injection['id']; ?>').show()">смотреть</a>
									<textarea id = "alertContent_<?php echo $injection['id']; ?>" style = "display: none;"><?php echo htmlspecialchars(stripslashes($injection['content'])); ?></textarea>
								</td>
							</tr>
                            <?php } ?>
						</tbody>
						<tfoot>
							<tr>
								<th>
									<input type="checkbox"/>
								</th>
								<th>№</th>
								<th>IP адрес</th>
								<th>Объект</th>
								<th>Тип</th>
								<th>Зафиксировано</th>
								<th style = 'width: 200px'>URL</th>
								<th>Содержание</th>
							</tr>
						</tfoot>
					</table>
				</div>
				
				<?php $site->tpl->display('paging'); ?>
				
                <div class="combo">
                    <span class="btn gray">
                        <button>Игнорировать</button>
                    </span>
                    <button class="dicon arrdown">меню</button>
                    <ul>
                        <li><a href="#" data-active="ignore_injection_alert">Игнорировать</a></li>
                        <li><a href="#" data-active="tick_injection_as_alert">Отметить как угроза</a></li>
						<li><a href="#" data-active="ignore_injection_all_alert">Игнорировать все</a></li>
                    </ul>
                        <input type="hidden" name="do_active" value="ignore_injection_alert">
                        <input type="hidden" name="group_actions" value="0">
                </div>
				</form>
<?php
}else{
?>
<h2><?php echo ($site->request->method('post'))?"Потенциальные угрозы обработаны":"Попыток внедрения не обнаружено."; ?></h2>
<script>
					$(function() {
						update_newcount_module("antivirus", <?php echo (intval($site->antivirus->GetNumNotices(true)) + count($site->antivirus->GetAlerts(true)))?"' ! '":"0";?>);
					});
</script>
<?php } ?>