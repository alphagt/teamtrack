(function() {
  $(function() {
    return $("#newic").on("click", function(e) {
      e.preventDefault();
      return window.location.href = this.href + '?note=' + prompt("Invite Code Note", "");
    });
  });

}).call(this);
