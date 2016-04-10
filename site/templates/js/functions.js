/* inputFocus */
var parentArray = ['.input-holder'];
function inputFocus(parent){
	var parentSize = parent.length;
	var n = 0;
	for ( n; n < parentSize; n++ ) {
		var obj = parent[n];
		var input = $(obj).find(':text, textarea');
		if ( $(input).length ) {
			$(obj).each(function(){
				$(this).on('click', function(e){
					var thisObj = $(this);
					input = thisObj.find(':text, textarea, :password');
					$(this).addClass('focus');
					$(input).trigger('focus');
					$(input).on('blur', function(){
						thisObj.removeClass('focus');
					});
					e.preventDefault();
				});
			});
		}
	}
}
/* inputFocus end */

/* all sliders */
function allSlider(){
	var autoSlider = ($('.main-slider li').length>1);
	
	$('.main-slider').bxSlider({
		mode: 'fade',
		pager: false,
		auto: autoSlider,
		speed: 1000,
		pause: slide_delay
	});
	
	
	$('.products-slider').bxSlider({
		pager: false,
		slideWidth: 140,
		minSlides: 4,
		maxSlides: 4,
		slideMargin: 21
	});
	
}
/* all sliders end */

/*fancybox gallery*/
 function fancyboxGallery(){	
	var fbGallery = $(".fb-gallery");	
	if (fbGallery.length) {			
		fbGallery.fancybox();	
	}	
};

/*gallery*/
 function fnGallery(){	
	var gallery = $('.large-img .bxslider');
	
	if(gallery.length){
		var gall = gallery.bxSlider({
			mode: 'fade',
			infiniteLoop: false,
			pagerCustom: '.preview-carousel',
			hideControlOnEnd: true,
			useCSS:false,
			speed: 1000,
			adaptiveHeight:true,
			adaptiveHeightSpeed:700,
			onSliderLoad:function(){
				if ($('.large-img .bxslider li').length <= 3 ) {
					$('.large-img .bx-prev').addClass('todisabled');
					$('.large-img .bx-next').addClass('todisabled');
				}
			}
		});
		
		var caruses = $('.preview-carousel').bxSlider({
			pager: false,
			minSlides: 3,
			maxSlides: 3,
			slideWidth: 75,
			slideMargin: 14,
			moveSlides: 1,
			hideControlOnEnd: true,
			infiniteLoop: false,
			speed: 700,
			caption: false,
			controls:false,
			useCSS: false
		});
		
		$('.large-img .bx-prev').on('click', function(){
			caruses.goToPrevSlide();
		});
		$('.large-img .bx-next').on('click', function(){
			caruses.goToNextSlide();
		});
		
	}
};
/*gallery*/

/* loadList */
function loadList(){
	$('.jq-show-list').each(function(){
		var list = $(this);
		var showItem = list.data('show-item');
		var slideItem = list.data('slide-item');
		var showItemIndex = showItem - 1;
		list
			.find('li:gt('+showItemIndex+')')
				.hide(0)
					.addClass('hidden');
		list
			.parents('.jq-show-container')
				.find('.jq-show-more')
					.on('click', function(e){
						var toShow = list.find('li.hidden:lt('+slideItem+')');
						toShow.slideDown().removeClass('hidden');
						if ( list.find('li.hidden').length ) {} else {
							$(this).hide(0);
						}
						e.preventDefault();
		});
	});
}

/* placeholder */
function placeholderEdit() {
	if ($.browser.webkit || $.browser.mozilla) {
		$('input,textarea').on('focus', function(){
			var placeholder = $(this).attr('placeholder');
			$(this).removeAttr('placeholder');			
			$(this).on('blur', function(){
				$(this).attr('placeholder',placeholder);
			});
		});
	}
}
/* placeholder end */

/* footer at bottom */
function footerBottom(){
	var footerBox = $('.footer');
	var footerHeight = $('.footer').height();
	var spacerBox = $('.spacer');
	footerBox.css({
		'height': footerHeight,
		'margin-top': -(footerHeight)
	});
	spacerBox.css({
		'height': footerHeight
	});
}
/* footer at bottom end */

/* has drop menu */
function hasDropMenu(){
	var item = $('.nav-list li');
	item.find('ul').parents('li').addClass('has-drop');
}
/* has drop menu end */

/* equalHeight */
function equalHeight(){
	$('.products-list:not(.products-slider) .product-holder>a:first-child').equalHeight({
		amount: 4
	});
	$('.products-slider').each(function(){
		var amount = $('li', this).length;
		$('.product-holder>a:first-child', this).equalHeight({
			amount: amount
		});
	});
}
/* equalHeight end */

