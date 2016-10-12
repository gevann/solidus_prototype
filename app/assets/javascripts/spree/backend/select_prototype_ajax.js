$(document).on('change', '#product_prototype_id', function() {
  var solidus_prototype_select = $('#product_prototype_id');
  var id = solidus_prototype_select.val();
  if (id.length) {
    var url = new Uri('prototypes');
    url.setPath(url.path() + '/' + id);
    $('#product-from-prototype').load(url.toString());
  } else {
    $('#product-from-prototype').empty();
  }
});
