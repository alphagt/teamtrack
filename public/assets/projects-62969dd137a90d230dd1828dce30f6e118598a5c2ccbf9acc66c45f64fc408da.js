(function() {
  this.updateprilist = function(list) {
    var array, ctpselect, currentctp, selectedi, theme;
    selectedi = list.selectedOptions[0].value || 0;
    console.log("theme changed!" + selectedi);
    theme = window.$("#project_initiative_id")[0];
    console.log("Active Theme id is:  " + theme.selectedOptions[0].text);
    array = gon.ctplists[selectedi];
    console.log("New Picklist is:  " + gon.ctplists[selectedi]);
    ctpselect = window.$("#project_ctpriority");
    currentctp = $(ctpselect)[0].selectedOptions[0].value;
    console.log("Current Selection is:  " + currentctp);
    $(ctpselect).empty();
    return $(array).each(function() {
      var opt;
      console.log("processing item: " + this);
      opt = document.createElement("option");
      opt.text = this;
      opt.value = this;
      $(ctpselect).append($(opt));
      if (opt.value === currentctp) {
        return $(opt).attr("selected", true);
      }
    });
  };

  $(document).ready(function() {
    return $("#p_org").change(function() {
      return window.location.search = 'org=' + this.value;
    });
  });

}).call(this);
