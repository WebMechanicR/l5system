<div class="label-holder">
    <label for="code-field">Введите цифры с картинки:</label>
</div>
<div class="img-code">
    <img src="<?php echo SITE_URL . "ajax/captcha_show.php"; ?>?sid=<?php echo md5(uniqid()) ?>" onclick='$(this).attr("src", site_url + "ajax/captcha_show.php?sid=" + Math.random())' id ='captcha_img'  alt="Кликните, чтобы обновить картинку" width="158" height="32">
</div>
<div class="input-holder input-code  <?php if(isset($captchaError) and $captchaError) echo "failed"; ?>">
    <input type="text" placeholder="" id="code-field" name = "<?php echo $anyNameOfCaptcha; ?>">
</div>
<?php if(isset($captchaError) and $captchaError) { ?>
	<p class="error">неверно введен код с картинки</p>
<?php } ?>
<script>
    $("#captcha_img").attr("src", site_url + "ajax/captcha_show.php?sid=" + Math.random())
</script>