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
          return _.each(products, function(product) {
            var attributeValueArr, attributes, brandObj, categoryObj, productItem;
            productItem = new ProductItem();
            productItem.set("name", product.name);
            productItem.set("images", product.images);
            productItem.set("model_number", product.model_number);
            productItem.set("mrp", parseInt(product.mrp));
            productItem.set("popularity", product.popularity);
            productItem.set("group", product.group);
            categoryObj = {
              "__type": "Pointer",
              "className": "Category",
              "objectId": product.category
            };
            productItem.set("category", categoryObj);
            brandObj = {
              "__type": "Pointer",
              "className": "Brand",
              "objectId": product.brand
            };
            productItem.set("brand", brandObj);
            attributeValueArr = [];
            attributes = product.attrs;
            _.each(attributes, function(attributeId) {
              var attribObj;
              attribObj = {
                "__type": "Pointer",
                "className": "AttributeValues",
                "objectId": attributeId
              };
              return attributeValueArr.push(attribObj);
            });
            productItem.set("attrs", attributeValueArr);
            return productSavedArr.push(productItem);
          });
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
