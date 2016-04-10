<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title><?php echo $site->settings->site_title;?></title>
</head>

<body style="font:12px 'Trebuchet MS',Tahoma,Arial,Verdana,'sans-serif'">
							<h1><font color="#2B7085">Заказ звонка.</font></h1>
                            
                            
                            <p><strong>Тема звонка:</strong> <?php if(isset($call) and isset($call['subject'])) echo $call['subject'];?></p>
                            <p><strong>Контактное лицо:</strong> <?php if(isset($call) and isset($call['name'])) echo $call['name'];?></p>
                            <p><strong>Телефон:</strong> <?php if(isset($call) and isset($call['phone'])) echo $call['phone'];?></p>
                             <p><strong>Удобное время звонка:</strong> <?php if(isset($call) and isset($call['besttime'])) echo $call['besttime'];?></p>
                            <?php if(isset($call) and isset($call['message']) and $call['message']!='') { ?>
                            <p><strong>Собщение:</strong> <br><?php echo $call['message'];?></p>
                            <?php } ?>
                            
<br><br>
<table border="0" cellspacing="0" cellpadding="10" width="100%" bgcolor="#3D90AA">
	<tr valign="top">
    	<td width="180" align="left" style="padding-top:25px; padding-bottom:25px; "><font style="font-size:12px;" color="#ffffff">&#169; 2004 — <?php echo date('Y');?> <br >&laquo;<a href="<?php echo SITE_URL;?>" style="color:#ffffff;"><?php echo $site->settings->site_title; ?></a>&raquo;</font></td>
    </tr>
</table>
</body>
</html>