function toCartButton() {
	$(document).on("click", "a.add-to-cart", function(e) {
		var elem = $(this);
		var url = $(this).attr('data-url');
		var id = $(this).attr('data-id');
		$.post(url, {product_id: id}, function(data) {
				$('.top-panel .cart').html(data);
		});

			var image;
			
			if($(this).data('transfer')) image = $($(this).data('transfer')).eq(0);
			
			if(image) {
				var o1 = $(image).offset();
				var o2 = $('.top-panel .cart').offset();
				var dx = o1.left - o2.left;
				var dy = o1.top - o2.top;
				var distance = Math.sqrt(dx * dx + dy * dy);
				
				$(image).effect("transfer", { to: $('.top-panel .cart'), className: "transfer_class" }, distance/1.5);	
				$('.transfer_class').html($(image).clone());
				$('.transfer_class').find('img').css('height', '100%');
			}
			elem.text('Добавлено в корзину');
		e.preventDefault();
	});
}

/*order table*/
function orderTableAction(){
	var table = $(".cart-list");	
	var order = ".form-checkout";
	if (table.length) {		
		var delay = 400;
		var hint = 'Добавьте что-нибудь к вашему заказу';

		$(table).on('click', '.icon-close' , function(e){
			var url = $(this).data('url');
			$.get(url, function(data) {
				$('.top-panel .cart').html(data);	
			});			
			
			var self = $(this);
			var item = self.closest('.product');

			item.fadeOut(delay);
			
			setTimeout(
				function(){
					item.remove();
					calcl_cart();
				}, delay + 5);		
				
			var curPar =  $(".cart-list .product");			
			if(curPar.length > 1 ){			
			}else{
				$(order).children().fadeOut(delay);
				$(order).append('<p class="order-hint">'+hint+'</p>');
				$(table).addClass('cart-empty');
			}
			e.preventDefault();
		});
		
		
		table.find('input[name=amount]').blur(function() {
			if($(this).val()>0) {
				$(this).closest('form').submit();
			}
		});

		table.find('.link-minus').click(function() {
			var amount = $(this).closest('form').find('input[name=amount]');
			if(amount.val()>1) {
				amount.val( parseInt(amount.val())-1 );
				$(this).closest('form').submit();
			}
			return false;
		});

		table.find('.link-plus').click(function() {
			var amount = $(this).closest('form').find('input[name=amount]');
				amount.val( parseInt(amount.val())+1 );
				$(this).closest('form').submit();
			return false;
		});
		
		table.find('form').submit(function() {
			var url = $(this).attr('action');
			var query = $(this).serialize();
			$.post(url, query, function(data) {
				$('.top-panel .cart').html(data);
			});
			calcl_cart();
			return false;	
		});
		
	}; 
};

function calcl_cart() {
	var total_price = 0,
	total_products = 0;
	var obj = $(".cart-list .product");
	
	$(obj).each(function() {
		price = parseFloat($(this).find('.price').data('price'));
		amount  = parseInt( $(this).find('input[name=amount]').val() );	
		price = price*amount;				
		total_products += amount;
		total_price += price;
	});
	
	$('.total-value-holder').html( myNumberFormat(total_price) + ' руб.' );
	$('.total-amount .total-amount-value').html( total_products + ' ' + get_right_okonch(total_products, 'товаров', 'товар', 'товара'));
}

function get_right_okonch(numeric, many, one, two) {
				numeric = parseInt(numeric);
				if (numeric % 100 == 1 || (numeric % 100 > 20) && ( numeric % 10 == 1 )) return one;
				if (numeric % 100 == 2 || (numeric % 100 > 20) && ( numeric % 10 == 2 )) return two;
				if (numeric % 100 == 3 || (numeric % 100 > 20) && ( numeric % 10 == 3 )) return two;
				if (numeric % 100 == 4 || (numeric % 100 > 20) && ( numeric % 10 == 4 )) return two;
				return many;
}

function round(a,b) {
	 b=b || 0;
	 return Math.round(a*Math.pow(10,b))/Math.pow(10,b);
}

function myNumberFormat(x) {
	x = round(x, 2);
	x = x.toString();
	x= x.replace(/.+?(?=\D|$)/, function(f) {
		return f.replace(/(\d)(?=(?:\d\d\d)+$)/g, "$1 ");
	});
	return x;
}


function initPopup(){
	$(document).on("submit", "#box_popup_inner form", function(e) {
					e.preventDefault();
					$('#box_popup_inner').html('<div id="box_loading"></div>');
					var url = $(this).attr('action');
					var query = $(this).serialize();	
					$.post(url, query, function(data) {
							$('#box_popup_inner').html(data);
					}); 
					return false;
		});
		//ищем ссылки на popup окна
		$(document).on('click', 'a.popup', function (e) {
			e.preventDefault();
			var open_url = $(this).attr('href');
			var  w = h = 0;
			
			if($(this).data('width')) w = parseInt($(this).data('width'));
			if($(this).data('height')) h = parseInt($(this).data('height'));			

			newPopupWindow(open_url, w, h);
			
			return false;
		});
}

