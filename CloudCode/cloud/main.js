(function() {
  var _, getAttribValueMapping, treeify;

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

  getAttribValueMapping = function(categoryId, filterableAttributes, secondaryAttributes) {
    var AttributeValues, Attributes, Category, categoryQuery, findCategoryPromise;
    if (filterableAttributes == null) {
      filterableAttributes = true;
    }
    if (secondaryAttributes == null) {
      secondaryAttributes = false;
    }
    Category = Parse.Object.extend('Category');
    Attributes = Parse.Object.extend('Attributes');
    AttributeValues = Parse.Object.extend('AttributeValues');
    categoryQuery = new Parse.Query("Category");
    categoryQuery.equalTo("objectId", categoryId);
    categoryQuery.include("filterable_attributes");
    findCategoryPromise = categoryQuery.first();
    return findCategoryPromise.done((function(_this) {
      return function(categoryData) {
        return categoryData;
      };
    })(this));
  };

  Parse.Cloud.define('getAttribValueMapping', function(request, response) {
    var AttributeValues, Attributes, Category, categoryId, categoryQuery, findCategoryPromise;
    categoryId = request.params.categoryId;
    Category = Parse.Object.extend('Category');
    Attributes = Parse.Object.extend('Attributes');
    AttributeValues = Parse.Object.extend('AttributeValues');
    categoryQuery = new Parse.Query("Category");
    categoryQuery.equalTo("objectId", categoryId);
    categoryQuery.include("filterable_attributes");
    findCategoryPromise = categoryQuery.first();
    return findCategoryPromise.done((function(_this) {
      return function(categoryData) {
        var filterable_attributes, findQs, result;
        filterable_attributes = categoryData.get('filterable_attributes');
        result = [];
        findQs = _.map(filterable_attributes, function(attribute) {
          var attributeId, attributeValues, innerQuery, query, resultAttribObject;
          attributeId = attribute.id;
          attributeValues = [];
          resultAttribObject = {
            'name': attribute.get("name"),
            'id': attributeId
          };
          innerQuery = new Parse.Query("Attributes");
          innerQuery.equalTo("objectId", attributeId);
          query = new Parse.Query("AttributeValues");
          query.matchesQuery("attribute", innerQuery);
          query.include("attribute");
          return query.find();
        });
        return Parse.Promise.when(findQs).then(function(attributeValuesArray) {
          var finalArr, individualFindResults;
          individualFindResults = _.flatten(_.toArray(attributeValuesArray));
          finalArr = [];
          _.each(individualFindResults, function(individualResult) {
            var object;
            object = {
              "attributeId": individualResult.get("attribute").id,
              "attributeName": individualResult.get("attribute").get("name"),
              "group": individualResult.get("attribute").get("group"),
              "displayType": individualResult.get("attribute").get("displayType"),
              "value": individualResult.get("value")
            };
            console.log(object);
            return finalArr.push(object);
          });
          Parse.Promise.as();
          return response.success(finalArr);
        }, function(error) {
          return response.error(error);
        });
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
    var ascending, categoryId, displayLimit, filterableAttribQuery, findFilterableAttrib, page, selectedFilters, sortBy;
    categoryId = request.params.categoryId;
    selectedFilters = request.params.selectedFilters;
    sortBy = request.params.sortBy;
    ascending = request.params.ascending;
    page = parseInt(request.params.page);
    displayLimit = parseInt(request.params.displayLimit);
    filterableAttribQuery = new Parse.Query("Category");
    filterableAttribQuery.equalTo("objectId", categoryId);
    filterableAttribQuery.select("filterable_attributes");
    filterableAttribQuery.include("filterable_attributes");
    findFilterableAttrib = filterableAttribQuery.find();
    findFilterableAttrib.done((function(_this) {
      return function(filters) {
        var ProductItem, brand, endPrice, filterableProps, innerBrandQuery, innerQuery, price, query, queryFindPromise, startPrice;
        ProductItem = Parse.Object.extend("ProductItem");
        innerQuery = new Parse.Query("Category");
        innerQuery.equalTo("objectId", categoryId);
        query = new Parse.Query("ProductItem");
        query.matchesQuery("category", innerQuery);
        if ((selectedFilters !== "all") && (_.isObject(selectedFilters))) {
          filterableProps = Object.keys(selectedFilters);
          if (_.contains(filterableProps, "brand")) {
            brand = selectedFilters["brand"];
            innerBrandQuery = new Parse.Query("Brand");
            innerBrandQuery.equalTo("objectId", brand);
            query.matchesQuery("brand", innerBrandQuery);
          }
          if (_.contains(filterableProps, "price")) {
            price = selectedFilters["price"];
            startPrice = parseInt(price[0]);
            endPrice = parseInt(price[1]);
            query.greaterThanOrEqualTo("mrp", startPrice);
            query.lessThanOrEqualTo("mrp", endPrice);
          }
        }
        query.select("images,name,mrp,brand");
        query.include("brand");
        query.limit(displayLimit);
        query.skip(page * displayLimit);
        if (ascending === true) {
          query.ascending(sortBy);
        } else {
          query.descending(sortBy);
        }
        queryFindPromise = query.find();
        queryFindPromise.done(function(products) {
          var result;
          result = {
            products: products,
            filters: filters,
            sortableAttributes: ["mrp", "popularity"]
          };
          return response.success(result);
        });
        return queryFindPromise.fail(function(error) {
          return response.error(error.message);
        });
      };
    })(this));
    return findFilterableAttrib.fail((function(_this) {
      return function(error) {
        return response.error(error.message);
      };
    })(this));
  });

  Parse.Cloud.define('getProduct', function(request, response) {
    var ProductItem, productId, queryProductItem;
    productId = request.params.productId;
    ProductItem = Parse.Object.extend("ProductItem");
    queryProductItem = new Parse.Query(ProductItem);
    queryProductItem.equalTo("objectId", productId);
    queryProductItem.include("attrs");
    queryProductItem.include("attrs.attribute");
    queryProductItem.include("category");
    return queryProductItem.first().then(function(ProductData) {
      return response.success(ProductData);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.useMasterKey();

  Parse.Cloud.define("sendSMSCode", function(request, response) {
    var code, onError, phone, query, save;
    phone = request.params.phone;
    code = (Math.floor(Math.random() * 900000) + 100000).toString();
    onError = function(error) {
      return response.error(error);
    };
    save = function(obj, attempts) {
      if (attempts > 3) {
        return response.success({
          attemptsExceeded: true
        });
      } else {
        return obj.save({
          'phone': phone,
          'verificationCode': code,
          'attempts': attempts
        }).then(function() {
          return response.success({
            code: code,
            attemptsExceeded: false
          });
        }, onError);
      }
    };
    query = new Parse.Query('SMSVerify');
    query.equalTo("phone", phone);
    return query.find().then(function(obj) {
      var SMSVerify, attempts, verify;
      if (_.isEmpty(obj)) {
        SMSVerify = Parse.Object.extend("SMSVerify");
        verify = new SMSVerify();
        return save(verify, 1);
      } else {
        obj = obj[0];
        attempts = obj.get('attempts');
        return save(obj, attempts + 1);
      }
    }, onError);
  });

  Parse.Cloud.afterSave("SMSVerify", function(request) {
    var obj, phone, verificationCode;
    obj = request.object;
    phone = obj.get('phone');
    return verificationCode = obj.get('verificationCode');
  });

  Parse.Cloud.define("verifySMSCode", function(request, response) {
    var code, phone, query;
    phone = request.params.phone;
    code = request.params.code;
    query = new Parse.Query('SMSVerify');
    query.equalTo("phone", phone);
    return query.find().then(function(obj) {
      var verificationCode, verified;
      obj = obj[0];
      verificationCode = obj.get('verificationCode');
      verified = verificationCode === code ? true : false;
      if (verified) {
        obj.destroy();
      }
      return response.success({
        'verified': verified
      });
    }, function(error) {
      return response.error(error);
    });
  });

}).call(this);
