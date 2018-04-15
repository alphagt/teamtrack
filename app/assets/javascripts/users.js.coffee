# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

closechildren =(target) ->
	console.log("closing children for " + target)
	$(target).each ->
		$(@).collapse('hide')
	$(target).not('.collapsed').filter('[data-toggle]').each ->
		closechildren($(@).data("target"))

$ ->
	console.log("DOM is Ready") 
	$(".collapsed").click  -> 
		t = $(this).data("target")
		p = $(this).attr("id")
		console.log(t + " something Clicked")
		$subs = $(t).not('.collapsed').filter('[data-toggle]')
		$subs.each ->
			closechildren($(@).data("target"))
				
				
