//Hook up the tweet display

$(document).ready(function() {
						   
	$("#countdown").countdown({
				date: "1 march 2015 11:00:00",
				format: "on"
			},
			
			function() {
				// callback function
			});

    $(".tweet").tweet({
        username: "flashuser",
        count: 3,
        loading_text: "loading tweets..."
    });

});	
