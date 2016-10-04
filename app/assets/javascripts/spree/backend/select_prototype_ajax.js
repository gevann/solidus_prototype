(function($){
  var base_url = "<%= admin_prototypes_url %>";
  var prototype_select = $('#product_prototype_id');
  prototype_select.change(function() {
    var id = prototype_select.val();
    if (id.length) {
      var url = new Uri(base_url);
      url.setPath(url.path() + '/' + id);
      $('#product-from-prototype').load(url.toString());
    } else {
      $('#product-from-prototype').empty();
    }
  })
  if (prototype_select.html() == "") {
    prototype_select.change();
  }
})(jQuery);
