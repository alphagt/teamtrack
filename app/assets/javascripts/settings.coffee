# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$ ->
	$("#newic").on "click", (e) ->
		e.preventDefault()
	#	note = prompt("Please enter your name","")	
	#	b = this.href + '?note=' + note
	#	window.alert(b + '?note=' + note)
		window.location.href = this.href + '?note=' + prompt("Invite Code Note","")