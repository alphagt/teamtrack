(function() {
  $(document).ready(function() {
    $("#f_year").change(function() {
      return window.location.search = 'fy=' + this.value;
    });
    return $("#f_quarter").change(function() {
      return window.location.search = 'q=' + this.value + '&fy=' + $("#f_year").val();
    });
  });

}).call(this);