function newPopupWindow(urlHtml, w, h, type) {
			if (type === undefined) {
				type = 1;
			}
			var my_page_size = my_getPageSize();
			var my_page_scroll = my_getPageScroll();
			var  popup_size = [0, 0];
			
			if(w>0) popup_size[0] = parseInt(w);
			if(h>0) popup_size[1] = parseInt(h);
			if(popup_size[0]<1) popup_size[0] = 500;
			if(popup_size[1]<1) popup_size[1] = 400;
			
			$('embed, object, select').css( {
				'visibility' :'hidden'
			});
			
			$('body')
					.append(
							'<div class="black_display" id="black_display"></div><div class="box_popup" id="box_popup"><div id="box_popup_inner" class="popup-inner"><div id="box_loading"></div></div><a id="CloseLinkPopup" class="popup-close" href="#"><i class="icon-close-window"></i></a></div>');
			$('#black_display').css( {
				display :'block',
				opacity: 0.5,
				width: my_page_size[0],
				height: my_page_size[1]
			}).fadeIn(500);
			
			$('#box_popup_inner').css( {
				opacity: 0
			});
			$('#CloseLinkPopup').css( {
				display: 'none'
			});
			
			if(type==1) {
						$('#box_popup_inner').load(urlHtml, function() {
							$('#CloseLinkPopup').css( {
								display: 'block'
							});
							if($.support.opacity) {
								$('#box_popup_inner').animate({opacity: 1 }, 500);
								$('#box_popup_inner').animate({opacity: 1 }, 500);
							}
							else {
								$('#box_popup_inner').css({opacity: 1});
								$('#box_popup_inner').css({opacity: 1}).fadeIn();
							}
							
							$('.close_link').one("click", function() {
								$('#box_popup').remove();
								$('#black_display').fadeOut( function() {
									$('#black_display').remove();
								});
								$('embed, object, select').css( {
									'visibility' :'visible'
								});
								return false;
							});
							
					});
			}
			else {
				$('#box_popup_inner').html(urlHtml);
				$('#CloseLinkPopup').css( {display: 'block'});
				if($.support.opacity) {
					$('#box_popup_inner').animate({opacity: 1 }, 500);
					$('#box_popup_inner').animate({opacity: 1 }, 500);
				}
				else {
					$('#box_popup_inner').css({opacity: 1});
					$('#box_popup_inner').css({opacity: 1}).fadeIn();
				}
			}
			var top = (my_page_scroll[1]+my_page_size[3]/2-popup_size[1]/2);
			if(top<0)  top = 20;
			var left =  (my_page_scroll[0]+my_page_size[2]/2-popup_size[0]/2)
			if(left<0)  left = 20;
			$('#box_popup').css( {
				display :'block',
				opacity :0,
				width : popup_size[0],
				minHeight: popup_size[1],
				top: top,
				left: left
			})
			if($.support.opacity) $('#box_popup').animate({opacity: 1}, 500);
			else  $('#box_popup').css({opacity: 1});
			
			
			$('#black_display, #CloseLinkPopup, .button.closebox, .close_link').one("click", function() {
				$('#box_popup').remove();
				$('#black_display').fadeOut( function() {
					$('#black_display').remove();
				});
				$('embed, object, select').css( {
					'visibility' :'visible'
				});
				return false;
			});
}

		function my_getPageSize() {
			var windowWidth, windowHeight,pageWidth, pageHeight;
			windowWidth = $(window).width();
			windowHeight = $(window).height();
			pageWidth = $(document).width();
			pageHeight = $(document).height();
			arrayPageSize = new Array(pageWidth, pageHeight, windowWidth,	windowHeight);
			return arrayPageSize;
		}
 
		function my_getPageScroll() {
			var xScroll, yScroll;
			if (self.pageYOffset) {
				yScroll = self.pageYOffset;
				xScroll = self.pageXOffset;
			} else if (document.documentElement
					&& document.documentElement.scrollTop) {
				yScroll = document.documentElement.scrollTop;
				xScroll = document.documentElement.scrollLeft;
			} else if (document.body) {
				yScroll = document.body.scrollTop;
				xScroll = document.body.scrollLeft;
			}
			arrayPageScroll = new Array(xScroll, yScroll);
			return arrayPageScroll;
		}

/** ready/load/resize document **/

$(document).ready(function(){
	inputFocus($('.input-holder'));
	placeholderEdit();
	hasDropMenu();
	toCartButton();
	fancyboxGallery();
	fnGallery();
	orderTableAction();
	initPopup();
});
$(window).load(function(){
	footerBottom();
	equalHeight();
	allSlider();
});