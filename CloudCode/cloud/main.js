(function() {
  var _, getAreaBoundSellers, getCategoryBasedSellers, getFilteredRequests, treeify;

  Parse.Cloud.define('getAttribValueMapping', function(request, response) {
    var AttributeValues, Attributes, Category, categoryId, categoryQuery, filterableAttributes, findCategoryPromise, secondaryAttributes;
    categoryId = request.params.categoryId;
    filterableAttributes = request.params.filterableAttributes;
    secondaryAttributes = request.params.secondaryAttributes;
    Category = Parse.Object.extend('Category');
    Attributes = Parse.Object.extend('Attributes');
    AttributeValues = Parse.Object.extend('AttributeValues');
    categoryQuery = new Parse.Query("Category");
    categoryQuery.equalTo("objectId", categoryId);
    if (filterableAttributes) {
      categoryQuery.include("filterable_attributes");
    }
    if (secondaryAttributes) {
      categoryQuery.include("secondary_attributes");
    }
    findCategoryPromise = categoryQuery.first();
    return findCategoryPromise.done((function(_this) {
      return function(categoryData) {
        var filterable_attributes, findQs;
        filterable_attributes = [];
        if (filterableAttributes) {
          filterable_attributes = categoryData.get('filterable_attributes');
        }
        if (secondaryAttributes) {
          filterable_attributes = _.union(filterable_attributes, categoryData.get('secondary_attributes'));
        }
        findQs = [];
        findQs = _.map(filterable_attributes, function(attribute) {
          var attributeId, attributeValues, innerQuery, query;
          attributeId = attribute.id;
          attributeValues = [];
          innerQuery = new Parse.Query("Attributes");
          innerQuery.equalTo("objectId", attributeId);
          query = new Parse.Query("AttributeValues");
          query.matchesQuery("attribute", innerQuery);
          query.include("attribute");
          return query.find();
        });
        return Parse.Promise.when(findQs).then(function() {
          var finalArr, individualFindResults;
          individualFindResults = _.flatten(_.toArray(arguments));
          finalArr = [];
          _.each(individualFindResults, function(individualResult) {
            var object;
            object = {
              "attributeId": individualResult.get("attribute").id,
              "attributeName": individualResult.get("attribute").get("name"),
              "group": individualResult.get("attribute").get("group"),
              "displayType": individualResult.get("attribute").get("displayType"),
              "valueId": individualResult.id,
              "value": individualResult.get("value")
            };
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

  Parse.Cloud.define('getCategoryBasedBrands', function(request, response) {
    var categoryId, queryCategory;
    categoryId = request.params.categoryId;
    queryCategory = new Parse.Query("Category");
    queryCategory.equalTo("objectId", categoryId);
    queryCategory.include("supported_brands");
    queryCategory.select("supported_brands");
    return queryCategory.first().then(function(category) {
      return response.success(category);
    }, function(error) {
      return response.error("Error - " + error.message);
    });
  });

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

  Parse.Cloud.job('processNotifications', function(request, response) {
    var notificationQuery;
    notificationQuery = new Parse.Query("Notification");
    notificationQuery.equalTo("processed", false);
    notificationQuery.include("recipientUser");
    return notificationQuery.find().then(function(pendingNotifications) {
      _.each(pendingNotifications, function(pendingNotification) {
        var channel;
        channel = pendingNotification.get("channel");
        console.log(pendingNotification);
        switch (channel) {
          case 'push':
            return console.log("push notifications");
          case 'sms':
            return console.log("send sms");
        }
      });
      return response.success("Processed pending notifications");
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.job('productImport', function(request, response) {
    var ProductItem, productSavedArr, products;
    ProductItem = Parse.Object.extend('ProductItem');
    productSavedArr = [];
    products = request.params.products;
    _.each(products, function(product) {
      var attributeValueArr, attributes, brandObj, categoryObj, primaryAttributeValueArr, primaryAttributes, productItem;
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
      primaryAttributeValueArr = [];
      primaryAttributes = product.primaryAttributes;
      _.each(primaryAttributes, function(primaryAttributeId) {
        var attribObj;
        attribObj = {
          "__type": "Pointer",
          "className": "AttributeValues",
          "objectId": primaryAttributeId
        };
        return primaryAttributeValueArr.push(attribObj);
      });
      productItem.set("primaryAttributes", primaryAttributeValueArr);
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
    filterableAttribQuery.select("supported_brands");
    filterableAttribQuery.select("price_range");
    filterableAttribQuery.include("filterable_attributes");
    filterableAttribQuery.include("supported_brands");
    findFilterableAttrib = filterableAttribQuery.first();
    findFilterableAttrib.done((function(_this) {
      return function(categoryData) {
        var AttributeValues, ProductItem, brand, endPrice, filterableProps, filters, innerBrandQuery, innerQuery, otherFilters, price, price_range, query, queryFindPromise, startPrice, supported_brands;
        filters = categoryData.get("filterable_attributes");
        supported_brands = categoryData.get("supported_brands");
        price_range = categoryData.get("price_range");
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
          if (_.contains(filterableProps, "other_filters")) {
            AttributeValues = Parse.Object.extend('AttributeValues');
            otherFilters = selectedFilters['other_filters'];
            _.each(otherFilters, function(sameAttribFilters) {
              var attribValuePointers;
              AttributeValues = Parse.Object.extend("AttributeValues");
              attribValuePointers = [];
              attribValuePointers = _.map(sameAttribFilters, function(attribValueId) {
                var AttributeValuePointer;
                AttributeValuePointer = new AttributeValues();
                AttributeValuePointer.id = attribValueId;
                return AttributeValuePointer;
              });
              return query.containedIn('attrs', attribValuePointers);
            });
          }
        }
        query.select("images,name,mrp,brand,primaryAttributes");
        query.include("brand");
        query.include("primaryAttributes");
        query.include("primaryAttributes.attribute");
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
            supportedBrands: supported_brands,
            priceRange: price_range,
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
    queryProductItem.include("brand");
    queryProductItem.include("attrs.attribute");
    queryProductItem.include("category");
    return queryProductItem.first().then(function(ProductData) {
      return response.success(ProductData);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('makeRequest', function(request, response) {
    var Request, address, area, brandId, brandObj, categoryId, categoryObj, city, comments, customerId, customerObj, deliveryStatus, location, point, productId, productObj, status;
    customerId = request.params.customerId;
    productId = request.params.productId;
    categoryId = request.params.categoryId;
    brandId = request.params.brandId;
    location = request.params.location;
    address = request.params.address;
    city = request.params.city;
    area = request.params.area;
    comments = request.params.comments;
    status = request.params.status;
    deliveryStatus = request.params.deliveryStatus;
    Request = Parse.Object.extend('Request');
    request = new Request();
    point = new Parse.GeoPoint(location);
    request.set("addressGeoPoint", point);
    request.set("address", address);
    request.set("status", status);
    request.set("deliveryStatus", deliveryStatus);
    request.set("city", city);
    request.set("area", area);
    customerObj = {
      "__type": "Pointer",
      "className": "_User",
      "objectId": customerId
    };
    request.set("customerId", customerObj);
    productObj = {
      "__type": "Pointer",
      "className": "ProductItem",
      "objectId": productId
    };
    request.set("productId", productObj);
    categoryObj = {
      "__type": "Pointer",
      "className": "Category",
      "objectId": categoryId
    };
    request.set("category", categoryObj);
    brandObj = {
      "__type": "Pointer",
      "className": "Brand",
      "objectId": brandId
    };
    request.set("brand", brandObj);
    return request.save().then(function(requestObject) {
      var createdRequestId, sellersArray;
      createdRequestId = requestObject.id;
      city = requestObject.get("city");
      area = requestObject.get("area");
      sellersArray = [];
      return getCategoryBasedSellers(point, categoryId, brandId, city, area).then(function(categoryBasedSellers) {
        var findQs;
        findQs = [];
        findQs = _.map(categoryBasedSellers, function(catBasedSeller) {
          var sellerGeoPoint, sellerId, sellerRadius;
          sellerId = catBasedSeller.id;
          sellerGeoPoint = catBasedSeller.get("addressGeoPoint");
          sellerRadius = catBasedSeller.get("deliveryRadius");
          return getAreaBoundSellers(sellerId, sellerGeoPoint, sellerRadius, createdRequestId, customerObj);
        });
        return Parse.Promise.when(findQs).then(function() {
          var locationBasedSellerIds, notificationSavedArr;
          locationBasedSellerIds = _.flatten(_.toArray(arguments));
          notificationSavedArr = [];
          _.each(locationBasedSellerIds, function(locationBasedSellerId) {
            var Notification, notification, notificationData, sellerObj;
            if (locationBasedSellerId) {
              sellerObj = {
                "__type": "Pointer",
                "className": "_User",
                "objectId": locationBasedSellerId
              };
              notificationData = {
                hasSeen: false,
                recipientUser: customerObj,
                channel: 'push',
                processed: false,
                type: "Request",
                typeId: requestObject.id
              };
              Notification = Parse.Object.extend("Notification");
              notification = new Notification(notificationData);
              return notificationSavedArr.push(notification);
            }
          });
          return Parse.Object.saveAll(notificationSavedArr).then(function(objs) {
            return response.success(objs);
          }, function(error) {
            return response.error(error);
          });
        }, function(error) {
          return response.error(error);
        });
      }, function(error) {
        return response.error(error);
      });
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('getNewRequests', function(request, response) {
    var city, currentTimeStamp, sellerId, sellerLocation, sellerQuery, sellerRadius, status;
    sellerId = request.params.sellerId;
    city = request.params.city;
    sellerLocation = request.params.sellerLocation;
    sellerRadius = request.params.sellerRadius;
    currentTimeStamp = request.params.currentTimeStamp;
    status = "open";
    sellerQuery = new Parse.Query(Parse.User);
    sellerQuery.equalTo("objectId", sellerId);
    sellerQuery.include("supportedCategories");
    sellerQuery.include("supportedBrands");
    return sellerQuery.first().then(function(sellerObject) {
      var requestQuery, sellerBrands, sellerCategories;
      sellerCategories = sellerObject.get("supportedCategories");
      sellerBrands = sellerObject.get("supportedBrands");
      requestQuery = new Parse.Query("Request");
      requestQuery.containedIn("category", sellerCategories);
      requestQuery.containedIn("brand", sellerBrands);
      return requestQuery.find().then(function(requests) {
        return response.success(requests);
      }, function(error) {
        return response.error(error);
      });
    }, function(error) {
      return response.error(error);
    });
  });

  getFilteredRequests = function(filters, className) {
    var filterKeys, query;
    query = new Parse.Query(className);
    filterKeys = _.allKeys(filters);
    _.each(filterKeys, function(filterKey) {
      return query.equalTo(filterKey, filters[filterKey]);
    });
    return query.find();
  };

  getCategoryBasedSellers = function(geoPoint, categoryId, brandId, city, area) {
    var Brand, Category, brandPointer, categoryPointer, promise, sellerQuery;
    sellerQuery = new Parse.Query(Parse.User);
    Category = Parse.Object.extend("Category");
    categoryPointer = new Category();
    categoryPointer.id = categoryId;
    Brand = Parse.Object.extend("Brand");
    brandPointer = new Brand();
    brandPointer.id = brandId;
    sellerQuery.equalTo("userType", "seller");
    sellerQuery.equalTo("city", city);
    sellerQuery.equalTo("area", area);
    sellerQuery.equalTo("supportedCategories", categoryPointer);
    sellerQuery.equalTo("supportedBrands", brandPointer);
    promise = new Parse.Promise();
    sellerQuery.find().then(function(sellers) {
      if (sellers.length === 0) {
        return promise.resolve();
      } else {
        return promise.resolve(sellers);
      }
    }, function(error) {
      return promise.reject(error);
    });
    return promise;
  };

  getAreaBoundSellers = function(sellerId, sellerGeoPoint, sellerRadius, createdRequestId, customerObj) {
    var promise, requestQuery;
    requestQuery = new Parse.Query("Request");
    requestQuery.equalTo("objectId", createdRequestId);
    requestQuery.equalTo("customerId", customerObj);
    requestQuery.equalTo("status", "open");
    requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius);
    promise = new Parse.Promise();
    requestQuery.find().then(function(requests) {
      if (requests.length === 0) {
        return promise.resolve();
      } else {
        return promise.resolve(sellerId);
      }
    }, function(error) {
      return promise.reject(error);
    });
    return promise;
  };

  Parse.Cloud.define('createTestSeller', function(request, response) {
    var addressGeoPoint, supportedBrands, supportedBrandsArr, supportedCategories, supportedCategoriesArr, user, userData;
    addressGeoPoint = new Parse.GeoPoint(request.params.addressLocation);
    userData = {
      'username': request.params.username,
      'password': request.params.password,
      'email': request.params.email,
      'addressGeoPoint': addressGeoPoint,
      'address': request.params.address,
      'city': request.params.city,
      'deliveryRadius': request.params.deliveryRadius
    };
    supportedCategoriesArr = [];
    supportedCategories = request.params.supportedCategories;
    _.each(supportedCategories, function(catId) {
      var catObj;
      catObj = {
        "__type": "Pointer",
        "className": "Category",
        "objectId": catId
      };
      return supportedCategoriesArr.push(catObj);
    });
    userData["supportedCategories"] = supportedCategoriesArr;
    supportedBrandsArr = [];
    supportedBrands = request.params.supportedBrands;
    _.each(supportedBrands, function(brandId) {
      var brandObj;
      brandObj = {
        "__type": "Pointer",
        "className": "Brand",
        "objectId": brandId
      };
      return supportedBrandsArr.push(brandObj);
    });
    userData["supportedBrands"] = supportedBrandsArr;
    userData["userType"] = "seller";
    user = new Parse.User(userData);
    return user.signUp().done((function(_this) {
      return function(user) {
        return response.success(user);
      };
    })(this)).fail((function(_this) {
      return function(error) {
        return response.error("Failed to create user " + error.message);
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
        api_key: 'e2f79907',
        api_secret: '88907392',
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
