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
    sortBy = parseInt(request.params.sortBy);
    offset = parseInt(request.params.offset);
    limit = parseInt(request.params.limit);
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
        var result;
        result = {
          count: products.length,
          products: products
        };
        return response.success(products);
      };
    })(this));
    return queryFindPromise.fail((function(_this) {
      return function(error) {
        return response.error(error.message);
      };
    })(this));
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
    verificationCode = obj.get('verificationCode');
    return Parse.Cloud.httpRequest({
      url: 'https://rest.nexmo.com/sms/json',
      params: {
        api_key: '343ea2a4',
        api_secret: 'a682ae14',
        from: 'ShopOye',
        to: "91" + phone,
        text: "Welcome to ShopOye. Your one time verification code is " + verificationCode
      }
    }).then(function(httpResponse) {
      return console.log("SMS Sent: " + phone);
    }, function(httpResponse) {
      return console.log("SMS Error");
    });
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
