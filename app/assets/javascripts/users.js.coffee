# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	console.log("DOM is Ready") 
	$(".collapsed").click  -> 
		t = $(this).data("target")
		p = $(this).attr("id")
		console.log(t + " something Clicked")
		$subs = $(t).not('.collapsed').filter('[data-toggle]')
		$subs.each ->
			m = $(@).data("target")
			console.log("cascade for " + m )
			
			$(m).each ->
				$(@).collapse('hide')
