<h1><img class="tools-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/>Личные настройки</h1>

<form action="<?php echo DIR_ADMIN; ?>?module=admins&action=profile" method="post">
<div class="tab-content">
											
						<ul class="form-lines wide">
							<li>
								<label for="name">Имя</label>
								<div class="input text <?php if(isset($errors['name'])) echo "fail";?>">
									<input type="text" id="name" name="name" value="<?php echo $admin_t['name'];?>"/>
                                    <?php if(isset($errors['name'])) { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
								</div>
							</li>
							<li>
								<label for="login">Логин</label>
								<div class="input text <?php if(isset($errors['login'])) echo "fail";?>">
									<input type="text" id="login" name="login" value="<?php echo $admin_t['login'];?>"/>
                                    <?php if(isset($errors['login']) and $errors['login']=='no_login') { ;?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                                    <?php if(isset($errors['login']) and $errors['login']=='exists_login') { ;?><p class="error">администратор с таким логином уже существует</p><?php } ?>
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
							  <label for="pass">Действующий пароль</label>
								<div class="input text <?php if(isset($errors['real_password'])) echo "fail";?>">
									<input type="password" id="pass" name="pass" autocomplete="off" />
                                     <?php if(isset($errors['real_password'])) { ;?><p class="error">неверный пароль</p><?php } ?>
								</div>
							</li>
  							<li>
								<label for="npass">Новый пароль</label>
								<div class="input text <?php if(isset($errors['new_password'])) echo "fail";?>">
									<input type="password" id="npass" name="npass" />
                                     <?php if(isset($errors['new_password'])) { ;?><p class="error">новые пароли не совпадают</p><?php } ?>
								</div>
							</li>
   							<li>
								<label for="ncpass">Повторите новый пароль</label>
								<div class="input text <?php if(isset($errors['new_password'])) echo "fail";?>">
									<input type="password" id="ncpass" name="ncpass" />
                                     <?php if(isset($errors['new_password'])) { ;?><p class="error">новые пароли не совпадают</p><?php } ?>
								</div>
							</li>
						</ul>
											
				</div>
                
                <div class="bt-set clip">
						<span class="btn standart-size blue hide-icon">
                        	<button class="ajax_submit" data-success-name="Cохранено">
                                <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <i>Сохранить</i></span>
                            </button>
						</span>
				</div>
                
</form>