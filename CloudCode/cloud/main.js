(function() {
  var _, treeify;

  _ = require('underscore.js');

  treeify = function(list, idAttr, parentAttr, childrenAttr) {
    var lookup, treeList;
    if (!idAttr) {
      idAttr = 'id';
    }
    if (!parentAttr) {
      parentAttr = 'parent';
    }
    if (!childrenAttr) {
      childrenAttr = 'children';
    }
    treeList = [];
    lookup = {};
    list.forEach(function(obj) {
      lookup[obj[idAttr]] = obj;
      obj[childrenAttr] = [];
    });
    list.forEach(function(obj) {
      var parentId;
      if (obj[parentAttr] !== null) {
        parentId = obj[parentAttr];
        lookup[parentId][childrenAttr].push(obj);
      } else {
        treeList.push(obj);
      }
    });
    return treeList;
  };

  Parse.Cloud.define('generateCategoryHierarchy', function(request, response) {
    var Category, queryCategory, queryFindPromise, sortBy;
    sortBy = request.params.sortBy;
    Category = Parse.Object.extend('Category');
    queryCategory = new Parse.Query(Category);
    queryCategory.include("parent_category");
    queryFindPromise = queryCategory.find();
    queryFindPromise.done((function(_this) {
      return function(results) {
        var categoryHierarchyTree, list, responseData;
        list = [];
        _.each(results, function(resultobj) {
          var listObj, parentCat;
          listObj = {
            id: resultobj.id,
            name: resultobj.get('name'),
            sort_order: resultobj.get('sort_order')
          };
          if (_.isObject(resultobj.get('parent_category'))) {
            parentCat = resultobj.get('parent_category');
            listObj['parent'] = parentCat.id;
          } else {
            listObj['parent'] = null;
          }
          return list.push(listObj);
        });
        categoryHierarchyTree = treeify(list, 'id', 'parent', 'children');
        responseData = {
          "success": true,
          "data": _.sortBy(categoryHierarchyTree, sortBy)
        };
        return response.success(responseData);
      };
    })(this));
    return queryFindPromise.fail((function(_this) {
      return function(error) {
        var responseData;
        responseData = {
          "success": false,
          "errorCode": error.code,
          "msg": error.msg
        };
        return response.error(responseData);
      };
    })(this));
  });

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
            response.success("Successfully added the products");
          },
          error: function(error) {
            return response.error("Failed to add products due to - " + error.message);
          }
        });
      };
    })(this));
    return queryFindPromise.fail(function(error) {
      return response.error("Error in products upload - " + error.message);
    });
  });

}).call(this);
