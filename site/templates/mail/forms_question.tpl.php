<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title><?php echo $site->settings->site_title;?></title>
</head>

<body style="font:12px Arial, Tahoma, Verdana, sans-serif">
			    <h1>Новый вопрос.</h1>
                            
                            <p><strong>Контактное лицо:</strong> <?php if(isset($form) and isset($form['name'])) echo $form['name'];?></p>
                            <p><strong>E-mail или телефон:</strong> <?php if(isset($form) and isset($form['email'])) echo $form['email'];?></p>
                            <p><strong>Вопрос:</strong> <br><?php echo $form['message'];?></p>
                            
<br><br>
<table border="0" cellspacing="0" cellpadding="10" width="100%" bgcolor="#EBEBEB">
	<tr valign="top">
    	<td width="180" align="left" style="padding-top:25px; padding-bottom:25px; "><font style="font-size:12px;" >&#169; <a href="<?php echo SITE_URL;?>" ><font color="#000"><?php echo $site->settings->site_title;?></font></a><?php echo date('Y');?></font></td>
    </tr>
</table>
</body>
</html>