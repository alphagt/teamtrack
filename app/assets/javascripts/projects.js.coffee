# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@updateprilist =(list) ->
   selectedi = list.selectedOptions[0].value
   console.log("theme changed!" + selectedi)
   theme = window.$("#project_initiative_id")[0]
   console.log("Active Theme id is:  " + theme.selectedOptions[0].text )
   array = gon.ctplists[selectedi]
   console.log("New Picklist is:  "  + gon.ctplists[selectedi])
   
   ctpselect = window.$("#project_ctpriority")
   currentctp = $(ctpselect)[0].selectedOptions[0].value
   console.log("Current Selection is:  " + currentctp)
   $(ctpselect).empty()
   $(array).each ->
   	 console.log("processing item: " + @)
   	 opt = document.createElement("option")
   	 opt.text = @
   	 opt.value = @
   	 $(ctpselect).append($(opt))
   	 if opt.value == currentctp
   	 	$(opt).attr("selected", true)
   	 


$(document).ready ->
  $("#p_org").change ->
    window.location.search = 'org=' + (this).value
   
