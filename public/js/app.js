(function() {
  window.getCategoriesData = function() {
    return $.ajax({
      async: true,
      url: 'https://api.parse.com/1/functions/getCategories',
      type: 'POST',
      headers: {
        'x-parse-application-id': '837yxeNhLEJUXZ0ys2pxnxpmyjdrBnn7BcD0vMn7',
        'x-parse-rest-api-key': 'zdoU2CuhK5S1Dbi2WDb6Rcs4EgprFrrpiWx3fUBy'
      },
      data: {
        'sort_by': 'popularity'
      },
      dataType: 'JSON',
      success: function(response) {
        window.categorieData = response.result.data;
        getDepartment();
      }
    });
  };

  window.getDepartments = function() {
    var deparments, str, temp;
    temp = window.categorieData;
    deparments = _.where(temp, {
      parent: null
    });
    str = '';
    return $.each(deparments, function(index, items) {
      str = '<option value="' + items.id + '">' + items.name + '</option>';
      $('#department').append(str);
    });
  };

  window.getChildCategory = function() {
    var categoryData, deparmentChildrens, deparmentId, str, temp;
    deparmentId = $('#department').val;
    temp = window.categorieData;
    deparmentChildrens = _.where(temp, {
      id: deparmentId
    });
    categoryData = deparmentChildrens[0].children;
    $('select[name=\'category\']').html('<option value="">Select Category</option>');
    $('select[name=\'category\']').select2('val', '');
    $('.export_block').addClass('hidden');
    str = '';
    return $.each(categoryData, function(index, items) {
      str = '<option value="' + items.id + '">' + items.name + '</option>';
      $('select[name=\'category\']').append(str);
    });
  };

  window.getCustomers = function() {
    var query;
    query = new Parse.Query(Parse.User);
    query.equalTo("userType", "customer");
    return query.find().then(function(results) {
      return results;
    }, function(error) {
      return error;
    });
  };

}).call(this);

(function() {
  var getSellers;

  getSellers = function() {
    var sellers;
    sellers = [
      {
        'objectId': 'waX1yFgxqy',
        'name': 'energy saving ratings',
        'group': 'general',
        'unit': 'stars',
        'is_primary': 'no'
      }, {
        'objectId': 'TFXHBzAPOO',
        'name': 'ac type',
        'group': 'general',
        'unit': null,
        'is_primary': 'no'
      }
    ];
    return sellers;
  };

}).call(this);

//# sourceMappingURL=app.js.map