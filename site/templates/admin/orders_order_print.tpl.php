<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title><?php echo $site->settings->site_title;?></title>
<style>
body {	
	font-family: Arial, Tahoma, Verdana, sans-serif;	
	line-height:1.4;	
	font-size:14px;	
	min-width:1000px;
	background:#fff;
	color:#333;
}

h1, h2, h3, h4, h5, h6{	
	color:#000;
	font: normal normal 26px/30px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
	padding:0 0 15px;
	margin:0;
}

h1{
	font-size:40px;
}
h2{
	font-size:22px;
	line-height:26px;
}
h3{
	font-size:18px;
	line-height:22px;
}
h4{
	font-size:14px;
	line-height:18px;
}
h5{
	font-size:12px;
	line-height:14px;
}

p {
	line-height:18px;
	padding: 0 0 13px;
	margin:0;
}
table {
    border: 0 none;
    border-collapse: collapse;
    width: 100%;
}
table, caption, tbody, tfoot, thead, tr, th, td {
    background: none repeat scroll 0 0 transparent;
    border: 0 none;
    font-size: 100%;
    margin: 0;
    outline: 0 none;
    padding: 0;
    vertical-align: baseline;
}
.site {
	position:relative;
	width:1000px;
	margin:0 auto;
}
.order-table{
	 
}
.order-table h3{
	padding:0px 0px 33px;
	 margin: -5px 0 0;
}
.order-table th,
.order-table td{
	font: normal normal 12px/14px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
	text-align:left;
	vertical-align:top;
	padding: 22px 10px 4px 0;
}
.order-table th{
	padding-top: 0px;
	padding-bottom: 7px;
	color: #999;
	border-bottom: 1px solid #CCC;
	white-space: nowrap;
}
.order-table .product_line td{
	border-top: 1px solid #e7e7e7;	
}
.order-table .product_line:first-child td{
	border-style: none;
}
.order-table .col-photo{
	width:70px;
	text-align:center;
}
.order-table .col-name{
	padding-right:30px;
	position:relative;
}
.order-table .col-amount{
	width:124px;
}
.order-table .col-price{
	width:161px;
}
.order-table .col-cost{
	width:131px;
	position:relative;
}
.order-table .col-del{
	width:38px;
}
.order-table{}
.order-table .poverka {
	
}
.order-table .poverka td {
	padding-top:5px;
}
.order-table .poverka > td {
	padding-bottom:20px;
}
.order-table .poverka table td.poverka-cost {
	width:121px;
}
.order-table .poverka table td.poverka-name {
	font: normal normal 11px/16px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
}
.order-table .col-photo img{
	/*width:150px;*/
}
.order-table .col-name h4{
	font: normal bold 16px/18px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
	padding: 0 0 7px;
}
.order-table .col-name h4 a:hover{
	text-decoration:underline;
	color:#993333;
}
.order-table .col-name p{
	font-size:12px;
	padding:0 0 10px 0;
}
.order-table .col-name label,
.order-table .poverka-name label {
	font: normal normal 11px/16px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
	cursor:pointer;
}
.order-table .col-name label input,
.order-table .poverka-name label input{
	margin:-1px 6px 0px 0px;	
}
.order-table .col-amount .finput{
	width:20px;
	margin: -4px 0 0;
}
.order-table .col-amount p{
	font-size:12px;
	 padding: 0 0 0 11px;
}
.order-table .col-price p{
	font-size:16px;
	padding:0px 0px 5px;
}
.order-table .col-cost p{
	font: normal normal 18px/19px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
	padding:0px 0px 5px;
}
.order-table .col-cost span,
.order-table .poverka-cost span{
	display:block;
	padding: 0px 0 1px;
	color:#ccc;
	font: normal normal 14px/16px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
	margin: 0;
	zoom:1;
	position:relative;
	z-index:3;
}
.order-table .col-cost span em,
.order-table .poverka-cost span em{
	font-style:normal;	
}
.order-table tr.checked .col-cost span,
.order-table tr.checked .poverka-cost span {
	color:#000;
}
.order-table tfoot td{	
	padding-right: 10px;
    text-align: right;
}
.order-table tfoot td.nums_info{	
	border-top: 1px solid #CCC;
	border-bottom: 1px solid #CCC;
}
.order-table tfoot p{
	font-size:16px;
	padding:0 0 15px;
}
.order-table tfoot  span{
	display: block;
	font-size: 14px;
	padding: 0 0 20px;
}
.order-table tfoot h4{
	font: normal normal 20px/21px 'Trebuchet MS', Tahoma, Arial, Verdana, 'sans-serif';
	color:#333;
	margin: -7px 0 0;
    padding: 0 0 29px;
}
.order-table tfoot h4 strong{
}
.clear {
	width:100%;
	position:relative;
	clear:both;
}
.header, .detailes {
	position:relative;
	width:100%;
	margin-bottom:30px;
}
.header .left_info {
	float:left;
	width:400px;
}
.header .right_info {
	float:right;
	width:550px;
	text-align:right;
}
.header p {
	font-size:20px;
}
.header h2 {
	font-size:24px;
}
.detailes .left_info {
	float:left;
	width:480px;
}
.detailes .right_info {
	float:right;
	width:480px;
}

