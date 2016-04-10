<?php 
	for($i=1; $i<=3; $i++) {
		if($site->settings->{"widget_code".$i}) {
?>
<div class="widget">
	<?php echo $site->settings->{"widget_code".$i};?>
</div>
<?php 
		}
	}
?>
	<?php echo $site->settings->text_sidebar;?>
