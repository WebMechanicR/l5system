                
				<h1><img class="tools-icon" src="<?php echo $dir_images;?>icon.png" alt="icon"/> Инструменты</h1>

             
				
				<div class="tabs">
					<ul class="bookmarks">
						<li class="active"><a href="#" data-name="main">Кеш</a></li>
					</ul>

					<div class="tab-content">
                         <ul class="form-lines wide">
								<li>
                                <form action="<?php echo DIR_ADMIN; ?>?module=tools" method="post" enctype="multipart/form-data">
                                    <input type="hidden" name="tool" value="cache_clear_tags" >
									<label for="site_title">Очистить кеш по тегам</label>
									<div class="input textarea">
										<textarea cols="30" rows="10" name="tags"></textarea>
									</div>
                                <p class="small">
                                	пишутся через запятую.<br>
                                    Теги делятся на уровни. <br>
									Самый верхний по имени модуля, очищающий кеш всего модуля (catalog, news и пр.).<br>
                                    Все модули, которые выдают информацию списком имеют теги list_* (list_news, list_products)<br>
                                    Наиболее точные теги по ID элемента: newsid_10, productid_10 - очищают все записи в кеше с новостью ID=10 или товары с ID=10<br><br>
                                    В зависимости от модуля могут быть дополнительные теги:<br>
                                    products_categoryid_10 - очищает все товарные списки категории id 10<br>
                                    search_products - очищает поисковый кеш товаров<br>
 
                                </p>
                                <div class="bt-set clip">
                                        <span class="btn standart-size blue hide-icon">
                                            <button class="ajax_submit" data-success-name="Кеш удален">
                                                <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <i>Удалить кеш</i></span>
                                            </button>
                                        </span>
                                </div>
                                </form>
                                </li>
								<li>
                       <form action="<?php echo DIR_ADMIN; ?>?module=tools" method="post" enctype="multipart/form-data">
                        	<input type="hidden" name="tool" value="cache_clear_all" >
                        <div class="bt-set clip">
                            <div class="left">
                                <span class="btn standart-size blue hide-icon">
                                    <button class="ajax_submit" data-success-name="Кеш удален">
                                        <span><img class="bicon check-w" src="<?php echo $dir_images;?>icon.png" alt="icon"/> <i>Очистить весь кеш</i></span>
                                    </button>
                                </span>
                           </div>
                        </div>
                        <p class="small">используйте только в крайнем случае</p>
                        </form>
                        </li>
                        </ul>
						
					</div>
									
				</div>