# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

checkchildren =(target) ->
	console.log("closing children for " + target)
	pname = "parent-" + target.split("C")[0].substring(1)
	submgrs = $(target).filter('[data-group]')
	submgrs.each ->
		if $(@).hasClass('in')
			checkchildren($(@).data("group"))
			$(@).collapse('hide')
			kids = $($(@).data("group"))
			kids.each ->
				$(@).collapse('hide')

		
fetchrows =(rowent) ->
	mid = $(rowent).attr("id").split("-")
	m = mid[mid.length - 1]
	icontd = rowent.firstElementChild
	sclass = $(icontd).data("target").substring(1)
	org = $(icontd).data("org")
	isdirect = $(icontd).data("direct")
	tperiod = $(icontd).data("period")
	console.log("IsDirect for " + mid + ": " + isdirect)
	$body = window.$("#body-" + m)
	u = "/users/teamlist"
	$.ajax(url: u, data: {id: m, tname: sclass, baseorg: org, isdirect: isdirect, tperiod: tperiod}).done (html) ->
		console.log(html)
		$body.prepend(html)
	

$ ->
	console.log("DOM is Ready") 
	$(".collapsed").on "click", ()  -> 
		t = $(this).data("target")
		p = $(this).attr("id")

			
	$(".icon-class").on "click", () ->
		console.log("Caught Icon Click")
		row = $(arguments)[0].target.parentElement
		t = $(this).data("target")
		p = $(row).attr("id")
		if $(row).hasClass('pending')
			$(row).removeClass('pending')
			fetchrows(row)
		else		
			checkchildren(t)

	$('tr').on "show.bs.collapse", (e) ->
	#	e.preventDefault()
		console.log("Catch show event")
		
	$('tr').on "hide.bs.collapse", (e) ->
	#	e.preventDefault()
		console.log("Catch hide event")
		
		
					
