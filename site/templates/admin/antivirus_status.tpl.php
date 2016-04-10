<div class="bt-set right">
		<span class="btn standart-size <?php echo ($enabled) ? "red" : "blue"; ?>">
			<a href="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&enabled=<?php echo ($enabled)?0:1; ?>&flag=1" class="button ajax_link" data-module="<?php echo $module;?>">
				<?php if($enabled) { ?>
                <span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Выключить</span>
				<?php } else { ?>
                <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Включить</span>
                <?php } ?>
            </a>
		</span>
</div>
<h1><img class="security-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Статус защиты</h1>

<?php
	$notices = $site->antivirus->GetNotices(true);
	$dangerousStatus = count($notices) + count($alerts);
?>

<div class = "<?php /*status (dangerous or not dangerous) */ echo ($dangerousStatus)?"danger":"without_danger"; ?>">
<?php
if($dangerousStatus and $enabled):
?>
	<h2 style = "color: red;">Возможно системе грозит опасность!</h2>
	<ul>
	<?php 
		if($alerts):
	?>
		<li>Обнаруженные угрозы не отправлены разработчикам.</li>
	<?php
		endif;
		if($notices):
			$shown = array();
			foreach($notices as $notice){
				$action = $notice['action'];
				if(($action == 'file_alert') and !in_array('file_alert', $shown))
				{
					$shown[] = 'file_alert';
				?>
					<li>
						В системе найдены подозрительные файлы. Пожалуйста, <a href = "<?php echo DIR_ADMIN; ?>?module=antivirus&action=file_alert" class="ajax_link" data-module="antivirus">ознакомьтесь.</a>
					</li>
				<?php
				}
				if(($action == 'injection_alert') and !in_array('injection_alert', $shown))
				{
					$shown[] = 'injection_alert';
				?>
					<li>
						Были предприняты попытки атаковать вашу систему посредством инъекции. <a href = "<?php echo DIR_ADMIN; ?>?module=antivirus&action=injection_alert" class="ajax_link" data-module="antivirus">подробнее</a>
					</li>
				<?php
				}
				if(($action == 'adminLogin_alert') and !in_array('adminLogin_alert', $shown))
				{
					$shown[] = 'adminLogin_alert';
				?>
					<li>
						Зафиксированы попытки несанкционированного проникновения в панель управления вашей системы. <a href = "<?php echo DIR_ADMIN; ?>?module=antivirus&action=adminLogin_alert" class="ajax_link" data-module="antivirus">подробнее</a>
					</li>
				<?php
				}
			}
		endif;
	?>
	</ul>
<?php
elseif($enabled):
?>
	<h2 style = "color: green;">Все хорошо! Угроз не обнаружено!</h2>
<?php
else:
?>
	<h2>Защита выключена.</h2>
<?php
endif;
?>
</div><br/><br/>
<?php 
if($alerts and $enabled){
			if(isset($sendInfo['code']) and ($sendInfo['code'] == 500)):
?>
			<h3 style = "color: red">В настоящий момент невозможно связаться с сервером разработчиков. Пожалуйста попробуйте позже.</h3><br/><br/>
			<?php endif; ?>
<form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>" method="get" enctype="multipart/form-data">
	
				<h3>Ожидается отправка разработчикам следующих обнаруженных угроз:</h3>
   				<div class="product-table">
					<table> 
						<thead>
							<tr>
								<th>Угроза</th>
								<th>Время обнаружения</th>
							</tr>  
						</thead>
						<tbody>   
                        	<?php foreach($alerts as $alert) { ?>
							<tr>
								<td>
									<?php echo wordwrap($alert['string'], 100, '<br/>'); ?>
								</td>
								<td>
									<?php echo date("d-m-Y H:i:s", $alert['time']); ?>
								</td>
							</tr>
                            <?php } ?>
						</tbody>
						<tfoot>
							<tr>
								<th>Угроза</th>
								<th>Время обнаружения</th>
							</tr>
						</tfoot>
					</table>
					<p>Нажмите "Отправить" и обнаруженные данные будут отправлены разработчикам.</p>
				</div>
				<input type = "hidden" name = "send" value = "1"/>
				<input type = "hidden" name = "flag" value = "1"/>
				<input type = "hidden" name = "enabled" value = "<?php echo $enabled; ?>"/>
	<div class="bt-set clip">
        <div class="left">
			<span class="btn standart-size blue hide-icon">
                <button class="ajax_submit" data-success-name="Отправлено">
                    <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <i>Отправить</i></span>
                </button>
			</span>
        </div>
	</div>
</form>
<?php
	}
?>
<script>
	$(function() {
		update_newcount_module("antivirus", <?php echo ($dangerousStatus)?'" ! "':"0"; ?>);
	});
</script>