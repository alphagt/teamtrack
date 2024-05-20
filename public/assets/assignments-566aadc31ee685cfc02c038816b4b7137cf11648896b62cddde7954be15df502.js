(function() {
  $(document).on("focus", "[data-behaviour~='datepicker']", function(e) {
    -$(this).datepicker;
    -({
      format: "dd-mm-yyyy"
    });
    -({
      weekStart: 1
    });
    return -{
      autoclose: true
    };
  });

  $(function() {
    $("#t_range").on("click", function(e) {
      e.preventDefault();
      console.log("caught button click");
      return window.location.search = 'fy=' + $("#t_fy").val() + '&wkrange=' + prompt("Week Range?", "");
    });
    $("#t_week").change(function() {
      return window.location.search = 'wk=' + this.value + '&fy=' + $("#t_fy").val();
    });
    return $("#t_fy").change(function() {
      return window.location.search = 'wk=' + $("#t_week").val() + '&fy=' + this.value;
    });
  });

}).call(this);
