<h1><img class="security-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Контроль авторизации</h1>

<?php if($tryings){ 
		
?>
<h3>Зафиксированы попытки несанкционированного проникновения в панель управления вашей системы. Пожалуйста, ознакомьтесь.</h3>
 <form action="<?php echo DIR_ADMIN; ?>?module=<?php echo $module;?>&action=group_actions" method="post">
   				<div class="product-table">
					<table>
						<thead>
							<tr>
								<th>IP адрес</th>
								<th>Зафиксировано</th>
							</tr>
						</thead>
						<tbody>
                        	<?php foreach($tryings as $trying) {?>
							<tr>
								<td>
									<?php echo $trying['string']; ?>
								</td>
                                <td>
                                		<?php echo date("d-m-Y H:i:s", $trying['add']);?>
                                </td>
							</tr>
                            <?php } ?>
						</tbody>
						<tfoot>
							<tr>
                            	<th>IP адрес</th>
								<th>Зафиксировано</th>
							</tr>
						</tfoot>
					</table>
				</div>
                <div class="combo">
                    <span class="btn gray">
                        <button>Очистить</button>
                    </span>
                    <ul>
                        <li><a href="#" data-active="clearing_of_tryings_into_adminpanel">Очистить</a></li>
                    </ul>
                        <input type="hidden" name="do_active" value="clearing_of_tryings_into_adminpanel">
                        <input type="hidden" name="group_actions" value="0">
						<input type="hidden" name="check_item[]" value="1"/>
                </div>
				</form>
<?php
}else{
?>
<h2>Попыток несанкционированного проникновения не зафиксировано.</h2>
<script>
					$(function() {
						update_newcount_module("antivirus", <?php echo (intval($site->antivirus->GetNumNotices(true)) + count($site->antivirus->GetAlerts(true)))?"' ! '":"0";?>);
					});
</script>
<?php } ?>