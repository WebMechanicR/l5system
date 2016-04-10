/**
 * Plugin defaults area
 */
// add reverse method to jQuery
(function(){
	if ( !$ ) return;
	$.fn.reverse = [].reverse;
})();

function trim( str, charlist ) {
    charlist = !charlist ? ' \\s\xA0' : charlist.replace(/([\[\]\(\)\.\?\/\*\{\}\+\$\^\:])/g, '\$1');
    var re = new RegExp('^[' + charlist + ']+|[' + charlist + ']+$', 'g');
    return str.replace(re, '');
}


var History = window.History;

// define multiselect defaults
(function(){
	if ( !$ ) return;
	if ( !$.ech ) return;
	if ( !$.ech.multiselect ) return;
	
	var multi = $.ech.multiselect.prototype.options;
	
	multi.header = false;
	multi.minWidth = 'auto';
	multi.height = 'auto';
	multi.multiple = false;
	multi.selectedList = 1;
	multi.noneSelectedText = 'Не выбрано';
	multi.checkAllText = 'Выбрать все';
	multi.uncheckAllText = 'Отменить все';
	multi.selectedText = '# выбрано';
	multi.position = {
		my: 'left-1 top',
		at: 'left bottom'
	}
	
	// по умолчанию к каждому селекту стыкуем
	// следующие примочки
	multi.create = function(){
		
		$(this).multiselect('widget').width( function(index, width)
			{
				return width + 2
			}
		);
		
		// прибирание класса ui-state-hover
		// при открытии выпадающего списка
		$(this).on('multiselectopen', function( event, ui )
			{
				$(this)
					.multiselect('widget')
					.find('.ui-state-hover')
					.removeClass('ui-state-hover');
			}
		);
		
		// стилизация кнопки
		$(this)
			.multiselect('getButton')
			.children().eq(0)
			.removeClass('ui-icon ui-icon-triangle-2-n-s')
			.addClass('dicon arrdown');
	}
})();