</style>
</head>

<body onload="window.print();">
	<div class="site">
    	<div class="header">
        	<div class="left_info">
            	<h1>Заказ <?php if(isset($order['id'])) echo "№".$order['id'];?></h1>
                <p><?php echo date('H:i d.m.Y', $order['date_add']);?></p>
            </div>
            <div class="right_info">
            	<h2><?php echo $site->settings->site_title;?></h2>
                <p><?php echo SITE_URL;?></p>
            </div>
            <div class="clear"></div>
        </div>
            	<h2>Детали заказа</h2>
        <div class="detailes">
        	<div class="left_info">
                            <p><strong>Контактное лицо:</strong> <?php if(isset($order) and isset($order['name'])) echo $order['name'];?></p>
                            <p><strong>e-mail:</strong> <?php if(isset($order) and isset($order['email'])) echo $order['email'];?></p>
                            <p><strong>Телефон с кодом города:</strong> <?php if(isset($order) and isset($order['phone'])) echo $order['phone'];?></p>
                            <?php if(isset($order) and isset($order['contacts']) and $order['contacts']!='') { ?>
                            <p><strong>Другие контакты:</strong><br><?php echo $order['contacts'];?></p>
                            <?php } ?>
            </div>
            <div class="right_info">
            	<p><strong>Способ доставки:</strong> <?php if(isset($order) and isset($order['delivery_id']) and isset($deliveries[$order['delivery_id']])) echo $deliveries[$order['delivery_id']]['name'];?></p>
                <p><strong>Тип оплаты:</strong> <?php if(isset($order) and isset($order['payment_type_id']) and isset($payment_types[$order['payment_type_id']])) echo $payment_types[$order['payment_type_id']]['name'];?></p>            
							<p><strong>Адрес доставки:</strong> <br><?php if(isset($order) and isset($order['address'])) echo $order['address'];?></p>
                            <?php if(isset($order) and isset($order['comment']) and $order['comment']!='') { ?>
                            <p><strong>Примечания к заказу:</strong> <br><?php echo $order['comment'];?></p>
                            <?php } ?>
            </div>
            <div class="clear"></div>
        </div>
							
                                <div class="order-table">
								<h2>Заказанные товары</h2>
						<!-- order table bl -->									
								<table border="0" cellspacing="0" cellpadding="0" width="100%">
									<thead>
										<tr>
											<th class="col-photo">Фото</th>
											<th class="col-name">Наименование</th>
											<th class="col-amount">Кол-во, шт.</th>
											<th class="col-price">Цена, с НДС</th>
											<th class="col-cost">Стоимость, с НДС</th>
										</tr>
									</thead>
									<tbody>
										<?php 
											$content_photos_dir = SITE_URL.URL_IMAGES.$site->catalog->setting("dir_images"); 
                                            foreach($order_products['products'] as $key=>$tl_product) {
                                        ?>
										<tr class="product_line">
											<td  class="col-photo">
												<?php if($tl_product['img']!="") { ?><img src="<?php echo $content_photos_dir."normal/".$tl_product['img'];?>" alt="<?php echo $tl_product['name'];?>" /><?php } ?>
											</td>
											<td  class="col-name">
												<h4><?php echo $tl_product['name'];?></h4>
											</td>
											<td  class="col-amount">
                                            	<p><?php echo $tl_product['amount'];?> шт.</p>
											</td>
											<td class="col-price">
												<p><?php echo F::number_format($tl_product['price']);?>&nbsp;руб.</p>
											</td>
											<td class="col-cost">
												<p><?php echo F::number_format($tl_product['price_order']*$tl_product['amount']);?>&nbsp;руб.</p>
											</td>
										</tr>
                            			<?php } ?>
									</tbody>
									<tfoot>
										<tr>
											<td colspan="5" class="nums_info" >
												<p>Ваш заказ: <?php echo $order['amount'].' '.F::get_right_okonch($order['amount'], "товаров", "товар", "товара");?> на сумму <?php echo F::number_format($order['total_price']);?> руб.</p>
											
											</td>
										</tr>
										<tr>
											<td colspan="5" >
												<h4>Итого: <strong><?php echo F::number_format($order['total_price']);?> руб.</strong> с НДС</h4>
											</td>
										</tr>
									</tfoot>
								</table>
                                </div>
	</div>
</body>
</html>