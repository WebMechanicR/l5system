<?php 
    $catalog_full_link = $site->pages->get_full_link_module("catalog");
?>

<!-- main content wrapper -->
<div class="content-wrap">
    <!-- main content -->
    <div class="content">
        <?php echo $site->tpl->display('breadcrumbs'); ?>

        <!-- checkout form -->
        <div class="checkout-form">
            <?php if(isset($success) and $success) { ?>
                     <h1>Ваш заказ <?php if(isset($order_id)) echo "№".$order_id;?> принят к обработке!</h1>
                     <p>Мы благодарим вас за заказ и желаем, чтобы наши товары приносили вам как можно больше удовольствия и пользы. <br />
                        На указанный адрес электронной почты, вы скоро получите письмо с подтверждением заказа. Наш менеджер свяжется с вами для обсуждения деталей заказа до конца рабочего дня. Надеемся, что вам у нас понравилось, и с нетерпением ждем вашего следующего визита.</p>
           <?php }
           elseif(!count($cart['products'])){ ?>
                <p>Добавьте что-нибудь к вашему заказу</p>
           <?php } ?>
         <?php if(count($cart['products']) and !$success): ?>                
            <form action="<?php echo SITE_URL.$catalog_full_link;?>/order.htm" method="post">
                <fieldset>
                    <h1>Оформление заказа</h1>
                    <div class="form-checkout">
                    <div class="form-line">
                        <div class="label-holder">
                            <label for="name-field">Представьтесь, пожалуйста:</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['name'])) echo "failed"; ?>">
                            <input type="text"  name = "name" value = "<?php if(isset($order) and isset($order['name'])) echo $order['name'];?>" id="name-field">
                        </div>
                        <?php if(isset($errors) and isset($errors['name'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="email-field">Ваш e-mail:</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['email']) and $errors['email']=="no_email") echo "failed"; ?>">
                            <input type="text" placeholder="" id="email-field" name = "email" value = "<?php if(isset($order) and isset($order['email'])) echo $order['email'];?>">
                        </div>
                        <?php if(isset($errors) and isset($errors['email']) and $errors['email']=="no_email") { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
 			<?php if(isset($errors) and isset($errors['email']) and $errors['email']=="err_email") { ?><p class="error">неверный email</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="phone-field">Телефон для связи:</label>
                        </div>
                        <div class="input-holder <?php if(isset($errors) and isset($errors['phone'])) echo "failed"; ?>">
                            <input type="text" placeholder="" id="phone-field" name = "phone" value = "<?php if(isset($order) and isset($order['phone'])) echo $order['phone'];?>">
                        </div>
                        <?php if(isset($errors) and isset($errors['phone'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="address-field">Адрес доставки:</label>
                        </div>
                        <div class="input-holder input-area <?php if(isset($errors) and isset($errors['address'])) echo "failed"; ?>">
                            <textarea placeholder="" id="address-field" name = "address"><?php if(isset($order) and isset($order['address'])) echo F::br2nl($order['address']);?></textarea>
                        </div>
                        <?php if(isset($errors) and isset($errors['address'])) { ?><p class="error">это поле обязательно для заполнения</p><?php } ?>	
                    </div>

                    <div class="form-line radio-row">
                        <div class="label-holder">
                            <span class="label">Способ доставки:</span>
                        </div>
                        <ul class="radio-list">
                            <?php
                             if($deliveries)
                                     foreach ($deliveries as $delivery){
                                    ?>
                                        <li>
                                            <label class="radio">
                                                <input type="radio" name="delivery_id" <?php if (isset($order['delivery_id']) and $order['delivery_id'] == $delivery['id']) echo " checked"; ?> value="<?php echo $delivery['id']; ?>" >
                                                <?php echo $delivery['name']; ?>
                                            </label>
                                        </li>
                        <?php } ?>
                        </ul>
			<?php if(isset($errors) and isset($errors['delivery'])) { ?><p class="error">выберите способ доставки</p><?php } ?>	
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <span class="label">Тип оплаты:</span>
                        </div>
                        <ul class="radio-list">
                            <?php
                             if($payment_types)
                                  foreach($payment_types as $payment_type) { ?>
                                  <li>
                                    <label class="radio">
                                        <input type="radio" name="payment_type_id" value="<?php echo $payment_type['id']; ?>"  <?php if( isset($order['payment_type_id']) and $order['payment_type_id']==$payment_type['id']) echo " checked"; ?>>
                                        <?php echo $payment_type['name'];?>
                                    </label>
                                 </li>
                            <?php } ?> 
                        </ul>							
                        <?php if(isset($errors) and isset($errors['payment_type'])) { ?><p class="error">выберите способ оплаты</p><?php } ?>
                    </div>

                    <div class="form-line">
                        <div class="label-holder">
                            <label for="notice-field">Примечания к заказу:</label>
                        </div>
                        <div class="input-holder input-area">
                            <textarea placeholder="" id="notice-field" name = "comment"><?php if(isset($order) and isset($order['comment'])) echo F::br2nl($order['comment']);?></textarea>
                        </div>
                    </div>

                    <div class="form-buttons">
                        <div class="btn btn-default">
                            <span>Оформить заказ</span>
                            <input type="submit" value="">
                        </div>
                    </div>
                    </div>
                </fieldset>
            </form>
            <?php endif; ?>
        </div>
        <!-- checkout form end -->
    </div>
    <!-- main content end -->
</div>
<!-- main content wrapper end -->

<?php $site->tpl->display('cart', array('cart' => $cart, 'catalog_full_link' => $catalog_full_link)); ?>    