$(document).ready(function() {
	
	// First Category Portfolio Items
	
	$("a#port_nav_first").click(function() {
		$("a#port_nav_second, a#port_nav_third").removeClass("current_port_nav");
		$(this).addClass("current_port_nav");
		
		$("#portfolio_second, #portfolio_third").css({ "display" : "none" });
		$("#portfolio_first").fadeIn(900);
		
		return false;
	});
	
	// Second Category Portfolio Items
	
	$("a#port_nav_second").click(function() {
		$("a#port_nav_first, a#port_nav_third").removeClass("current_port_nav");
		$(this).addClass("current_port_nav");
		
		$("#portfolio_first, #portfolio_third").css({ "display" : "none" });
		$("#portfolio_second").fadeIn(900);
		
		return false;
	});
	
	// Third Category Portfolio Items
	
	$("a#port_nav_third").click(function() {
		$("a#port_nav_first, a#port_nav_second").removeClass("current_port_nav");
		$(this).addClass("current_port_nav");
		
		$("#portfolio_first, #portfolio_second").css({ "display" : "none" });
		$("#portfolio_third").fadeIn(900);
		
		return false;
	});
	
	// Loads data from folders and inserts it into "portfolio_display" div
	
	$(".portfolio_item_summary").hover(function() {
			$(this).css({ "background-color" : "#eee" });
		}, function() {
			$(this).css({ "background-color" : "#f2f2f2" });
		});
	$(".portfolio_item_summary p, .portfolio_item_summary h3, .portfolio_item_summary img").hover(function() {
			$(this).css({ "cursor" : "pointer" });
		}, function() {
			$(this).css({ "cursor" : "default" });
		});
		
	$("#portfolio_display").empty();
	$("#portfolio_display").append('<img src="portfolio_first/main_image/0.jpg" alt="Image" />');
	$("<div></div>").appendTo("#portfolio_display").load("portfolio_first/description/0.txt");
	
	$(".portfolio_item_summary a, .portfolio_item_summary p, .portfolio_item_summary h3, .portfolio_item_summary img").click(function() {
		$("#portfolio_display").empty();
		$("#portfolio_display").css({ "display" : "none" });
		
		var folder = $(this).parent().parent().attr('id');
		var file_name = $(this).parent().prevAll(".portfolio_item_summary").length;
		
		$("#portfolio_display").append('<img src="' + folder + '/main_image/' + file_name + '.jpg" alt="Image" />');
		$("<div></div>").appendTo("#portfolio_display").load(folder + '/description/' + file_name + '.txt');
		
		$("#portfolio_display").fadeIn("normal");
		
		return false;
	});
});