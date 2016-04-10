<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title><?php echo $site->settings->site_title;?></title>
</head>
<?php $catalog_full_link = $site->pages->get_full_link_module("catalog"); ?>
<body style="font:12px Arial, Tahoma, Verdana, sans-serif">
							<h1>Новый  заказ <?php if(isset($order_id)) echo "№".$order_id;?>.</h1>
							<h2>Детали заказа</h2>
                            <p><strong>Контактное лицо:</strong> <?php if(isset($order) and isset($order['name'])) echo $order['name'];?></p>
                            <p><strong>Телефоны:</strong> 
                            <?php 
								if(isset($order) and isset($order['phones'])) { 
									foreach($order['phones'] as $i=>$phone) {
										if($i>0) echo ", ";
										echo $phone['phone']." (".$order_type_phones[$phone['type']].")";
									}
								} 
							?>
                             </p>
                            <p><strong>e-mail:</strong> <?php if(isset($order) and isset($order['email'])) echo $order['email'];?></p>
                        
                             <p><strong>Адрес доставки:</strong> <br><?php if(isset($order) and isset($order['address'])) echo $order['address'];?></p>
                             <p><strong>Способ доставки:</strong> <?php if(isset($order) and isset($order['delivery_id']) and isset($deliveries[$order['delivery_id']])) echo $deliveries[$order['delivery_id']]['name'];?></p>
                             <p><strong>Тип оплаты:</strong> <?php if(isset($order) and isset($order['payment_type_id']) and isset($payment_types[$order['payment_type_id']])) echo $payment_types[$order['payment_type_id']]['name'];?></p>
							<?php if(isset($order) and isset($order['comment']) and $order['comment']!='') { ?>
                            <p><strong>Примечания к заказу:</strong> <br><?php echo $order['comment'];?></p>
                            <?php } ?>
                           
								<h2>Заказанные товары</h2>
						<!-- order table bl -->									
								<table border="0" cellspacing="0" cellpadding="10" width="100%">
									<thead>
										<tr>
											<th width="172" align="left" style="padding-bottom:5px; border-bottom: 1px solid #990000">Фото</th>
											<th align="left" style="padding-bottom:5px; border-bottom: 1px solid #990000"><nobr>Наименование</nobr></th>
											<th align="left" style="padding-bottom:5px; border-bottom: 1px solid #990000"><nobr>Кол-во, шт.</nobr></th>
											<th align="left" style="padding-bottom:5px; border-bottom: 1px solid #990000"><nobr>Цена</nobr></th>
											<th align="left" width="150" style="padding-bottom:5px; border-bottom: 1px solid #990000"><nobr>Стоимость</nobr></th>
										</tr>
									</thead>
									<tbody>
										<?php 
											$content_photos_dir = SITE_URL.URL_IMAGES.$site->catalog->setting("dir_images"); 
                                            foreach($cart['products'] as $key=>$tl_product) { 
                                                    $link_product = SITE_URL.$catalog_full_link."/";
                                                        if(isset($tl_product['category_id']) and $tl_product['category_id'] and isset($tree_categories['all'][ $tl_product['category_id'] ])) 
                                                            $link_product .= $tree_categories['all'][ $tl_product['category_id'] ]["full_link"];
                                                        else 
                                                            $link_product .= $tree_categories['all'][ $tl_product['categ'] ]['full_link'];
                                        ?>
										<tr>
											<td align="center">
												<a href="<?php echo $link_product."/".$tl_product['url'];?>.htm"><img src="<?php if($tl_product['img']!="") echo $content_photos_dir."normal/".$tl_product['img']; else { echo $dir_images;?>noimg_small.jpg<?php } ?>" alt="<?php echo $tl_product['name'];?>" /></a>
											</td>
											<td >
												<h3><a href="<?php echo $link_product."/".$tl_product['url'];?>.htm"><?php echo $tl_product['name'];?></a></h3>
											</td>
											<td style="padding-left:11px;" >
                                            	<font style="font-size:12px;"><?php echo $tl_product['amount'];?> шт.</font>
											</td>
											<td >
												<font style="font-size:16px;"><?php echo F::number_format($tl_product['price']);?>&nbsp;руб.</font>
											</td>
											<td >
												<font style="font-size:18px;" color="#990000"><?php echo F::number_format($tl_product['price']*$tl_product['amount']);?>&nbsp;руб.</font>
											</td>
										</tr>
                            			<?php } ?>
									</tbody>
									<tfoot>
										<tr>
											<td colspan="5" align="right" style="padding-top:15px; padding-bottom:15px; border-top: 1px solid #990000;  border-bottom: 1px solid #990000">
												<p><font style="font-size:16px;">Ваш заказ: <?php echo $cart['total_products'].' '.F::get_right_okonch($cart['total_products'], "товаров", "товар", "товара");?> на сумму <?php echo F::number_format($cart['total_price']);?> руб.</font></p>
											</td>
										</tr>
									</tfoot>
								</table><br><br>
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