// define russian calendar
(function(){
	if ( !$ ) return;
	if ( !$.datepicker ) return;
	
	$.datepicker.regional['ru'] = {
		closeText: 'Закрыть',
		prevText: '&#x3c;Пред',
		nextText: 'След&#x3e;',
		currentText: 'Сегодня',
		monthNames: ['Январь','Февраль','Март','Апрель','Май','Июнь',
		'Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'],
		monthNamesShort: ['Янв','Фев','Мар','Апр','Май','Июн',
		'Июл','Авг','Сен','Окт','Ноя','Дек'],
		dayNames: ['воскресенье','понедельник','вторник','среда','четверг','пятница','суббота'],
		dayNamesShort: ['вск','пнд','втр','срд','чтв','птн','сбт'],
		dayNamesMin: ['Вос','Пон','Вто','Сре','Чет','Пят','Суб'],
		weekHeader: 'нед',
		dateFormat: 'dd.mm.yyyy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	$.datepicker.setDefaults($.datepicker.regional['ru']);
})();


/**
 * Creating unique namespace for the project
 */
var sD;

if ( sD ) throw new Error( "Name 'sD' is already exist" );
else sD = {};


/**
 * Project functions
 */
sD.enableHints = function(){
	var hint_color = '';//'#aaa';
	$('form').each(function(){
		var elems = $('input[placeholder], textarea[placeholder]',this);
		elems.each(function(){
			if($(this).val()=='') {
				// remember hint value
				var hint = $(this).attr('placeholder');
				
				// remove attribute to prevent browser defaults
				// and make hint text gray
				$(this).removeAttr('placeholder').attr('hint', hint).css('color', hint_color);
				
				// show hint text
				$(this).val(hint);
				
				// link hints showing/hiding to the events
				$(this).on({
					blur: function(){
						if ( $(this).val() == '' ) $(this).val(hint).css('color', hint_color);
					},
					focus: function(){
						$(this).removeAttr('style');
						if ( $(this).val() == hint ) $(this).val('');
					}
				});
			}
		});
		
		// prevent submition of the default values
		$(this).on('submit',function(){
			elems.each(function(){
				if ( $(this).val() == $(this).attr('hint') ) $(this).val('');
			});
		});
	});
}

sD.activateCombo = function(){
	var elems = $('.combo');
	if ( !elems.length ) return;
	
	elems.each(function()
		{
			var self = $(this), id;
			
			function clickListner()
			{
				if ( !id ){
					id = true;
					return
				}
				self.removeClass('active');
				$(document).off('click', clickListner);
			}
			
			self.children().eq(1).on('click', function(event)
				{
					event.preventDefault();
					id = false;
					self.toggleClass('active');
					$(document).on('click', clickListner);
				}
			);
			
			self.find('.btn button').click(function(event) {
				event.preventDefault();
				self.find('input[name="group_actions"]').val(1);
				self.closest('form').submit();
				self.find('input[name="group_actions"]').val(0);
			});
			
			self.find('a').click(function(event) {
				event.preventDefault();
				self.find('input[name="do_active"]').val( $(this).data('active') );
				var added_field = $(this).data('added-field');
				$('.added_field_combo').hide();
				if(added_field) {
					self.find('.btn button').text($(this).text());
					$('#'+added_field).show();
				}
				else {
					self.find('input[name="group_actions"]').val(1);
					self.closest('form').submit();
					self.find('input[name="group_actions"]').val(0);
				}
			});
			
			$('.added_field_combo .btn button').click(function(event) {
				event.preventDefault();
				self.find('input[name="group_actions"]').val(1);
				self.closest('form').submit();
				self.find('input[name="group_actions"]').val(0);
			});
		}
	);
	
}

sD.enableTabs = function(){
	var elems = $('.tabs');
	if ( !elems.length ) return;
	
	elems.each(function()
		{
			var 
				contentZones = $('.tab-content', this).hide(),
				bookmarks = $('.bookmarks', this).children(),
				active = bookmarks.filter('.active').index();
			
			// show first tab in case class 'active' is omitted
			if ( active == -1 ) active = 0;
			
			contentZones.eq( active ).show();
			bookmarks.eq( active ).addClass('active');
			
			bookmarks.find('a').on('click', function()
				{
					bookmarks.eq( active ).removeClass('active');
					contentZones.eq( active ).hide();
					
					active = $(this).parent().index();
					
					bookmarks.eq( active ).addClass('active');
					contentZones.eq( active ).show();
					$(this).closest("form").find('input[name="tab_active"]').val( $(this).data("name") );
					return false;
				}
			);
		}
	);
}

sD.activateCalendars = function(){
	$.extend(
		$.datepicker,
		{_checkOffset:function(inst,offset,isFixed)
			{
				offset.left -= 11;
				return offset
			}
		}
	);
	$('.date input').datepicker({
		showOn: 'button',
		buttonImage: dir_images+'icon.png',
		buttonImageOnly: true,
		dateFormat: 'dd.mm.yy',
		showWeek: true,
		beforeShow: function()
		{
			$(this).siblings().addClass('active');
		},
		onClose: function()
		{
			$(this).siblings().removeClass('active');
		}
	});
}

sD.enableTableDrag = function(){
	var elems = $('.product-table.sortable table');
	if (elems.length) {
		elems.each(function()
			{
				$(this).sortable({
					items: 'tbody tr',
					handle: '.lines-s',
					cursor: 'move',
					axis: 'y',
					helper: function(event, elem)
					{
						var twin = $(elem).clone();
						
						twin.children().each(function(i)
							{
								$(this).width( $(elem).children().eq(i).width() );
							}
						);
						
						return twin;
					},
					update: function( event, ui ) {
						upd_onfly = ui.item.closest('tr.update_onfly, tr.update_onfly_sort');
						if(upd_onfly.length) {
							var form = $(upd_onfly).closest('form');
							if(form.length) {
								var url;
								if($(form).attr('action')!='') {
									url = $(form).attr('action');
									var myForm = $(form).serialize();
									$.post(url, myForm);
								}
							}
						}
					}
				});
			}
		);
	}
	
	$(".sortable_pages").nestedSortable({
					items: 'li',
					handle: '.lines-s',
					cursor: 'move',
		            toleranceElement: '> div',
					forcePlaceholderSize: true,
					helper:	'clone',opacity: .6,
					placeholder: 'mjs-nestedSortable-placeholder',
					revert: 250,
					tabSize: 25,
					isTree: true,
					expandOnHover: 700,
					listType: "ul",
					startCollapsed: true
	});
	
	$('.sortable_pages .mjs-nestedSortable-branch > .sortable_line .picon').on('click', function() {
			$(this).closest('li').toggleClass('mjs-nestedSortable-collapsed').toggleClass('mjs-nestedSortable-expanded');
	});
	
	$('.collapse_pages_expand').on('click', function() {
			$('.sortable_pages li.mjs-nestedSortable-branch').removeClass('mjs-nestedSortable-collapsed').addClass('mjs-nestedSortable-expanded');
			return false;
	});

	$('.collapse_pages_collapse').on('click', function() {
			$('.sortable_pages li.mjs-nestedSortable-branch').addClass('mjs-nestedSortable-collapsed').removeClass('mjs-nestedSortable-expanded');
			return false;
	});
}

sD.enableTableSort = function(){
	/*var elems = $('.product-table.sortable table');
	if (!elems.length) return;
	
	elems.each(function()
		{
			$(this).tablesorter({
				headers:{
					0: {
						sorter:false
					},
					2: {
						sorter:false
					},
					3: {
						sorter:false
					},
					5: {
						sorter:false
					}
				}
			});
		}
	);*/
}

sD.activateCarousel = function(){
	var elems = $('.doc-carousel');
	if (!elems.length) return;
	
	elems.jcarousel();
}

sD.activateTopPanel = function(){
	var panel = $('.top-panel');
	if (!panel.length) return;
	
	var carousel = panel.children().eq(0);
	carousel.hide();
	
	panel.find('.right').on('click', function()
		{
			carousel.slideToggle('slow');
			panel.toggleClass('open');
			return false;
		}
	);
}

sD.activateConfirm = function(){
	$(document).on('click', '.delete-confirm', function()
		{
			var message = $('<div id="confirm"><p class="del-message"></p></div>');
			message.find(".del-message").html($(this).data("text"));
			var delUrl = ( $(this).attr("href") && $(this).attr("href").length ?  $(this).attr("href") : $(this).data("url") );
			var module = $(this).data("module");
			var self_button = $(this);
			
			message.dialog({
				title: null,
				resizable: false,
				draggable: false,
				modal: true,
				minHeight: 50,
				buttons: {
					'Да': function()
					{
						if($(self_button).hasClass("delete-image")) {
							$(self_button).closest("tr").fadeOut(200, function() { $(self_button).remove(); });
							$.get(delUrl);
						}
						else if($(self_button).hasClass("delete-one-image")) {
							$(self_button).closest(".one_image").fadeOut(200, function() { $(this).remove(); });
							$.get(delUrl);
						}
						else {
							sD.loadPage(delUrl, module);
						}
						$( this ).dialog( 'close' );
					},
					'Нет': function()
					{
						$( this ).dialog( 'close' );
					}
				},
				create: function()
				{
					var elem = $(this).dialog('widget');
					elem
						.removeClass('ui-corner-all')
						.children().eq(0)
						.hide();
					elem
						.find('.ui-dialog-buttonpane')
						.removeClass()
						.addClass('btn-set txtctr')
						.children().eq(0)
						.removeClass()
						.find('button')
						.removeClass()
						.wrap('<span class="btn hide-icon" />');
					//console.log(elem);
				}
			});
			message.dialog('open');
			$(window).on('resize', function()
				{
					message.dialog('option', 'position', 'center');
				}
			);
			return false;
		}
	);

}

sD.initInputBlur = function(){
	$(document).on('click', '.input.text, .input.date, .search', function() {
		$(':text, :password', this).focus();
	});
}

sD.activateCheckAll = function(){
	var 
		elems = $('.product-table :checkbox, .pages-table :checkbox');
		nottails = elems.filter(function() {return !$(this).closest('th').length;});
		
	elems.on('change', function()
		{
			if($(this).closest('th').length) {
				if ( this.checked ) elems.prop('checked', true);
				else elems.prop('checked', false);
			}
			else {
				if ( nottails.filter(':checked').length == nottails.length ) $(this).closest('table').find('th :checkbox').prop('checked', true);
				else $(this).closest('table').find('th :checkbox').prop('checked', false)
			}
		}
	);
}

sD.styleOpacity = function(){
	var 
		icons = $('.doc-carousel .doc-ico'),
		min = 0.3,
		step = 0;
	
	if (!icons.length) return;
	
	step = (1-min)/(icons.length-1);
	
	//icons.reverse();
	icons.filter(':gt(0)').each( function(i)
		{
			var val = (1 - step*(i + 1)).toFixed(2);
			$(this).css('opacity', val);
		}
	);
}

sD.activateMenuArrows = function(){
	$('.menu .arr-down').on('click', function()
		{
			$(this).siblings('ul').slideToggle();
			return false;
		}
	);
}

sD.activateTooltips = function(){
	$('*[rel="tooltip"]').tooltip({
		open: function( event, ui )
		{
			ui.tooltip.removeClass('ui-corner-all').append('<div class="top" />');
		},
		position: {
			my: 'center top+7',
			at: 'center bottom'
		}
	});
}

sD.ajaxForms = function(){
	$(document).on("submit", "#contentHelper form", function(event) {
		event.preventDefault();
			if($(this).attr('action')!='') {
				for(var editor in CKEDITOR.instances) {
					CKEDITOR.instances[editor].updateElement();
				}
				var self = $(this);
				$(this).ajaxSubmit(function(data) {
						if(data==1) {
							$(self).find('.ajax_submit').parent().removeClass('disable hide-icon');
							$(self).find('.ajax_submit').prop('disabled', false);
							$(self).find('.ajax_submit').find('i').text($(self).find('.ajax_submit').data('success-name'));
							$(self).find('div.input').removeClass('fail');
							$(self).find('div.input p.error').remove();
						}
						else {
							if($.support.opacity) {
								$('#contentHelper').animate({opacity: 0.3}, 300, function() {
									$('#contentHelper').html(data).animate({opacity: 1}, 300);
									sD.multiselect();
									sD.enableTabs();
									sD.activateCalendars();
									sD.activateTooltips();
									sD.styleOpacity();
									sD.activateCarousel();
									sD.activateTopPanel();
									sD.enableTableDrag();
									sD.activateCheckAll();
									sD.activateCombo();
									show_seo_counters();
								});
							}
							else {
								$('#contentHelper').html(data);
								sD.multiselect();
								sD.enableTabs();
								sD.activateCalendars();
								sD.activateTooltips();
								sD.styleOpacity();
								sD.activateCarousel();
								sD.activateTopPanel();
								sD.enableTableDrag();
								sD.activateCheckAll();
								sD.activateCombo();
								show_seo_counters();
							}
						}
				});
			}
	});
	
	$(document).on("click", ".ajax_submit", function(event) {
		event.preventDefault();
		var form = $(this).closest('form');
		if(form.length) {
			$(this).prop('disabled', true);
			$(this).parent().addClass('disable hide-icon');
			$(form).submit();
		}
		return false;
	});

	$(document).on("click", ".submit_and_exit", function(event) {
		event.preventDefault();
		var form = $(this).closest('form');
		if(form.length) {
			$(form).append('<input type="hidden" name="after_exit" value="1">');
			$(this).prop('disabled', true);
			$(this).parent().addClass('disable');
			$(form).submit();
		}
		return false;
	});

	$(document).on("blur", '.update_onfly input[type="text"]', sD.smallAJAXform);
	$(document).on("change", ".update_onfly select", sD.smallAJAXform);
	$(document).on("blur", '.update_ajax_field', function() {
		var url = $(this).data('url');
		if(url.length) {
			var myForm = $(this).attr('name')+"="+$(this).val();
			$.post(url, myForm);
		}
	});

};

				 	function calcl_cart() {
						var total_price = 0,
						total_checkings = 0,
						total_products = 0;
						
						$(".order_products tr.product_line").each(function() {
							price = parseFloat($(this).find('.price_product').val());
							amount  = parseInt( $(this).find('.amount_product').val() );	
							price = price*amount;
							
							checking_price = 0;
							if($(this).find('.checking_id_product').prop('checked') && $(this).find('.price_checking_product').val()) {
								checking_price = parseFloat( $(this).find('.price_checking_product').val() );
								checking_price = checking_price*amount;
							}
							
							$(this).find('.cost_product').html(myNumberFormat(price+checking_price)+" руб.");
							
							total_products += amount;
							total_price += price;
							total_checkings += checking_price;
						});
						
						$('.text_total_products').html(total_products+' шт.');
						$('.text_total_price').html(myNumberFormat(total_price)+' руб.');
						$('.text_total_price').data('value', total_price);
						$('.text_total_checkings').html(myNumberFormat(total_checkings)+' руб.');
						$('.text_total_checkings').data('value', total_checkings);
						
						delivery_price = 0;
						if($('#cost_delivery').val()) delivery_price = parseFloat($('#cost_delivery').val());
						
						if($('.use_balls:checked').val()==2) {
							$('.for_balls_discount').find('input').val( (total_price+total_checkings+delivery_price) );
						}
						
						balls_discount = 0;
						if($('.use_balls:checked').val()>0 &&  $('#balls_discount').val()) {
							balls_discount = parseFloat($('#balls_discount').val());
						}
						full_price = total_price+total_checkings+delivery_price-balls_discount;
						$('.text_full_price').html(myNumberFormat( full_price)+' руб.' );
					}

sD.smallAJAXform = function() {
		var form = $(this).closest('form');
		if(form.length) {
			var url;
			if($(form).attr('action')!='') {
				url = $(form).attr('action');
				var myForm = $(form).serialize();
				$.post(url, myForm);
			}
		}
};

sD.uploadPreview = function() {
	$(document).on("change", "input.upload_preview", function() {
		if($(this).val().length) {
			var div_image = $(this).closest("td").find(".preview_image");
			$(div_image).find("img").animate({opacity: 0.3}, 300, function() {
				$(div_image).append('<div class="box_loading"></div>');
			});
			var clone = $(this).clone();
			clone.val('');
			clone.insertAfter($(this));
			var form = $('<form action="'+$(this).data('url')+'" method="post" enctype="multipart/form-data"></form>').append($(this));
			$(form).ajaxSubmit(function(data) {
				var objImagePreloader = new Image();
				var new_src = $(div_image).find("img").attr("src")+"?"+Math.random();
				objImagePreloader.onload = function() {
					$(div_image).find("img").attr("src", new_src);
					$(div_image).find(".box_loading").remove();
					$(div_image).find("img").stop().animate({opacity: 1}, 300);
					objImagePreloader.onload = function() {};
				};
				objImagePreloader.src = new_src;
			});
			//$(this).val('');
		}
	});
}

sD.smartFileInput = function() {
	$(document).on("change", ".input_smart_file input", function() {
		var filename = $(this).val().split(/[\/\\]+/);
		filename = filename[(filename.length - 1)];
		$(this).siblings(".file_name").html( filename );
	});
}

sD.redirect = function() {
	var url = arguments[0];
	var module = ( arguments[1] ? arguments[1] : "");
	setTimeout(function() {
		sD.loadPage(url, module);
	}, 2000);
}

sD.loadPage = function() {
	if (!History.enabled) {
			return;
	}

	var url = arguments[0];
	var module = ( arguments[1] ? arguments[1] : "");
	var State = History.getState();
	if(url==State.url) url = url+'&t='+Math.random();
	
	History.pushState({module: module}, document.title, url);
}

sD.activateAJAXlink = function() {
	$(document).on("click", ".ajax_link", function() {
		var url = $(this).attr('href');
		var module = ( $(this).data('module') ? $(this).data('module') : "");
		sD.loadPage(url, module);
		return false;	
	});	
}

sD.activateTranslit = function() {
	$(document).on("change", "input.title_for_slug", function() {
		var url = $(this).val();
		url = url.replace(/[\s]+/gi, '-');
		url = translit(url);
		url = url.replace(/[^0-9a-z_\-]+/gi, '').toLowerCase();	
		$("input.url_slug").val(url);
	});
}


function translit(str)
{
	var ru=("А-а-Б-б-В-в-Ґ-ґ-Г-г-Д-д-Е-е-Ё-ё-Є-є-Ж-ж-З-з-И-и-І-і-Ї-ї-Й-й-К-к-Л-л-М-м-Н-н-О-о-П-п-Р-р-С-с-Т-т-У-у-Ф-ф-Х-х-Ц-ц-Ч-ч-Ш-ш-Щ-щ-Ъ-ъ-Ы-ы-Ь-ь-Э-э-Ю-ю-Я-я").split("-")   
	var en=("A-a-B-b-V-v-G-g-G-g-D-d-E-e-E-e-E-e-ZH-zh-Z-z-I-i-I-i-I-i-J-j-K-k-L-l-M-m-N-n-O-o-P-p-R-r-S-s-T-t-U-u-F-f-H-h-TS-ts-CH-ch-SH-sh-SCH-sch-'-'-Y-y-'-'-E-e-YU-yu-YA-ya").split("-")   
 	var res = '';
	for(var i=0, l=str.length; i<l; i++)
	{ 
		var s = str.charAt(i), n = ru.indexOf(s); 
		if(n >= 0) { res += en[n]; } 
		else { res += s; } 
    } 
    return res;  
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

sD.multiselect = function() {
	$('.select').multiselect();	
	$('.multi_select').multiselect({
	   multiple: true,
	   header: true,
	   height: 300,
	   classes: "multi_select"
	});	
}

function update_newcount_module(module, count) {
	$('#menu-module-'+module+' .counter').remove();
	if(count>0) $('#menu-module-'+module+' .clip').append('<span class="counter">'+count+'</span>');
}

function quicksearchClose() {
	$("#quick_search_results").stop().fadeTo(300, 0, function() { $(this).find('.tooltip-container').empty()});
	$(document).off('click.quick_search');
}

function quicksearch() {
	var quickTime, oldVal;
	$(document).on("keyup", "#quick_input_search", function() {
		clearTimeout(quickTime);
		if($(this).val().length>2 && $(this).val()!=oldVal) {
			var self = $(this);
			quickTime = setTimeout(function () {
				oldVal = $(self).val();
                $.get($(self).data('url'), "q="+encodeURIComponent($(self).val()), function(data) {
					if(data != 0) {
						$("#quick_search_results").stop().fadeTo(300, 1, function() {
							$(document).on('click.quick_search', function (e) {
								var target = $(e.target);
								if (target.closest('#quick_search_results').size()) return;
								quicksearchClose();
							});	
						});
						$("#quick_search_results .tooltip-container").html(data);
					} else {
						quicksearchClose();
					}
				});
            }, 300);
		}
		else quicksearchClose();
	});
}

				 	function calcl_cart() {
						var total_price = 0,
						total_checkings = 0,
						total_products = 0;
						
						$(".order_products tr.product_line").each(function() {
							price = parseFloat($(this).find('.price_product').val());
							amount  = parseInt( $(this).find('.amount_product').val() );	
							price = price*amount;
							
							checking_price = 0;
							if($(this).find('.checking_id_product').prop('checked') && $(this).find('.price_checking_product').val()) {
								checking_price = parseFloat( $(this).find('.price_checking_product').val() );
								checking_price = checking_price*amount;
							}
							
							$(this).find('.cost_product').html(myNumberFormat(price+checking_price)+" руб.");
							
							total_products += amount;
							total_price += price;
							total_checkings += checking_price;
						});
						
						$('.text_total_products').html(total_products+' шт.');
						$('.text_total_price').html(myNumberFormat(total_price)+' руб.');
						$('.text_total_price').data('value', total_price);
						$('.text_total_checkings').html(myNumberFormat(total_checkings)+' руб.');
						$('.text_total_checkings').data('value', total_checkings);
						
						delivery_price = 0;
						if($('#cost_delivery').val()) delivery_price = parseFloat($('#cost_delivery').val());
						
						if($('.use_balls:checked').val()==2) {
							$('.for_balls_discount').find('input').val( (total_price+total_checkings+delivery_price) );
						}
						
						balls_discount = 0;
						if($('.use_balls:checked').val()>0 &&  $('#balls_discount').val()) {
							balls_discount = parseFloat($('#balls_discount').val());
						}
						full_price = total_price+total_checkings+delivery_price-balls_discount;
						$('.text_full_price').html(myNumberFormat( full_price)+' руб.' );
					}

function show_seo_counters() {
	$('.seo-input').each(function() {
        var htmlCounter = $('<span class="seo-counter"></span>');
		if($(this).val().length) htmlCounter.text($(this).val().length);
		$(this).after(htmlCounter);
    });
}

function updater_seo_counters() {
	$(document).on("change keyup blur", '.seo-input', function() {
		if($(this).val().length) 
			$(this).siblings('.seo-counter').text($(this).val().length);
		else 
			$(this).siblings('.seo-counter').text('');
    });
}

/**
 * Start functions
 */
$(document).ready( function(){
	History.Adapter.bind(window,'statechange',function(){ 
		var State = History.getState();
		var module = State.data.module;
		$(".menu-item, .menu-added").removeClass("active");
		if(module) {
			$("#menu-module-"+module).addClass("active");
			$("#menu-added-module-"+module).addClass("active");
		}
		
		if($.support.opacity) {
			$('#contentHelper').animate({opacity: 0.3}, 300);
		}
		else $('#contentHelper').css("visibility", "hidden");

		
		$.get(State.url, function(data) {
			if($.support.opacity) {
				$('#contentHelper').html(data).stop().animate({opacity: 1}, 300);
			}
			else $('#contentHelper').html(data).css("visibility", "visible");
			sD.multiselect();
			sD.enableTabs();
			sD.activateCalendars();
			sD.activateTooltips();
			sD.styleOpacity();
			sD.activateCarousel();
			sD.activateTopPanel();
			sD.enableTableDrag();
			sD.activateCheckAll();
			sD.activateCombo();
			show_seo_counters();
		});
	});
	
	sD.enableHints();
	sD.activateCombo();
	sD.enableTabs();
	sD.activateCalendars();
	sD.enableTableDrag();
	sD.enableTableSort();
	sD.activateConfirm();
	sD.initInputBlur();
	sD.activateCheckAll();
	sD.activateMenuArrows();
	sD.activateTooltips();
	
	sD.styleOpacity();
	sD.multiselect();
	
	sD.ajaxForms();
	sD.activateAJAXlink();
	sD.activateTranslit();
	sD.uploadPreview();
	sD.smartFileInput();
	quicksearch();
	show_seo_counters();
	updater_seo_counters();
	
	$(document).on("click", "a.delete-inline", function() {
							$(this).closest("tr").fadeOut(200, function() {
								var upd_order = false;
								if($(this).closest('.order_products')) upd_order = true;
								$(this).remove();
								if(upd_order) calcl_cart();
							});
							return false;	
	});
});

$(window).load( function(){
	sD.activateCarousel();
	sD.activateTopPanel();
});