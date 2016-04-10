<?php if (!$isAJAX) { ?>
<div class="content-wrap">
    <div class="content">
            <?php $site->tpl->display('breadcrumbs'); ?>
		    <h1>Обратный звонок</h1>
<?php } else { ?>
    <div class="popup-head">
        <h2>Обратный звонок</h2>			
    </div>
<?php } ?>
<!-- form question bl -->
<?php if (isset($success) and $success) { ?>
    Спасибо! Ваша заявка отправлена менеджеру. В ближайшее время с Вами свяжутся.
<?php } else { ?>
            <form action="<?php echo SITE_URL;?>ordercall/" method="post">
            	<input type="text" class="spec_field" name="last_name" value=''>
                    <div class="form-popup">
                    <div class="form-line">
                        <div class="label-holder">
                            <label for="subject-field">Тема звонка</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['subject'])) echo "failed"; ?>">
                            <input type="text"  name = "subject" value = "<?php if(isset($call) and isset($call['subject'])) echo $call['subject'];?>" id="subject-field">
                        </div>
                        <?php if(isset($errors) and isset($errors['subject'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="name-field">Представьтесь</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['name'])) echo "failed"; ?>">
                            <input type="text"  name = "name" value = "<?php if(isset($call) and isset($call['name'])) echo $call['name'];?>" id="name-field">
                        </div>
                        <?php if(isset($errors) and isset($errors['name'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="phone-field">Ваш телефон</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['phone'])) echo "failed"; ?>">
                            <input type="text" id="phone-field" name = "phone" value = "<?php if(isset($call) and isset($call['phone'])) echo $call['phone'];?>">
                        </div>
                        <?php if(isset($errors) and isset($errors['phone'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>                    

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="besttime-field">Удобное время звонка</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['besttime'])) echo "failed"; ?>">
                            <input type="text"  name = "besttime" value = "<?php if(isset($call) and isset($call['besttime'])) echo $call['besttime'];?>" id="besttime-field">
                        </div>
                        <?php if(isset($errors) and isset($errors['besttime'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="notice-field">Ваше собщение</label>
                        </div>
                        <div class="input-holder input-area">
                            <textarea id="notice-field" name = "message"><?php if(isset($call) and isset($call['message'])) echo F::br2nl($call['message']);?></textarea>
                        </div>
                    </div>

                    <div class="form-buttons">
                        <div class="btn btn-default">
                            <span>Отправить</span>
                            <input type="submit" value="">
                        </div>
                    </div>
                    </div>
            </form>

<?php } ?>
<!-- form question bl end -->

<?php if (!$isAJAX) { ?>
        </div>
        <!-- main content end -->
    </div>
<aside class="sidebar">
	<?php $site->display('sidebar_blocks');?>
</aside>
<?php } ?>
