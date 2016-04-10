dir_css = "css/";

$(document).ready(function(){	

	'use strict';

 	//=================================== Nav Responsive ===================================//

    $('#menu').tinyNav({
       active: 'selected'
    });

    //=================================== Tabs Varius  ===================================//

	$(".tab_content").hide(); //Hide all content
	$("ul.tabs li:first").addClass("active").show(); //Activate first tab
	$(".tab_content:first").show(); //Show first tab content
	
	//=================================== Tabs On Click Event  ===================================//
	$("ul.tabs li").click(function() {
		$("ul.tabs li").removeClass("active"); //Remove any "active" class
		$(this).addClass("active"); //Add "active" class to selected tab
		$(".tab_content").hide(); //Hide all tab content
		var activeTab = $(this).find("a").attr("href"); //Find the rel attribute value to identify the active tab + content
		$(activeTab).fadeIn(); //Fade in the active content
		return false;
	});

	//=================================== Totop  ===================================//
	$().UItoTop({ 		
		scrollSpeed:500,
		easingType:'linear'
	});	

	//=================================== Subtmit Form  =================================//

	$('#form').submit(function(event) {  
	  event.preventDefault();  
	  var url = $(this).attr('action');  
	  var datos = $(this).serialize();  
	  $.get(url, datos, function(resultado) {  
	    $('#result').html(resultado);  
	  });  
	});  

	//=================================== Form Newslleter  =================================//

	  $('#newsletterForm').submit(function(event) {  
	       event.preventDefault();  
	       var url = $(this).attr('action');  
	       var datos = $(this).serialize();  
	        $.get(url, datos, function(resultado) {  
	        $('#result-newsletter').html(resultado);  
	    });  
	  });  

	
	//=================================== Carousel Sponsors  =================================//

	$("#sponsors").owlCarousel({ 	
		  autoPlay: 4000,      
	      items : 6,
	      pagination: false,
	      navigation: true 
	 });

	//=================================== Carousel Recent Work  =================================//

	$("#recent_work").owlCarousel({ 	
		  autoPlay: 4000,      
	      items : 4,
	      pagination: true,
	      navigation: false 
	 });

	

    //=================================== Carousels Footer  =================================//

    $(".about, .tweet_list, .post, .testimonials_carousel").owlCarousel({ 	
		  autoPlay: 11000,      
	      items : 1,
	      itemsDesktop : [1199,1],
	      itemsDesktopSmall : [979,1],
	      itemsTablet: [768,1],
		  itemsMobile : [479,1], 
	  });

	//=================================== Ligbox  ===================================//
	
	    jQuery("a[class*=fancybox]").fancybox({
		'overlayOpacity'	:	0.7,
		'overlayColor'		:	'#000000',
		'transitionIn'		: 'elastic',
		'transitionOut'		: 'elastic',
		'easingIn'      	: 'easeOutBack',
		'easingOut'     	: 'easeInBack',
		'speedIn' 			: '700',
		'centerOnScroll'	: true
	});
	
	jQuery("a[class*='video_lightbox']").click(function(){
		var et_video_href = jQuery(this).attr('href'),
			et_video_link;

		et_vimeo = et_video_href.match(/vimeo.com\/(.*)/i);
		if ( et_vimeo != null )	et_video_link = 'http://player.vimeo.com/video/' + et_vimeo[1];
		else {
			et_youtube = et_video_href.match(/watch\?v=([^&]*)/i);
			if ( et_youtube != null ) et_video_link = 'http://youtube.com/embed/' + et_youtube[1];
		}
		
		jQuery.fancybox({
			'overlayOpacity'	:	0.7,
			'overlayColor'		:	'#000000',
			'autoScale'		: true,
			'transitionIn'	: 'elastic',
			'transitionOut'	: 'elastic',
			'easingIn'      : 'easeOutBack',
			'easingOut'     : 'easeInBack',
			'type'			: 'iframe',
			'centerOnScroll'	: true,
			'speedIn' 			: '700',
			'href'			: et_video_link
		});
		return false;
	});

	
	//=================================== Tooltips =====================================//

	if( $.fn.tooltip() ) {
		$('[class="tooltip_hover"]').tooltip();
	}
    
    //=================================== Slide =====================================//
		
	$('#slide').camera({
		height: '40%',	  
		pagination:true    
	});

	 //=================================== Your functinos =====================================//
    
	if(isMobile() || detectIE()){
		var val = '-20px';
		if(isMobile()){
			val = '-30px';
			$('.hidden-in-mobile').hide();
			$('.shown-in-mobile').show();
			$.each($('.change-in-mobile'), function(i, v){
				$(this).html($(this).data('in-mobile'));
			})
			
		}
		
		$('.item_service .image_service').css({left: val});
		$('.item_service_right .image_service').css({right: val});
	}
	
	if(!isMobile()){
		$('.no-margin-if-mobile').css({'margin-left': '80px'});
	}
	
	$('a.m-open-new-comment').on("click", function(e){
		e.preventDefault();
		$(this).closest('div.m-form-comment').find('div.m-new-comment').show();
		$(this).remove();
	});
	
	$('#js-scroll-to-news').on('click', function(e){
		e.preventDefault();
		$("html, body").animate({ scrollTop: $('#m-news-block').offset().top }, 1000);
	});
	
	$('a.m-open-hidden-text').on('click', function(e){
			e.preventDefault();
			var block = $(this).closest('p').find('span.m-hidden-text');
			block.toggleClass('active');
			var d = $(this).data('other');
			$(this).data('other', $(this).html());
			$(this).html(d);
	})
	
});

//================================== Slide portfolio =============================//

	$('#slide_portfolio').camera({
		 height: '57%'
	});
	
	
	function isMobile() {
		if( navigator.userAgent.match(/Android/i) ||
			navigator.userAgent.match(/webOS/i) ||
			navigator.userAgent.match(/iPad/i) ||
			navigator.userAgent.match(/iPhone/i) ||
			navigator.userAgent.match(/iPod/i) ||
			navigator.userAgent.match(/Windows Phone/i) ||
			navigator.userAgent.match(/WPDesktop/i)
			){
				return true;
		}
	}
	
	function detectIE() {
		var ua = window.navigator.userAgent;

		var msie = ua.indexOf('MSIE ');
		if (msie > 0) {
			// IE 10 or older => return version number
			return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
		}

		var trident = ua.indexOf('Trident/');
		if (trident > 0) {
			// IE 11 => return version number
			var rv = ua.indexOf('rv:');
			return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
		}

		var edge = ua.indexOf('Edge/');
		if (edge > 0) {
		   // IE 12 => return version number
		   return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
		}

		// other browser
		return false;
	}
	
	if(!isMobile()){
		$('head').append('<link rel="stylesheet" href="" id="not-mobile-styles"/>');
		$('#not-mobile-styles').attr('href', dir_css + 'not-mobile.css'); 
	}
