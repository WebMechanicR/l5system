
/*	Name: jquery-funcs.js
	Written by: Imaginacionweb - (http://www.iwthemes.com)
	Version: 1.2
*/

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

	//=================================== Twitter Feed  =================================//

    $(".twitter").tweet({
        modpath: 'js/twitter/index.php',
        username: "iwthemes",
        count: 5,
        loading_text: "Loading tweets...",
    });

    //=================================== Carousels Footer  =================================//

    $(".about, .tweet_list, .post, .testimonials_carousel").owlCarousel({ 	
		  autoPlay: 4000,      
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

        
});

//================================== Slide portfolio =============================//

	$('#slide_portfolio').camera({
		 height: '57%'
	});
	
