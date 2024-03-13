(function() {
  var checkchildren, fetchrows;

  checkchildren = function(target) {
    var pname, submgrs;
    console.log("closing children for " + target);
    pname = "parent-" + target.split("C")[0].substring(1);
    submgrs = $(target).filter('[data-group]');
    return submgrs.each(function() {
      var kids;
      if ($(this).hasClass('in')) {
        checkchildren($(this).data("group"));
        $(this).collapse('hide');
        kids = $($(this).data("group"));
        return kids.each(function() {
          return $(this).collapse('hide');
        });
      }
    });
  };

  fetchrows = function(rowent) {
    var $body, icontd, isdirect, m, mid, org, sclass, tperiod, u;
    mid = $(rowent).attr("id").split("-");
    m = mid[mid.length - 1];
    icontd = rowent.firstElementChild;
    sclass = $(icontd).data("target").substring(1);
    org = $(icontd).data("org");
    isdirect = $(icontd).data("direct");
    tperiod = $(icontd).data("period");
    console.log("IsDirect for " + mid + ": " + isdirect);
    $body = window.$("#body-" + m);
    u = "/users/teamlist";
    return $.ajax({
      url: u,
      data: {
        id: m,
        tname: sclass,
        baseorg: org,
        isdirect: isdirect,
        tperiod: tperiod
      }
    }).done(function(html) {
      console.log(html);
      return $body.prepend(html);
    });
  };

  $(function() {
    console.log("DOM is Ready");
    $(".collapsed").on("click", function() {
      var p, t;
      t = $(this).data("target");
      return p = $(this).attr("id");
    });
    $(".icon-class").on("click", function() {
      var p, row, t;
      console.log("Caught Icon Click");
      row = $(arguments)[0].target.parentElement;
      t = $(this).data("target");
      p = $(row).attr("id");
      if ($(row).hasClass('pending')) {
        $(row).removeClass('pending');
        return fetchrows(row);
      } else {
        return checkchildren(t);
      }
    });
    $('tr').on("show.bs.collapse", function(e) {
      return console.log("Catch show event");
    });
    $('tr').on("hide.bs.collapse", function(e) {
      return console.log("Catch hide event");
    });
    return $("#u_acct").change(function() {
      window.location.search = 'acct=' + this.value;
      return $("#i_week").change(function() {
        return window.location.search = 'pDate=' + this.value;
      });
    });
  });

}).call(this);
