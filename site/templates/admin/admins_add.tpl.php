				<h1><img class="admins-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <?php if(isset($admin_t['id']) and $admin_t['id']>0) { ?>Редактировать<?php } else { ?>Добавить<?php } ?> администратора</h1>
                <form action="<?php echo DIR_ADMIN; ?>?module=admins&action=edit" method="post">
                <?php if(isset($admin_t['id'])) { ?><input type="hidden" name="id" value="<?php echo $admin_t['id'];?>"><?php } ?>
                <div class="tab-content">
											
						<ul class="form-lines wide">
							<li>
								<label for="name">Имя</label>
								<div class="input text <?php if(isset($errors['name'])) echo "fail";?>">
									<input type="text" id="name" name="name" value="<?php if(isset($admin_t['name'])) echo $admin_t['name'];?>"/>
                                    <?php if(isset($errors['name'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
								</div>
							</li>
							<li>
								<label for="login">Логин</label>
								<div class="input text <?php if(isset($errors['login'])) echo "fail";?>">
									<input type="text" id="login" name="login" value="<?php if(isset($admin_t['login'])) echo $admin_t['login'];?>" autocomplete="off"/>
                                    <?php if(isset($errors['login']) and $errors['login']=='no_login') { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                                    <?php if(isset($errors['login']) and $errors['login']=='exists_login') { ;?><p class="error">администратор с таким логином уже существует</p><?php } ?>
								</div>
							</li>
							<li>
								<label for="ip">IP <img class="q-ico" src="<?php echo $dir_images;?>icon.png" alt="question" rel="tooltip" title="Если указан, доступ данному администратору будет открыт только с этого IP адреса."/></label>
								<div class="input text">
									<input type="text" id="ip" name="ip" value="<?php if(isset($admin_t['ip'])) echo $admin_t['ip'];?>" autocomplete="off"/>
								</div>
							</li>
							<li>
								<label for="access_class">Класс прав</label>
								<div class="input <?php if(isset($errors['access_class'])) echo "fail";?>">
                                	<select class="select" name="access_class">
                                    <?php
										foreach($admin_classes as $admin_class) {
									?>
                                        <option value="<?php echo $admin_class['id'];?>" <?php if(isset($admin_t['access_class']) and $admin_t['access_class']==$admin_class['id']) echo "selected"; ?>><?php echo $admin_class['name'];?></option>
                                     <?php } ?>
                                    </select>

                                    <?php if(isset($errors['access_class'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
								</div>
							</li>
                                <li>
                                    <label>Контакты менеджера</label>
                                    <div class="frame small_editor">
                                        <textarea name="contacts" id="contacts"><?php if(isset($admin_t['contacts'])) echo $admin_t['contacts'];?></textarea>
                                        <script>
                                            CKEDITOR.replace( 'contacts', {height: 150} );
                                        </script>
                                    </div>
                                </li>
  							<li>
								<label for="npass">Новый пароль</label>
								<div class="input text <?php if(isset($errors['new_password'])) echo "fail";?>">
									<input type="password" id="npass" name="npass" autocomplete="off" />
                                     <?php if(isset($errors['new_password']) and $errors['new_password']=="no_password") { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                                     <?php if(isset($errors['new_password']) and $errors['new_password']=="invalid_new") { ;?><p class="error">новые пароли не совпадают</p><?php } ?>
								</div>
							</li>
   							<li>
								<label for="ncpass">Повторите новый пароль</label>
								<div class="input text <?php if(isset($errors['new_password'])) echo "fail";?>">
									<input type="password" id="ncpass" name="ncpass" autocomplete="off" />
                                     <?php if(isset($errors['new_password']) and $errors['new_password']=="no_password") { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                                    <?php if(isset($errors['new_password']) and $errors['new_password']=="invalid_new") { ;?><p class="error">новые пароли не совпадают</p><?php } ?>
								</div>
							</li>
						</ul>
											
				</div>
                
                <div class="bt-set clip">
                	<div class="left">
						<span class="btn standart-size blue hide-icon">
                        	<button class="ajax_submit" data-success-name="Cохранено">
                                <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <i>Сохранить</i></span>
                            </button>
						</span>
                        <span class="btn standart-size blue hide-icon">
							<button class="submit_and_exit">
								<span>Сохранить и выйти</span>
							</button>
						</span>
                   </div>
                   <?php if(isset($admin_t['id']) and $admin_t['id']>0) { ?>
                   <div class="right">
						<span class="btn standart-size red">
							<button class="delete-confirm" data-module="admins" data-text="Вы действительно хотите удалить этого администратора?" data-url="<?php echo DIR_ADMIN; ?>?module=admins&action=delete&id=<?php echo $admin_t['id']; ?>">
								<span><img class="bicon cross-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Удалить админа</span>
							</button>
						</span>
					</div>
					<?php } ?>
				</div>
</form>
<?php 
/*} else { ?>
<div class="success_block">
	<strong>Администратор добавлен.</strong>
    <script>
		sD.redirect("<?php echo DIR_ADMIN;?>?module=admins", "admins");
	</script>
</div>
<?php }*/
 ?>
