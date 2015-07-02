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

  Parse.Cloud.define('getCategories', function(request, response) {
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
            sort_order: resultobj.get('sort_order'),
            image: resultobj.get('image')
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
    var ProductItem, productSavedArr, products;
    ProductItem = Parse.Object.extend('ProductItem');
    productSavedArr = [];
    products = request.params.products;
    _.each(products, function(product) {
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
    return Parse.Object.saveAll(productSavedArr, {
      success: function(objs) {
        response.success("Successfully added the products");
      },
      error: function(error) {
        return response.error("Failed to add products due to - " + error.message);
      }
    });
  });

  Parse.Cloud.define('getProducts', function(request, response) {
    var ProductItem, allProductsQuery, brand, categoryBasedProducts, categoryId, displayLimit, innerQuery, limit, offset, page, query, queryFindPromise, selectedFilters, sortBy;
    categoryId = request.params.categoryId;
    selectedFilters = request.params.selectedFilters;
    sortBy = request.params.sortBy;
    offset = request.params.offset;
    limit = request.params.limit;
    brand = request.params.brandId;
    categoryBasedProducts = [];
    ProductItem = Parse.Object.extend("ProductItem");
    allProductsQuery = new Parse.Query(ProductItem);
    innerQuery = new Parse.Query("Category");
    innerQuery.equalTo("objectId", categoryId);
    query = new Parse.Query("ProductItem");
    query.matchesQuery("category", innerQuery);
    query.include("category");
    query.include("brand");
    query.include("attrs");
    query.include("attrs.attribute");
    page = offset;
    displayLimit = limit;
    query.limit(displayLimit);
    query.skip(page * limit);
    queryFindPromise = query.find();
    queryFindPromise.done((function(_this) {
      return function(products) {
        return response.success(products);
      };
    })(this));
    return queryFindPromise.fail((function(_this) {
      return function(error) {
        return response.error(error.message);
      };
    })(this));
  });

}).call(this);
