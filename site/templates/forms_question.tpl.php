<?php if (!$isAJAX) { ?>
<div class="content-wrap">
    <div class="content">
            <?php $site->tpl->display('breadcrumbs'); ?>
		    <h1>Задайте вопрос</h1>
<?php } else { ?>
    <div class="popup-head">
        <h2>Задайте вопрос</h2>			
    </div>
<?php } ?>

<?php if (isset($success) and $success) { ?>
    Спасибо! Ваш вопрос отправлен менеджеру. В ближайшее время с Вами свяжутся.
<?php } else { ?>

			<form action="<?php echo SITE_URL.'question/'; ?>" method="post">
	            	<input type="text" class="spec_field" name="last_name" value=''>
			<!-- form question bl -->
				<div class="form-popup form-question">
                    <div class="form-line">
                        <div class="label-holder">
                            <label for="name-field">Представьтесь</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['name'])) echo "failed"; ?>">
                            <input type="text"  name = "name" value = "<?php if(isset($form) and isset($form['name'])) echo $form['name'];?>" id="name-field">
                        </div>
                        <?php if(isset($errors) and isset($errors['name'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="email-field">Телефон или e-mail</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['email'])) echo "failed"; ?>">
                            <input type="text"  name = "email" value = "<?php if(isset($form) and isset($form['email'])) echo $form['email'];?>" id="email-field">
                        </div>
                        <?php if(isset($errors) and isset($errors['email'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="notice-field">Ваш вопрос</label>
                        </div>
                        <div class="input-holder input-area <?php if(isset($errors) and isset($errors['message'])) echo "failed"; ?>">
                            <textarea id="notice-field" name = "message"><?php if(isset($form) and isset($form['message'])) echo F::br2nl($form['message']);?></textarea>
                        </div>
                        <?php if(isset($errors) and isset($errors['message'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>
                    
                    <div class="form-buttons">
                        <div class="btn btn-default">
                            <span>Отправить</span>
                            <input type="submit" value="">
                        </div>
                    </div>


				</div>
				<!-- form question bl end -->
			</form>			
<?php } ?>

<?php if (!$isAJAX) { ?>
        </div>
        <!-- main content end -->
    </div>
<aside class="sidebar">
	<?php $site->display('sidebar_blocks');?>
</aside>
<?php } ?>
