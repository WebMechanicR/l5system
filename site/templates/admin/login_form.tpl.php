<!DOCTYPE HTML>
<html lang="en-US">
<head>
	<meta charset="UTF-8">
	<title>Вход в личный кабинет</title>
	
	<!--[if lt IE 9]><script type="text/javascript" src="<?php echo $dir_js;?>html5shiv.js"></script><![endif]-->
	
	<!-- Main CSS file -->
	<link rel="stylesheet" type="text/css" href="<?php echo $dir_css;?>main.css" media="all"/>
	
</head>
<body class="login">
	<div id="wrapper">
		
		<!-- Site header start -->
		<div id="header">
			<div class="fix-width">
				
				<div class="logo">
					<a href="<?php echo DIR_ADMIN; ?>">
						<span class="top">система управления</span>
						<span class="btm"><?php echo $site_host;?></span>
					</a>
				</div>
				
				<div class="clear"></div>
				
			</div><!-- .fix-width end -->
		</div>
		<!-- Site header end -->
		
		<div id="main" class="fix-width">
			
			<!-- Main site content start -->
			<div id="content">
            <?php if($num_try>=3) { //бан ip на 15 минут ?>
            	<div class="error_message">
                	<p>Доступ с Вашего IP адреса закрыт на 15 минут</p>
                </div>
            <?php } 
				else { ?>
            	<?php if(isset($_POST['v_login']) and isset($_POST['v_pas'])) { ?>
            	<div class="error_message">
                	<p>Ошибка! Введенный логин или пароль неверный.</p>
                    <p>У Вас осталось <?php echo (3-$num_try)." ".F::get_right_okonch(3-$num_try, "попыток", "попытка", "попытки");?>, после чего доступ будет закрыт на 15 минут.</p>
                </div>
				<?php } ?>
				<form action="<?php echo DIR_ADMIN; ?>" method="post">
					
					<ul class="form-lines">
						<li>
							<label for="login">Имя пользователя</label>
							<div class="input text">
								<input placeholder="логин" type="text" name="v_login" id="login"/>
							</div>
						</li>
						<li>
							<label for="pass">Пароль</label>
							<div class="input text">
								<input placeholder="пароль" type="password" name="v_pas" id="pass"/>
							</div>
						</li>
					</ul>
					
					<div class="btn">
						<input type="submit" value="Войти"/>
					</div>
					
				</form>
				<?php } ?>
				<ul class="external">
					<li>
						<a href="<?php echo  SITE_URL;?>">
							<img src="<?php echo $dir_images;?>icon.png" alt="icon" class="ticon arrow-b"/>
							Перейти на сайт <?php echo $site_host;?>
						</a>
					</li>
					<!--<li>
						<a href="#">
							<img src="<?php echo $dir_images;?>icon.png" alt="icon" class="ticon tool-b"/>
							Помощь и техподдержка
						</a>
					</li>-->
				</ul>
				
			</div>
			<!-- Main site content start -->
			
			<div class="clear"></div>
		</div><!-- #main end -->
		
	</div><!-- #wrapper end -->
</body>
</html>