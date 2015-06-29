(function() {
  var Category;

  Category = Parse.Object.extend('Category');

  Parse.Cloud.beforeSave('Category', function(request, response) {
    var query;
    if (!request.object.get('name')) {
      response.error('A Category must have a name.');
    } else {
      query = new Parse.Query(Category);
      query.equalTo('name', request.object.get('name'));
      query.first({
        success: function(object) {
          if (object) {
            response.error('A Category with this name already exists.');
          } else {
            response.success();
          }
        },
        error: function(error) {
          response.error('Could not validate uniqueness for this Category object.');
        }
      });
    }
  });

}).call(this);
