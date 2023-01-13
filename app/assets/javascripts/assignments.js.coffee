# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).on "focus", "[data-behaviour~='datepicker']", (e) ->
 - $(this).datepicker
 - format: "dd-mm-yyyy"
 - weekStart: 1
 - autoclose: true
 
$ ->
	$("#t_range").on "click", (e) ->
		e.preventDefault()
		console.log("caught button click")
		window.location.search = 'fy=' + $("#t_fy").val() + '&wkrange=' + prompt("Week Range?","")
		
	$("#t_week").change ->
   		window.location.search = 'wk=' + (this).value + '&fy=' + $("#t_fy").val()
    
    $("#t_fy").change ->
    	window.location.search = 'wk=' + $("#t_week").val() + '&fy=' + (this).value

