<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title><?php echo $site->settings->site_title;?></title>
</head>
<body style="font:12px Arial, Tahoma, Verdana, sans-serif">
    <h1>Обновление в списке новостей экономического календаря</h1>
    <p> Уведомляем Вас о том, что список новостей экономического календаря пополнен на <?php echo $added_news; ?>
                                                            <br/>
                                                            Вы можете настроить параметры интерпретации новый новостей по <a href="<?php echo SITE_URL.'admin/?module=economic_news&action=index'; ?>">ссылке</a>
    </p>
							<br><br>
<table border="0" cellspacing="0" cellpadding="10" width="100%" bgcolor="#EBEBEB">
	<tr valign="top">
    	<td width="180" align="left" style="padding-top:25px; padding-bottom:25px; "><font style="font-size:12px;" >&#169; <a href="<?php echo SITE_URL;?>" ><font color="#000"><?php echo ($site->settings->site_title)?$site->settings->site_title:SITE_URL; ?></font></a> <?php echo date('Y');?></font></td>
        <!--<td width="205" align="left" style="padding-top:25px; padding-bottom:25px; ">
        	Бесплатный звонок по России<br>
        	<font style="font-size:16px;" ><?php echo $site->settings->site_phone2;?></font>
        	<p><font style="font-size:12px;" ><?php echo $site->settings->office_hours;?></font></p>
        </td>
        <td width="205" align="left" style="padding-top:25px; padding-bottom:25px; ">
        	Оформление заказа в Москве<br>
        	<font style="font-size:16px;" ><?php echo $site->settings->site_phone;?></font>
        </td>
    	<td align="left" style="padding-top:25px; padding-bottom:25px; ">
        		<a href="mailto:<?php echo $site->settings->site_email2;?>" ><font style="font-size:12px;" ><?php echo $site->settings->site_email2;?></font></a>
				<p><a href="skype:<?php echo $site->settings->skype;?>?call" ><font style="font-size:12px;" ><?php echo $site->settings->skype;?></font></a></p>
        </td>-->
    </tr>
</table>
</body>
</html>