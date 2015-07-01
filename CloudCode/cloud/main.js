(function() {
  var _;

  _ = require('underscore.js');

  Parse.Cloud.job('productImport', function(request, response) {
    var BulkImport, query, queryFindPromise;
    BulkImport = Parse.Object.extend('bulkImport');
    query = new Parse.Query(BulkImport);
    query.include("import_based_id");
    queryFindPromise = query.find();
    queryFindPromise.done((function(_this) {
      return function(results) {
        var ProductItem, productSavedArr;
        ProductItem = Parse.Object.extend('ProductItem');
        productSavedArr = [];
        _.each(results, function(result) {
          var products;
          products = result.get("json");
          _.each(products, function(product) {
            var categoryObj, productItem;
            productItem = new ProductItem();
            productItem.set("name", product.name);
            productItem.set("images", product.images);
            productItem.set("model_number", product.model_number);
            categoryObj = {
              "__type": "Pointer",
              "className": "Category",
              "objectId": product.category
            };
            productItem.set("category", categoryObj);
            return productSavedArr.push(productItem);
          });
          return console.log("length of prodArr " + productSavedArr.length);
        });
        return Parse.Object.saveAll(productSavedArr, {
          success: function(objs) {
            response.success("Successful");
          },
          error: function(error) {
            return response.error("Failure");
          }
        });
      };
    })(this));
    return queryFindPromise.fail(function(error) {
      return response.error("The error is - " + error);
    });
  });

}).call(this);
