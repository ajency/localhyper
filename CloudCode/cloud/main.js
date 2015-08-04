(function() {
  var _, findAttribValues, getAreaBoundSellers, getCategoryBasedSellers, getNotificationData, getRequestData, moment, processPushNotifications, setPrimaryAttribute, treeify;

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
      categoryQuery.include("filterable_attributes.filterAttribute");
    }
    if (secondaryAttributes) {
      categoryQuery.include("secondary_attributes");
    }
    findCategoryPromise = categoryQuery.first();
    return findCategoryPromise.done((function(_this) {
      return function(categoryData) {
        var f_attributes, filterable_attributes, final_attributes, findQs, secondary_attributes;
        final_attributes = [];
        if (filterableAttributes) {
          filterable_attributes = categoryData.get('filterable_attributes');
          if (filterable_attributes) {
            if (filterable_attributes.length > 0) {
              f_attributes = [];
              f_attributes = _.map(filterable_attributes, function(filterObj) {
                return filterObj.get("filterAttribute");
              });
              final_attributes = f_attributes;
            }
          }
        }
        if (secondaryAttributes) {
          secondary_attributes = categoryData.get('secondary_attributes');
          if (secondary_attributes) {
            if (secondary_attributes.length > 0) {
              final_attributes = _.union(f_attributes, secondary_attributes);
            }
          }
        }
        findQs = [];
        findQs = _.map(final_attributes, function(attribute) {
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
          var attributes, finalArr, individualFindResults, result;
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
          attributes = _.map(final_attributes, function(attribute) {
            return attribute = {
              "id": attribute.id,
              "name": attribute.get("name"),
              "type": attribute.get("type")
            };
          });
          result = {
            attributes: attributes,
            attributeValues: finalArr
          };
          return response.success(result);
        }, function(error) {
          return response.error(error);
        });
      };
    })(this));
  });

  Parse.Cloud.define('attributeImport', function(request, response) {
    var Attributes, attributeSavedArr, attributes, categoryId, isFilterable, primaryAttributeObj, primaryAttributeSavedArr;
    Attributes = Parse.Object.extend('Attributes');
    attributeSavedArr = [];
    attributes = request.params.attributes;
    categoryId = request.params.categoryId;
    isFilterable = request.params.isFilterable;
    primaryAttributeObj = request.params.primaryAttributeObj;
    _.each(attributes, function(attributeObj) {
      var attribute;
      if (!_.isNull(attributeObj.name)) {
        attribute = new Attributes();
        if (!_.isNull(attributeObj.objectId)) {
          attribute.id = attributeObj.objectId;
        }
        attribute.set("name", attributeObj.name);
        attribute.set("group", attributeObj.group);
        if (!_.isNull(attributeObj.unit)) {
          attribute.set("unit", attributeObj.unit);
        }
        if (attributeObj.hasOwnProperty("display_type")) {
          attribute.set("display_type", attributeObj.display_type);
        } else {
          attribute.set("display_type", "checkbox");
        }
        if (attributeObj.hasOwnProperty("type")) {
          attribute.set("type", attributeObj.type);
        } else {
          attribute.set("type", "select");
        }
        return attributeSavedArr.push(attribute);
      }
    });
    primaryAttributeSavedArr = [];
    return setPrimaryAttribute(primaryAttributeObj).then(function(primaryobj) {
      return Parse.Object.saveAll(attributeSavedArr).then(function(objs) {
        var Category, ProductFilters, category, queryProdFilters;
        if (!(_.isEmpty(primaryobj))) {
          objs.push(primaryobj);
        }
        Category = Parse.Object.extend('Category');
        category = new Category();
        category.id = categoryId;
        ProductFilters = Parse.Object.extend('ProductFilters');
        if (isFilterable === true) {
          queryProdFilters = new Parse.Query('ProductFilters');
          queryProdFilters.equalTo("categoryId", categoryId);
          return queryProdFilters.find().then(function(oldCategoryFilters) {
            return Parse.Object.destroyAll(oldCategoryFilters).then(function(destroyedObjs) {
              var filterColumn, filterableAttribArr;
              filterColumn = 1;
              filterableAttribArr = [];
              _.each(objs, function(obj) {
                var productFilters;
                productFilters = new ProductFilters();
                productFilters.set("categoryId", categoryId);
                productFilters.set("filterColumn", filterColumn);
                productFilters.set("filterAttribute", obj);
                filterColumn++;
                return filterableAttribArr.push(productFilters);
              });
              return Parse.Object.saveAll(filterableAttribArr).then(function(savedFilters) {
                category.set("filterable_attributes", savedFilters);
                if (!(_.isEmpty(primaryobj))) {
                  primaryAttributeSavedArr.push(primaryobj);
                  category.set("primary_attributes", primaryAttributeSavedArr);
                }
                return category.save().then(function(categoryObj) {
                  var successObj;
                  successObj = {
                    success: true,
                    message: "Successfully added/updated the attributes (with primary)"
                  };
                  return response.success(successObj);
                }, function(error) {
                  return response.error(error);
                });
              }, function(error) {
                return response.error(error);
              });
            }, function(error) {
              return response.error("1. error due to " + error);
            });
          }, function(error) {
            return response.error(error);
          });
        } else {
          category.set("secondary_attributes", objs);
          if (!(_.isEmpty(primaryobj))) {
            primaryAttributeSavedArr.push(primaryobj);
            category.set("primary_attributes", primaryAttributeSavedArr);
          }
          return category.save().then(function(categoryObj) {
            var successObj;
            successObj = {
              success: true,
              message: "Successfully added/updated the attributes (with primary)"
            };
            return response.success(successObj);
          }, function(error) {
            return response.error(error);
          });
        }
      }, function(error) {
        return response.error("Failed to add/update attributes due to - " + error.message);
      });
    }, function(error) {
      return response.error("Failed to save/update primary attribute due to - " + error.message);
    });
  });

  Parse.Cloud.define('attributeValueImport', function(request, response) {
    var AttributeValues, attributeValSavedArr, attributeValues, categoryId;
    AttributeValues = Parse.Object.extend('AttributeValues');
    attributeValSavedArr = [];
    attributeValues = request.params.attributeValues;
    categoryId = request.params.categoryId;
    _.each(attributeValues, function(attributeValObj) {
      var attributePointer, attributeValue, value;
      if ((!_.isNull(attributeValObj.attributeId)) && (!_.isNull(attributeValObj.value))) {
        attributeValue = new AttributeValues();
        if (!_.isNull(attributeValObj.objectId)) {
          attributeValue.id = attributeValObj.objectId;
        }
        value = String(attributeValObj.value);
        attributeValue.set("value", value);
        attributePointer = {
          "__type": "Pointer",
          "className": "Attributes",
          "objectId": attributeValObj.attributeId
        };
        attributeValue.set("attribute", attributePointer);
        return attributeValSavedArr.push(attributeValue);
      }
    });
    return Parse.Object.saveAll(attributeValSavedArr, {
      success: function(objs) {
        var successObj;
        successObj = {
          success: true,
          message: "Successfully added/updated the attribute valuess"
        };
        return response.success(successObj);
      },
      error: function(error) {
        return response.error("Failed to add/update attributes due to - " + error.message);
      }
    });
  });

  setPrimaryAttribute = function(primaryAttributeObj) {
    var Attributes, pAttrib, promise;
    Attributes = Parse.Object.extend('Attributes');
    promise = new Parse.Promise();
    if (_.isEmpty(primaryAttributeObj) || _.isNull(primaryAttributeObj.name)) {
      primaryAttributeObj = {};
      promise.resolve(primaryAttributeObj);
    } else {
      pAttrib = new Attributes();
      if (!_.isNull(primaryAttributeObj.objectId)) {
        pAttrib.id = primaryAttributeObj.objectId;
      }
      pAttrib.set("name", primaryAttributeObj.name);
      pAttrib.set("group", primaryAttributeObj.group);
      if (primaryAttributeObj.unit !== "") {
        pAttrib.set("unit", primaryAttributeObj.unit);
      }
      if (primaryAttributeObj.hasOwnProperty("display_type")) {
        pAttrib.set("display_type", primaryAttributeObj.display_type);
      } else {
        pAttrib.set("display_type", "checkbox");
      }
      if (primaryAttributeObj.hasOwnProperty("type")) {
        pAttrib.set("type", primaryAttributeObj.type);
      } else {
        pAttrib.set("type", "select");
      }
      pAttrib.save().then(function(savedPrimaryObj) {
        return promise.resolve(savedPrimaryObj);
      }, function(error) {
        return promise.reject(error);
      });
    }
    return promise;
  };

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

  Parse.Cloud.define('brandImport', function(request, response) {
    var Brand, brands, brandsSavedArr, categoryId;
    Brand = Parse.Object.extend('Brand');
    brandsSavedArr = [];
    brands = request.params.brands;
    categoryId = request.params.categoryId;
    _.each(brands, function(brandObj) {
      var brand, image;
      if (!_.isNull(brandObj.name)) {
        brand = new Brand();
        if (!_.isNull(brandObj.objectId)) {
          brand.id = brandObj.objectId;
        }
        brand.set("name", brandObj.name);
        if (!_.isNull(brandObj.imageUrl)) {
          image = {
            "src": brandObj.imageUrl
          };
        } else {
          image = {
            "src": "https://placehold.it/350x150?text=Brand"
          };
        }
        brand.set("image", image);
        return brandsSavedArr.push(brand);
      }
    });
    return Parse.Object.saveAll(brandsSavedArr, {
      success: function(objs) {
        var Category, category;
        Category = Parse.Object.extend('Category');
        category = new Category();
        category.id = categoryId;
        category.set("supported_brands", objs);
        return category.save().then(function(categoryObj) {
          var successObj;
          successObj = {
            success: true,
            message: "Successfully added/updated the brands"
          };
          return response.success(successObj);
        }, function(error) {
          return response.error(error);
        });
      },
      error: function(error) {
        return response.error(error);
      }
    });
  });

  _ = require('underscore.js');

  moment = require('moment');

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

  Parse.Cloud.define("sendMail", function(request, status) {
    var Mandrill, brand, category, comments, description, productName, text;
    productName = request.params.productName;
    category = request.params.category;
    brand = request.params.brand;
    description = request.params.description;
    comments = request.params.comments;
    text = '<p>Product Name:' + productName + '<br> Category:' + category + '<br> Brand: ' + brand + '<br> Categories: ' + description + '<br> Comments:' + comments + '<p>';
    Mandrill = require('mandrill');
    Mandrill.initialize('JGQ1FMECVDSJLnOFvxDzaQ');
    return Mandrill.sendEmail({
      message: {
        html: "<p>" + text + "</p>",
        text: text,
        subject: "Product suggestions",
        from_email: "parse@cloudcode.com",
        from_name: "Cloud Code",
        to: [
          {
            email: "namrata@ajency.in",
            name: "Your Name"
          }
        ]
      },
      async: true
    }, {
      success: function(httpResponse) {
        console.log(httpResponse);
        return status.success('Mail Sent');
      },
      error: function(httpResponse) {
        console.error(httpResponse);
        return status.error('err');
      }
    });
  });

  getNotificationData = function(notificationId, installationId, pushOptions) {
    var installationQuery, promise;
    promise = new Parse.Promise();
    installationQuery = new Parse.Query(Parse.Installation);
    installationQuery.equalTo("installationId", installationId);
    installationQuery.find().then(function(installationObject) {
      var deviceType, notificationObj, pushData;
      if (_.isEmpty(installationObject)) {
        deviceType = 'unknown';
      } else {
        deviceType = installationObject[0].get('deviceType');
      }
      if (deviceType.toLowerCase() === 'android') {
        pushData = {
          header: pushOptions.title,
          message: pushOptions.alert,
          data: pushOptions.notificationData
        };
      } else {
        pushData = {
          title: pushOptions.title,
          alert: pushOptions.alert,
          data: pushOptions.notificationData,
          badge: 'Increment'
        };
      }
      notificationObj = {
        pushData: pushData,
        installationId: installationId,
        notificationId: notificationId
      };
      return promise.resolve(notificationObj);
    }, function(error) {
      return promise.reject(error);
    });
    return promise;
  };

  processPushNotifications = function(installationId, pushData, notificationId) {
    var promise, pushQuery;
    promise = new Parse.Promise();
    pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("installationId", installationId);
    Parse.Push.send({
      where: pushQuery,
      data: pushData
    }).then(function() {
      var Notification, query;
      Notification = Parse.Object.extend('Notification');
      query = new Parse.Query(Notification);
      query.equalTo("objectId", notificationId);
      return query.first().then(function(notification) {
        notification.set("processed", true);
        return notification.save().then(function(notifobj) {
          return promise.resolve(notifobj);
        }, function(error) {
          return promise.reject(error);
        });
      }, function(error) {
        return promise.reject(error);
      });
    }, function(error) {
      return promise.reject(error);
    });
    return promise;
  };

  Parse.Cloud.job('processNotifications', function(request, response) {
    var notificationQuery;
    notificationQuery = new Parse.Query("Notification");
    notificationQuery.equalTo("processed", false);
    notificationQuery.include("recipientUser");
    notificationQuery.include("requestObject");
    notificationQuery.include("requestObject.product");
    notificationQuery.include("offerObject");
    notificationQuery.include("offerObject.request");
    notificationQuery.include("offerObject.request.product");
    return notificationQuery.find().then(function(pendingNotifications) {
      var customerAppName, notificationQs, sellerAppName;
      notificationQs = [];
      sellerAppName = "ShopOye Seller";
      customerAppName = "ShopOye Customer";
      _.each(pendingNotifications, function(pendingNotification) {
        var channel, msg, notificationId, notificationPromise, obj, otherPushData, productName, pushOptions, recipientUser, title, type, userInstallationId;
        channel = pendingNotification.get("channel");
        recipientUser = pendingNotification.get("recipientUser");
        notificationId = pendingNotification.id;
        userInstallationId = recipientUser.get("installationId");
        type = pendingNotification.get("type");
        if (type === "Request") {
          obj = pendingNotification.get("requestObject");
          productName = pendingNotification.get("requestObject").get("product").get("name");
          title = sellerAppName;
          msg = "You have received a request for " + productName;
          otherPushData = {
            "id": obj.id,
            "type": "new_request"
          };
        } else if (type === "Offer") {
          obj = pendingNotification.get("offerObject");
          productName = pendingNotification.get("offerObject").get("request").get("product").get("name");
          title = customerAppName;
          msg = "You have received an offer for " + productName;
          otherPushData = {
            "id": obj.id,
            "type": "new_offer"
          };
        } else if (type === "AcceptedOffer") {
          obj = pendingNotification.get("offerObject");
          productName = pendingNotification.get("offerObject").get("request").get("product").get("name");
          title = sellerAppName;
          msg = "Your offer for " + productName + " has been accepted";
          otherPushData = {
            "id": obj.id,
            "type": "accepted_offer"
          };
        } else if (type === "CancelledRequest") {
          obj = pendingNotification.get("requestObject");
          productName = pendingNotification.get("requestObject").get("product").get("name");
          title = sellerAppName;
          msg = "Request for " + productName + " has been cancelled";
          otherPushData = {
            "id": obj.id,
            "type": "cancelled_request"
          };
        }
        switch (channel) {
          case 'push':
            pushOptions = {
              title: title,
              alert: msg,
              notificationData: otherPushData
            };
            notificationPromise = getNotificationData(notificationId, userInstallationId, pushOptions);
            return notificationQs.push(notificationPromise);
          case 'sms':
            return console.log("send sms");
        }
      });
      return Parse.Promise.when(notificationQs).then(function() {
        var individualPushResults, pushQs;
        individualPushResults = _.flatten(_.toArray(arguments));
        pushQs = [];
        _.each(individualPushResults, function(pushResult) {
          var installationId, notificationId, pushNotifPromise;
          installationId = pushResult.installationId;
          notificationId = pushResult.notificationId;
          pushNotifPromise = processPushNotifications(installationId, pushResult.pushData, notificationId);
          return pushQs.push(pushNotifPromise);
        });
        return Parse.Promise.when(pushQs).then(function() {
          return response.success("Processed");
        }, function(error) {
          return response.error(error);
        });
      }, function(error) {
        return response.error("Error");
      });
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('getUnseenNotifications', function(request, response) {
    var innerQueryUser, notificationQuery, type, userId;
    userId = request.params.userId;
    type = request.params.type;
    notificationQuery = new Parse.Query("Notification");
    notificationQuery.equalTo("hasSeen", false);
    innerQueryUser = new Parse.Query(Parse.User);
    innerQueryUser.equalTo("objectId", userId);
    notificationQuery.matchesQuery("recipientUser", innerQueryUser);
    notificationQuery.equalTo("type", type);
    notificationQuery.select("requestObject");
    notificationQuery.select("offerObject");
    return notificationQuery.find().then(function(notificationResults) {
      var unseenNotifications;
      if (type === "Request") {
        unseenNotifications = _.map(notificationResults, function(notificationObj) {
          var requestId;
          return requestId = notificationObj.get("requestObject").id;
        });
      } else if (type === "Offer") {
        unseenNotifications = _.map(notificationResults, function(notificationObj) {
          var requestId;
          return requestId = notificationObj.get("offerObject").id;
        });
      }
      return response.success(unseenNotifications);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('updateNotificationStatus', function(request, response) {
    var hasSeen, innerQuery, notificationQuery, notificationType, notificationTypeId, recipientId, recipientUserObj;
    notificationType = request.params.notificationType;
    notificationTypeId = request.params.notificationTypeId;
    recipientId = request.params.recipientId;
    hasSeen = request.params.hasSeen;
    notificationQuery = new Parse.Query("Notification");
    notificationQuery.equalTo("type", notificationType);
    recipientUserObj = {
      "__type": "Pointer",
      "className": "_User",
      "objectId": recipientId
    };
    notificationQuery.equalTo("recipientUser", recipientUserObj);
    if (notificationType === "Request") {
      innerQuery = new Parse.Query("Request");
      innerQuery.equalTo("objectId", notificationTypeId);
      notificationQuery.matchesQuery("requestObject", innerQuery);
    } else if (notificationType === "Offer") {
      innerQuery = new Parse.Query("Offer");
      if (_.isArray(notificationTypeId)) {
        innerQuery.containedIn("objectId", notificationTypeId);
      } else if (_.isString(notificationTypeId)) {
        innerQuery.equalTo("objectId", notificationTypeId);
      }
      notificationQuery.matchesQuery("offerObject", innerQuery);
    }
    return notificationQuery.find().then(function(notificationObjects) {
      var saveQs;
      saveQs = _.map(notificationObjects, function(notificationObj) {
        notificationObj.set("hasSeen", hasSeen);
        return notificationObj.save();
      });
      return Parse.Promise.when(saveQs).then(function() {
        var updatedNotifications;
        updatedNotifications = _.flatten(_.toArray(arguments));
        return response.success(updatedNotifications);
      }, function(error) {
        return response.error(error);
      });
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('getNewOffers', function(request, response) {
    var customerId, innerCustomerQuery, innerProductQuery, productId, queryReq;
    productId = request.params.productId;
    customerId = request.params.customerId;
    innerProductQuery = new Parse.Query("ProductItem");
    innerProductQuery.equalTo("objectId", productId);
    innerCustomerQuery = new Parse.Query(Parse.User);
    innerCustomerQuery.equalTo("objectId", customerId);
    queryReq = new Parse.Query("Request");
    queryReq.matchesQuery("product", innerProductQuery);
    queryReq.matchesQuery("customerId", innerCustomerQuery);
    return queryReq.first().then(function(requestObj) {
      var currentDate, currentTimeStamp, expiryValueInHrs, moreRequests, queryDate, queryRequest, result, time24HoursAgo;
      if (_.isEmpty(requestObj)) {
        moreRequests = false;
        result = {
          "activeRequest": {},
          "offers": [],
          "moreRequests": moreRequests
        };
        return response.success(result);
      } else {
        moreRequests = true;
        queryRequest = new Parse.Query("Request");
        queryRequest.matchesQuery("product", innerProductQuery);
        queryRequest.matchesQuery("customerId", innerCustomerQuery);
        currentDate = new Date();
        currentTimeStamp = currentDate.getTime();
        expiryValueInHrs = 24;
        queryDate = new Date();
        time24HoursAgo = currentTimeStamp - (expiryValueInHrs * 60 * 60 * 1000);
        queryDate.setTime(time24HoursAgo);
        queryRequest.greaterThanOrEqualTo("createdAt", queryDate);
        queryRequest.descending("createdAt");
        return queryRequest.find().then(function(allNonExpiredRequests) {
          var innerRequestQuery, mostRecentRequest, queryOffer, recentRequestStatus;
          if (allNonExpiredRequests.length === 0) {
            result = {
              "activeRequest": {},
              "offers": [],
              "moreRequests": moreRequests
            };
            return response.success(result);
          } else {
            mostRecentRequest = allNonExpiredRequests[0];
            recentRequestStatus = mostRecentRequest.get("status");
            if (recentRequestStatus === "open") {
              queryOffer = new Parse.Query("Offer");
              innerRequestQuery = new Parse.Query("Request");
              innerRequestQuery.equalTo("objectId", mostRecentRequest.id);
              queryOffer.matchesQuery("request", innerRequestQuery);
              queryOffer.equalTo("status", "open");
              return queryOffer.find().then(function(offers) {
                result = {
                  "activeRequest": mostRecentRequest,
                  "offers": offers,
                  "moreRequests": moreRequests
                };
                return response.success(result);
              }, function(error) {
                return response.error(error);
              });
            } else {
              result = {
                "activeRequest": {},
                "offers": [],
                "moreRequests": moreRequests
              };
              return response.success(result);
            }
          }
        }, function(error) {
          return response.error(error);
        });
      }
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('makeOffer', function(request, response) {
    var Notification, Offer, Price, Request, comments, deliveryTime, priceValue, requestId, requestQuery, sellerId, status;
    requestId = request.params.requestId;
    sellerId = request.params.sellerId;
    priceValue = parseInt(request.params.priceValue);
    deliveryTime = request.params.deliveryTime;
    comments = request.params.comments;
    status = request.params.status;
    Price = Parse.Object.extend("Price");
    Offer = Parse.Object.extend("Offer");
    Request = Parse.Object.extend("Request");
    Notification = Parse.Object.extend("Notification");
    requestQuery = new Parse.Query("Request");
    requestQuery.equalTo("objectId", requestId);
    return requestQuery.first().then(function(requestObj) {
      var price, product, requestingCustomer, sellerObj;
      requestingCustomer = requestObj.get("customerId");
      price = new Price();
      price.set("source", "seller");
      sellerObj = new Parse.User();
      sellerObj.id = sellerId;
      price.set("seller", sellerObj);
      price.set("type", "open_offer");
      price.set("value", priceValue);
      product = requestObj.get("product");
      price.set("product", product);
      return price.save().then(function(priceObj) {
        var offer;
        offer = new Offer();
        requestObj = new Request();
        requestObj.id = requestId;
        offer.set("seller", sellerObj);
        offer.set("request", requestObj);
        offer.set("price", priceObj);
        offer.set("status", status);
        offer.set("deliveryTime", deliveryTime);
        offer.set("comments", comments);
        return offer.save().then(function(offerObj) {
          var notification;
          notification = new Notification();
          notification.set("hasSeen", false);
          notification.set("recipientUser", requestingCustomer);
          notification.set("channel", "push");
          notification.set("processed", false);
          notification.set("type", "Offer");
          notification.set("offerObject", offerObj);
          return notification.save().then(function(notificationObj) {
            return response.success(notificationObj);
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

  Parse.Cloud.define('getSellerOffers', function(request, response) {
    var acceptedOffers, allowedStatuses, descending, displayLimit, innerSellerQuery, page, queryOffers, selectedFilters, sellerId, sortBy;
    sellerId = request.params.sellerId;
    page = parseInt(request.params.page);
    displayLimit = parseInt(request.params.displayLimit);
    acceptedOffers = request.params.acceptedOffers;
    selectedFilters = request.params.selectedFilters;
    sortBy = request.params.sortBy;
    descending = request.params.descending;
    innerSellerQuery = new Parse.Query(Parse.User);
    innerSellerQuery.equalTo("objectId", sellerId);
    queryOffers = new Parse.Query("Offer");
    queryOffers.matchesQuery("seller", innerSellerQuery);
    if (acceptedOffers === true) {
      allowedStatuses = ["accepted"];
    } else {
      if (selectedFilters.length === 0) {
        allowedStatuses = ["open", "unaccepted"];
      } else {
        allowedStatuses = _.without(selectedFilters, "expired");
      }
    }
    queryOffers.containedIn("status", allowedStatuses);
    queryOffers.limit(displayLimit);
    queryOffers.skip(page * displayLimit);
    if (descending === true) {
      queryOffers.descending("updatedAt");
    } else {
      queryOffers.ascending("updatedAt");
    }
    queryOffers.include("price");
    queryOffers.include("request");
    queryOffers.include("seller");
    queryOffers.include("price");
    queryOffers.include("request.product");
    queryOffers.include("request.brand");
    queryOffers.include("request.category");
    queryOffers.include("request.category.parent_category");
    return queryOffers.find().then(function(offers) {
      var sellerOffers;
      sellerOffers = [];
      _.each(offers, function(offerObj) {
        var brand, brandObj, category, categoryObj, createdDate, currentDate, diff, differenceInDays, priceObj, product, productObj, requestGeoPoint, requestObj, requestStatus, sellerGeoPoint, sellerObj, sellerOffer, sellersDistancFromCustomer;
        requestObj = offerObj.get("request");
        productObj = requestObj.get("product");
        brandObj = requestObj.get("brand");
        categoryObj = requestObj.get("category");
        sellerObj = offerObj.get("seller");
        priceObj = offerObj.get("price");
        product = {
          "objectId": productObj.id,
          "name": productObj.get("name"),
          "mrp": productObj.get("mrp"),
          "modelNumber": productObj.get("model_number"),
          "images": productObj.get("images")
        };
        brand = {
          "objectId": brandObj.id,
          "name": brandObj.get("name")
        };
        category = {
          "objectId": categoryObj.id,
          "name": categoryObj.get("name"),
          "parentCategory": categoryObj.get("parent_category").get("name")
        };
        sellerGeoPoint = sellerObj.get("addressGeoPoint");
        requestGeoPoint = requestObj.get("addressGeoPoint");
        sellersDistancFromCustomer = requestGeoPoint.kilometersTo(sellerGeoPoint);
        currentDate = new Date();
        createdDate = requestObj.createdAt;
        diff = currentDate.getTime() - createdDate.getTime();
        differenceInDays = Math.floor(diff / (1000 * 60 * 60 * 24));
        requestStatus = requestObj.get("status");
        if (differenceInDays >= 1) {
          if (requestStatus === "open") {
            requestStatus = "expired";
          }
        }
        request = {
          "id": requestObj.id,
          "address": requestObj.get("address"),
          "status": requestStatus,
          "differenceInDays": differenceInDays,
          "offerCount": requestObj.get("offerCount"),
          "comments": requestObj.get("comments"),
          "createdAt": requestObj.createdAt
        };
        sellerOffer = {
          "id": offerObj.id,
          "product": product,
          "brand": brand,
          "category": category,
          "request": request,
          "distanceFromCustomer": sellersDistancFromCustomer,
          "offerPrice": priceObj.get("value"),
          "offerStatus": offerObj.get("status"),
          "offerDeliveryTime": offerObj.get("deliveryTime"),
          "offerComments": offerObj.get("comments"),
          "createdAt": offerObj.createdAt
        };
        return sellerOffers.push(sellerOffer);
      });
      return response.success(sellerOffers);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.afterSave("Offer", function(request) {
    var RequestClass, offerObject, queryReq, requestId;
    offerObject = request.object;
    if (!offerObject.existed()) {
      requestId = offerObject.get("request").id;
      RequestClass = Parse.Object.extend("Request");
      queryReq = new Parse.Query(RequestClass);
      return queryReq.get(requestId).then(function(requestObj) {
        requestObj.increment("offerCount");
        return requestObj.save();
      }, function(error) {
        return console.log("Got an error " + error.code + " : " + error.message);
      });
    }
  });

  Parse.Cloud.define('getRequestOffers', function(request, response) {
    var innerQueryRequest, queryOffers, requestId;
    requestId = request.params.requestId;
    queryOffers = new Parse.Query("Offer");
    innerQueryRequest = new Parse.Query("Request");
    innerQueryRequest.equalTo("objectId", requestId);
    queryOffers.matchesQuery("request", innerQueryRequest);
    queryOffers.include("price");
    queryOffers.include("request");
    queryOffers.include("request.product");
    queryOffers.include("seller");
    return queryOffers.find().then(function(offerObjects) {
      var offers;
      offers = [];
      offers = _.map(offerObjects, function(offerObject) {
        var offer, priceObj, product, productObj, seller, sellerObj;
        productObj = offerObject.get("request").get("product");
        product = {
          "name": productObj.get("name"),
          "images": productObj.get("images")
        };
        sellerObj = offerObject.get("seller");
        seller = {
          "displayName": sellerObj.get("displayName"),
          "businessName": sellerObj.get("businessName"),
          "address": sellerObj.get("address"),
          "city": sellerObj.get("city"),
          "phoneNumber": sellerObj.get("username")
        };
        priceObj = offerObject.get("price");
        offer = {
          "id": offerObject.id,
          "product": product,
          "seller": seller,
          "price": priceObj.get("value"),
          "comments": offerObject.get("comments"),
          "deliveryTime": offerObject.get("deliveryTime"),
          "status": offerObject.get("status"),
          "createdAt": offerObject.createdAt,
          "updatedAt": offerObject.updatedAt
        };
        return offer;
      });
      return response.success(offers);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('acceptOffer', function(request, response) {
    var Offer, acceptedOffer, offerId, offerSavedArr, offersToBeUpdated, unacceptedOfferIds;
    offerId = request.params.offerId;
    unacceptedOfferIds = request.params.unacceptedOfferIds;
    Offer = Parse.Object.extend('Offer');
    offersToBeUpdated = [];
    acceptedOffer = {
      "id": offerId,
      "status": "accepted"
    };
    offersToBeUpdated.push(acceptedOffer);
    if (unacceptedOfferIds.length > 0) {
      _.each(unacceptedOfferIds, function(unacceptedOfferId) {
        var unacceptedOffer;
        unacceptedOffer = {
          "id": unacceptedOfferId,
          "status": "unaccepted"
        };
        return offersToBeUpdated.push(unacceptedOffer);
      });
    }
    offerSavedArr = [];
    _.each(offersToBeUpdated, function(offerObj) {
      var offer;
      offer = new Offer();
      offer.id = offerObj.id;
      offer.set("status", offerObj.status);
      return offerSavedArr.push(offer);
    });
    return Parse.Object.saveAll(offerSavedArr).then(function(savedOfferObjs) {
      var queryOffer;
      queryOffer = new Parse.Query("Offer");
      queryOffer.equalTo("objectId", offerId);
      queryOffer.include("request");
      queryOffer.include("seller");
      return queryOffer.first().then(function(acceptedOffer) {
        var requestObj, sellerObj;
        sellerObj = acceptedOffer.get("seller");
        requestObj = acceptedOffer.get("request");
        requestObj.set("status", "pending_delivery");
        return requestObj.save().then(function(savedReq) {
          var Notification, notification, notificationData;
          notificationData = {
            hasSeen: false,
            recipientUser: sellerObj,
            channel: 'push',
            processed: false,
            type: "AcceptedOffer",
            offerObject: acceptedOffer
          };
          Notification = Parse.Object.extend("Notification");
          notification = new Notification(notificationData);
          return notification.save().then(function(notifObj) {
            var resultObj;
            resultObj = {
              offerId: acceptedOffer.id,
              offerStatus: acceptedOffer.get("status"),
              offerUpdatedAt: acceptedOffer.updatedAt,
              requestId: acceptedOffer.get("request").id,
              requestStatus: acceptedOffer.get("request").get("status")
            };
            return response.success(resultObj);
          }, function(error) {
            return response.error(error);
          });
        });
      }, function(error) {
        return response.error(error);
      });
    }, function(error) {
      return response.error("Failed to update offer status due to - " + error.message);
    });
  });

  Parse.Cloud.define('getRequestForOffer', function(request, response) {
    var offerId, queryOffer;
    offerId = request.params.offerId;
    queryOffer = new Parse.Query("Offer");
    queryOffer.equalTo("objectId", offerId);
    queryOffer.select("request");
    queryOffer.include("request");
    queryOffer.include("request.product");
    return queryOffer.first().then(function(offerObj) {
      var product, productObj, requestObj, requestResult;
      requestObj = offerObj.get("request");
      productObj = requestObj.get("product");
      product = {
        "name": productObj.get("name"),
        "images": productObj.get("images"),
        "mrp": productObj.get("mrp")
      };
      requestResult = {
        "id": requestObj.id,
        "product": product,
        "status": requestObj.get("status"),
        "address": requestObj.get("address"),
        "comments": requestObj.get("comments"),
        "createdAt": requestObj.createdAt,
        "updatedAt": requestObj.updatedAt,
        "offerCount": requestObj.get("offerCount")
      };
      return response.success(requestResult);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('isOfferNotificationSeen', function(request, response) {
    var innerQueryRequest, queryOffer, requestId, type, userId;
    userId = request.params.userId;
    requestId = request.params.requestId;
    type = "Offer";
    queryOffer = new Parse.Query("Offer");
    innerQueryRequest = new Parse.Query("Request");
    innerQueryRequest.equalTo("objectId", requestId);
    queryOffer.matchesQuery("request", innerQueryRequest);
    return queryOffer.first().then(function(offerObj) {
      var hasSeen, innerQueryOffer, innerUserQuery, offerId, queryNotification, result;
      if (_.isEmpty(offerObj)) {
        hasSeen = true;
        result = {
          "requestId": requestId,
          "offerId": "",
          "hasSeen": hasSeen
        };
        return response.success(result);
      } else {
        offerId = offerObj.id;
        queryNotification = new Parse.Query("Notification");
        queryNotification.equalTo("type", "Offer");
        innerQueryOffer = new Parse.Query("Offer");
        innerQueryOffer.equalTo("objectId", offerId);
        queryNotification.matchesQuery("offerObject", innerQueryOffer);
        innerUserQuery = new Parse.Query(Parse.User);
        innerUserQuery.equalTo("objectId", userId);
        queryNotification.matchesQuery("recipientUser", innerUserQuery);
        return queryNotification.first().then(function(notificationObj) {
          hasSeen = notificationObj.get("hasSeen");
          result = {
            "requestId": requestId,
            "offerId": offerId,
            "hasSeen": hasSeen
          };
          return response.success(result);
        }, function(error) {
          return response.error("1" + error);
        });
      }
    }, function(error) {
      return response.error("2" + error);
    });
  });

  Parse.Cloud.job('productImport', function(request, response) {
    var ProductItem, categoryId, productSavedArr, products, queryCategory;
    ProductItem = Parse.Object.extend('ProductItem');
    productSavedArr = [];
    products = request.params.products;
    categoryId = request.params.categoryId;
    queryCategory = new Parse.Query("Category");
    queryCategory.equalTo("objectId", categoryId);
    queryCategory.include("filterable_attributes");
    queryCategory.include("secondary_attributes");
    queryCategory.include("filterable_attributes.filterAttribute");
    queryCategory.include("primary_attributes");
    queryCategory.select("filterable_attributes", "primary_attributes", "secondary_attributes");
    return queryCategory.first().then(function(categoryObj) {
      var countFilterableAttrib, countSecAttrib, totalAttrCount;
      totalAttrCount = 0;
      if (!_.isUndefined(categoryObj.get("filterable_attributes"))) {
        countFilterableAttrib = categoryObj.get("filterable_attributes").length;
      }
      if (!_.isUndefined(categoryObj.get("secondary_attributes"))) {
        countSecAttrib = categoryObj.get("secondary_attributes").length;
      }
      totalAttrCount = countFilterableAttrib + countSecAttrib;
      _.each(products, function(product) {
        var attributeValueArr, brandObj, categoryPrimaryAttribute, inputImages, lengthOfAttr, lengthOfTextAttr, primaryAttribObj, primaryAttributeValueArr, primeAttrib, productAttributes, productFilters, productImgs, productItem, validAttrLength;
        lengthOfAttr = _.keys(product.attrs).length;
        lengthOfTextAttr = _.keys(product.text_attributes).length;
        validAttrLength = lengthOfAttr + lengthOfTextAttr;
        if (!_.isNull(product.name) && (validAttrLength === totalAttrCount) && !_.isNull(product.brandId)) {
          productItem = new ProductItem();
          if (!_.isNull(product.objectId)) {
            productItem.id = product.objectId;
          }
          productAttributes = product.attrs;
          productItem.set("name", product.name);
          productImgs = [];
          inputImages = product.images;
          _.each(product.images, function(productImage) {
            var prodImg;
            if (!_.isNull(productImage.src)) {
              prodImg = {
                "src": productImage.src
              };
            } else {
              prodImg = {
                "src": "https://placehold.it/350x150?text=Product"
              };
            }
            return productImgs.push(prodImg);
          });
          productItem.set("images", productImgs);
          productItem.set("model_number", String(product.model_number));
          productItem.set("mrp", parseInt(product.mrp));
          productItem.set("popularity", product.popularity);
          productItem.set("group", product.group);
          brandObj = {
            "__type": "Pointer",
            "className": "Brand",
            "objectId": product.brandId
          };
          productItem.set("brand", brandObj);
          productItem.set("category", categoryObj);
          if (!(_.isEmpty(product.text_attributes))) {
            productItem.set("textAttributes", product.text_attributes);
          }
          categoryPrimaryAttribute = categoryObj.get("primary_attributes");
          if (!_.isUndefined(categoryPrimaryAttribute)) {
            primeAttrib = _.first(categoryPrimaryAttribute);
            primaryAttributeValueArr = [];
            primaryAttribObj = {
              "__type": "Pointer",
              "className": "AttributeValues",
              "objectId": productAttributes[primeAttrib.id]
            };
            primaryAttributeValueArr.push(primaryAttribObj);
            productItem.set("primaryAttributes", primaryAttributeValueArr);
          }
          productFilters = categoryObj.get("filterable_attributes");
          _.each(productFilters, function(productFilter) {
            var AttributeValues, columnName, columnPosition, fattributeValues, filterAttribId, filterValueToSet;
            columnPosition = productFilter.get("filterColumn");
            columnName = "filter" + columnPosition;
            filterAttribId = productFilter.get("filterAttribute").id;
            filterValueToSet = productAttributes[filterAttribId];
            AttributeValues = Parse.Object.extend("AttributeValues");
            fattributeValues = new AttributeValues();
            fattributeValues.id = filterValueToSet;
            if (!_.isUndefined(filterValueToSet)) {
              return productItem.set(columnName, fattributeValues);
            }
          });
          attributeValueArr = [];
          _.each(productAttributes, function(attrib) {
            var attribObj;
            attribObj = {
              "__type": "Pointer",
              "className": "AttributeValues",
              "objectId": attrib
            };
            return attributeValueArr.push(attribObj);
          });
          productItem.set("attrs", attributeValueArr);
          return productSavedArr.push(productItem);
        }
      });
      return Parse.Object.saveAll(productSavedArr).then(function(objs) {
        return response.success("Successfully added the products");
      }, function(error) {
        return response.error("Failed to add products due to - " + error.message);
      });
    }, function(error) {
      return response.error(error);
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
    queryProductItem.include("primaryAttributes");
    queryProductItem.include("primaryAttributes.attribute");
    return queryProductItem.first().then(function(ProductData) {
      return response.success(ProductData);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('getProductsNew', function(request, response) {
    var ascending, categoryId, categoryQuery, displayLimit, page, selectedFilters, sortBy;
    categoryId = request.params.categoryId;
    selectedFilters = request.params.selectedFilters;
    sortBy = request.params.sortBy;
    ascending = request.params.ascending;
    page = parseInt(request.params.page);
    displayLimit = parseInt(request.params.displayLimit);
    categoryQuery = new Parse.Query("Category");
    categoryQuery.equalTo("objectId", categoryId);
    categoryQuery.select("filterable_attributes");
    categoryQuery.select("supported_brands");
    categoryQuery.select("price_range");
    categoryQuery.include("filterable_attributes");
    categoryQuery.include("filterable_attributes.filterAttribute");
    categoryQuery.include("supported_brands");
    return categoryQuery.first().then(function(categoryData) {
      var displayFilters, filters, findAttribValuesQs;
      filters = categoryData.get("filterable_attributes");
      displayFilters = [];
      findAttribValuesQs = _.map(filters, function(filter) {
        return findAttribValues(filter);
      });
      return Parse.Promise.when(findAttribValuesQs).then(function() {
        var ProductItem, brandPointers, brands, categoryBrands, endPrice, filterableProps, innerQuery, otherFilterColumnNames, otherFilters, price, price_range, query, queryFindPromise, startPrice, supported_brands;
        displayFilters = arguments;
        categoryBrands = categoryData.get("supported_brands");
        supported_brands = _.map(categoryBrands, function(categoryBrand) {
          var brand;
          if (categoryBrand !== null) {
            return brand = {
              "id": categoryBrand.id,
              "name": categoryBrand.get("name")
            };
          }
        });
        price_range = categoryData.get("price_range");
        ProductItem = Parse.Object.extend("ProductItem");
        innerQuery = new Parse.Query("Category");
        innerQuery.equalTo("objectId", categoryId);
        query = new Parse.Query("ProductItem");
        query.matchesQuery("category", innerQuery);
        if ((selectedFilters !== "all") && (_.isObject(selectedFilters))) {
          filterableProps = Object.keys(selectedFilters);
          if (_.contains(filterableProps, "brands")) {
            brands = selectedFilters["brands"];
            if (brands.length > 0) {
              brandPointers = _.map(brands, function(brandId) {
                var brandPointer;
                brandPointer = new Parse.Object('Brand');
                brandPointer.id = brandId;
                return brandPointer;
              });
              query.containedIn("brand", brandPointers);
            }
          }
          if (_.contains(filterableProps, "price")) {
            price = selectedFilters["price"];
            if (price.length === 2) {
              startPrice = parseInt(price[0]);
              endPrice = parseInt(price[1]);
              query.greaterThanOrEqualTo("mrp", startPrice);
              query.lessThanOrEqualTo("mrp", endPrice);
            }
          }
          if (_.contains(filterableProps, "otherFilters")) {
            otherFilters = selectedFilters['otherFilters'];
            if (!_.isEmpty(otherFilters)) {
              otherFilterColumnNames = _.keys(otherFilters);
              _.each(otherFilterColumnNames, function(otherFilterColumnName) {
                var attributeValuePointers, specificFilterArr;
                specificFilterArr = otherFilters[otherFilterColumnName];
                console.log(specificFilterArr);
                if (specificFilterArr.length > 0) {
                  attributeValuePointers = _.map(specificFilterArr, function(attributeValueId) {
                    var attributeValuePointer;
                    attributeValuePointer = new Parse.Object('AttributeValues');
                    attributeValuePointer.id = attributeValueId;
                    return attributeValuePointer;
                  });
                  return query.containedIn(otherFilterColumnName, attributeValuePointers);
                }
              });
            }
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
        return queryFindPromise = query.find().then(function(productsList) {
          var products, result;
          products = [];
          products = _.map(productsList, function(singleProduct) {
            var brand, product;
            brand = {
              "id": singleProduct.get("brand").id,
              "name": singleProduct.get("brand").get("name")
            };
            return product = {
              "objectId": singleProduct.id,
              "name": singleProduct.get("name"),
              "brand": brand,
              "images": singleProduct.get("images"),
              "mrp": singleProduct.get("mrp"),
              "primaryAttributes": singleProduct.get("primaryAttributes")
            };
          });
          result = {
            products: products,
            filters: displayFilters,
            supportedBrands: supported_brands,
            priceRange: price_range,
            sortableAttributes: ["mrp", "popularity"]
          };
          return response.success(result);
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

  Parse.Cloud.afterSave("ProductItem", function(request) {
    var categoryId, mrp, productObject, queryCategory;
    productObject = request.object;
    mrp = parseInt(productObject.get("mrp"));
    if ((!productObject.existed()) || ((productObject.existed()) && (productObject.createdAt !== productObject.updatedAt))) {
      categoryId = productObject.get("category").id;
      queryCategory = new Parse.Query("Category");
      queryCategory.equalTo("objectId", categoryId);
      return queryCategory.first().then(function(categoryObject) {
        var newPriceRange, oldPriceRange;
        newPriceRange = [];
        oldPriceRange = categoryObject.get("price_range");
        if ((_.isUndefined(oldPriceRange)) || (_.isEmpty(oldPriceRange))) {
          oldPriceRange[0] = 0;
          oldPriceRange[1] = 0;
        }
        oldPriceRange[0] = parseInt(oldPriceRange[0]);
        oldPriceRange[1] = parseInt(oldPriceRange[1]);
        if (mrp >= oldPriceRange[1]) {
          newPriceRange[0] = oldPriceRange[0];
          newPriceRange[1] = mrp;
        } else {
          newPriceRange[0] = mrp;
          newPriceRange[1] = oldPriceRange[1];
        }
        categoryObject.set("price_range", newPriceRange);
        return categoryObject.save();
      }, function(error) {
        return console.log("Got an error while fetching category " + error.code + " : " + error.message);
      });
    }
  });

  findAttribValues = (function(_this) {
    return function(filter) {
      var attributeId, attributeName, filterColumn, innerAttributeQuery, promise, queryAttributeValues;
      promise = new Parse.Promise();
      filterColumn = filter.get('filterColumn');
      attributeId = filter.get('filterAttribute').id;
      attributeName = filter.get('filterAttribute').get("name");
      queryAttributeValues = new Parse.Query("AttributeValues");
      innerAttributeQuery = new Parse.Query("Attributes");
      innerAttributeQuery.equalTo("objectId", attributeId);
      queryAttributeValues.matchesQuery("attribute", innerAttributeQuery);
      queryAttributeValues.find().then(function(allAttributeValues) {
        var attribValues, displayFilter;
        attribValues = _.map(allAttributeValues, function(attributeValue) {
          var attribValue;
          return attribValue = {
            "id": attributeValue.id,
            "name": attributeValue.get("value")
          };
        });
        displayFilter = {
          "filterName": "filter" + filterColumn,
          "attributeId": attributeId,
          "attributeName": attributeName,
          "values": attribValues
        };
        return promise.resolve(displayFilter);
      }, function(error) {
        return promise.reject(error);
      });
      return promise;
    };
  })(this);

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
    request.set("comments", comments);
    request.set("offerCount", 0);
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
    request.set("product", productObj);
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
      return getCategoryBasedSellers(categoryId, brandId, city, area).then(function(categoryBasedSellers) {
        var findQs;
        findQs = [];
        findQs = _.map(categoryBasedSellers, function(catBasedSeller) {
          var sellerGeoPoint, sellerId, sellerRadius;
          sellerId = catBasedSeller.id;
          sellerGeoPoint = catBasedSeller.get("addressGeoPoint");
          sellerRadius = catBasedSeller.get("deliveryRadius");
          return getAreaBoundSellers(sellerId, sellerGeoPoint, sellerRadius, createdRequestId);
        });
        return Parse.Promise.when(findQs).then(function() {
          var locationBasedSellers, notificationSavedArr;
          locationBasedSellers = _.flatten(_.toArray(arguments));
          notificationSavedArr = [];
          _.each(locationBasedSellers, function(locationBasedSeller) {
            var Notification, locationBasedSellerId, notification, notificationData, sellerObj;
            locationBasedSellerId = locationBasedSeller.sellerId;
            if (locationBasedSellerId) {
              sellerObj = {
                "__type": "Pointer",
                "className": "_User",
                "objectId": locationBasedSellerId
              };
              requestObject = {
                "__type": "Pointer",
                "className": "Request",
                "objectId": createdRequestId
              };
              notificationData = {
                hasSeen: false,
                recipientUser: sellerObj,
                channel: 'push',
                processed: false,
                type: "Request",
                requestObject: requestObject
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
    var area, city, sellerId, sellerLocation, sellerQuery, sellerRadius, status;
    sellerId = request.params.sellerId;
    city = request.params.city;
    area = request.params.area;
    sellerLocation = request.params.sellerLocation;
    sellerRadius = request.params.sellerRadius;
    status = "open";
    sellerQuery = new Parse.Query(Parse.User);
    sellerQuery.equalTo("objectId", sellerId);
    return sellerQuery.first().then(function(sellerObject) {
      var innerQuerySellers, offerQuery, sellerBrands, sellerCategories;
      sellerCategories = sellerObject.get("supportedCategories");
      sellerBrands = sellerObject.get("supportedBrands");
      if (city === 'default') {
        city = sellerObject.get("city");
      }
      if (area === 'default') {
        area = sellerObject.get("area");
      }
      if (sellerLocation === 'default') {
        sellerLocation = sellerObject.get("addressGeoPoint");
      } else {
        sellerLocation = request.params.sellerLocation;
      }
      if (sellerRadius === 'default') {
        sellerRadius = sellerObject.get("deliveryRadius");
      } else {
        sellerRadius = parseInt(request.params.sellerRadius);
      }
      innerQuerySellers = new Parse.Query(Parse.User);
      innerQuerySellers.equalTo("objectId", sellerId);
      offerQuery = new Parse.Query("Offer");
      offerQuery.matchesQuery("seller", innerQuerySellers);
      offerQuery.select("request");
      offerQuery.include("request");
      return offerQuery.find().then(function(offersMadeBySeller) {
        var currentDate, currentTimeStamp, expiryValueInHrs, queryDate, requestQuery, requestsWhereOfferMade, sellerGeoPoint, time24HoursAgo;
        requestsWhereOfferMade = _.map(offersMadeBySeller, function(offerMade) {
          return offerMade.get("request").id;
        });
        requestQuery = new Parse.Query("Request");
        requestQuery.containedIn("category", sellerCategories);
        requestQuery.containedIn("brand", sellerBrands);
        requestQuery.equalTo("city", city);
        requestQuery.equalTo("area", area);
        requestQuery.equalTo("status", status);
        currentDate = new Date();
        currentTimeStamp = currentDate.getTime();
        expiryValueInHrs = 24;
        queryDate = new Date();
        time24HoursAgo = currentTimeStamp - (expiryValueInHrs * 60 * 60 * 1000);
        queryDate.setTime(time24HoursAgo);
        requestQuery.greaterThanOrEqualTo("createdAt", queryDate);
        sellerGeoPoint = new Parse.GeoPoint(sellerLocation);
        requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius);
        requestQuery.notContainedIn("objectId", requestsWhereOfferMade);
        requestQuery.select("address,addressGeoPoint,category,brand,product,comments,customerId");
        requestQuery.include("product");
        requestQuery.include("category");
        requestQuery.include("category.parent_category");
        requestQuery.include("brand");
        return requestQuery.find().then(function(filteredRequests) {
          var requestsQs, sellerDetails;
          requestsQs = [];
          sellerDetails = {
            "id": sellerId,
            "geoPoint": sellerGeoPoint
          };
          requestsQs = _.map(filteredRequests, function(filteredRequest) {
            var requestPromise;
            return requestPromise = getRequestData(filteredRequest, sellerDetails);
          });
          return Parse.Promise.when(requestsQs).then(function() {
            var individualReqResults, requestsResult;
            individualReqResults = _.flatten(_.toArray(arguments));
            requestsResult = {
              "city": city,
              "area": area,
              "radius": sellerRadius,
              "location": sellerLocation,
              "requests": individualReqResults
            };
            return response.success(requestsResult);
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

  Parse.Cloud.define('updateRequestStatus', function(request, response) {
    var Request, failedDeliveryReason, isValidStatus, requestId, status, validStatuses;
    requestId = request.params.requestId;
    status = request.params.status;
    failedDeliveryReason = request.params.failedDeliveryReason;
    validStatuses = ['pending_delivery', 'failed_delivery', 'successful', 'cancelled'];
    isValidStatus = _.indexOf(validStatuses, status);
    if (isValidStatus > -1) {
      Request = Parse.Object.extend('Request');
      request = new Request();
      request.id = requestId;
      request.set("status", status);
      if (status === "failed_delivery") {
        request.set("failedDeliveryReason", failedDeliveryReason);
      }
      return request.save().then(function(requestObj) {
        var innerQueryRequest, queryNotification, requestStatus, resultObj;
        requestStatus = requestObj.get("status");
        requestId = requestObj.id;
        if (requestStatus === "cancelled") {
          queryNotification = new Parse.Query("Notification");
          innerQueryRequest = new Parse.Query("Request");
          innerQueryRequest.equalTo("objectId", requestId);
          queryNotification.equalTo("type", "Request");
          queryNotification.matchesQuery("requestObject", innerQueryRequest);
          queryNotification.include("recipientUser");
          return queryNotification.find().then(function(newReqNotifications) {
            var notificationSavedArr, sellersArr;
            sellersArr = _.map(newReqNotifications, function(newNotification) {
              return newNotification.get("recipientUser");
            });
            notificationSavedArr = [];
            _.each(sellersArr, function(sellerObj) {
              var Notification, notification, notificationData;
              notificationData = {
                hasSeen: false,
                recipientUser: sellerObj,
                channel: 'push',
                processed: false,
                type: "CancelledRequest",
                requestObject: requestObj
              };
              Notification = Parse.Object.extend("Notification");
              notification = new Notification(notificationData);
              return notificationSavedArr.push(notification);
            });
            return Parse.Object.saveAll(notificationSavedArr).then(function(objs) {
              return response.success(objs);
            }, function(error) {
              return response.error(error);
            });
          }, function(error) {
            return response.error(error);
          });
        } else {
          resultObj = {
            requestId: requestId,
            requestStatus: requestObj.get("status")
          };
          return response.success(resultObj);
        }
      }, function(error) {
        return response.error(error);
      });
    } else {
      return response.error("Please enter a valid status");
    }
  });

  Parse.Cloud.define('getCustomerRequests', function(request, response) {
    var currentDate, currentTimeStamp, customerId, descending, displayLimit, expiryValueInHrs, innerQueryCustomer, innerQueryCustomer2, innerQueryProduct, innerQueryProduct2, otherRequestStatuses, page, productId, queryDate, queryNonExpiredOpenReq, queryOtherStatusReq, queryRequest, requestType, selectedFilters, sortBy, time24HoursAgo;
    customerId = request.params.customerId;
    productId = request.params.productId;
    page = parseInt(request.params.page);
    displayLimit = parseInt(request.params.displayLimit);
    requestType = request.params.requestType;
    selectedFilters = request.params.selectedFilters;
    sortBy = request.params.sortBy;
    descending = request.params.descending;
    currentDate = new Date();
    currentTimeStamp = currentDate.getTime();
    expiryValueInHrs = 24;
    queryDate = new Date();
    time24HoursAgo = currentTimeStamp - (expiryValueInHrs * 60 * 60 * 1000);
    queryDate.setTime(time24HoursAgo);
    if (requestType === "expired") {
      queryRequest = new Parse.Query("Request");
      innerQueryCustomer = new Parse.Query(Parse.User);
      innerQueryCustomer.equalTo("objectId", customerId);
      queryRequest.matchesQuery("customerId", innerQueryCustomer);
      if (productId !== "") {
        innerQueryProduct = new Parse.Query("ProductItem");
        innerQueryProduct.equalTo("objectId", productId);
        queryRequest.matchesQuery("product", innerQueryProduct);
      }
      queryRequest.equalTo("status", "open");
      queryRequest.lessThanOrEqualTo("createdAt", queryDate);
    } else if (requestType === "nonexpired") {
      queryNonExpiredOpenReq = new Parse.Query("Request");
      innerQueryCustomer = new Parse.Query(Parse.User);
      innerQueryCustomer.equalTo("objectId", customerId);
      queryNonExpiredOpenReq.matchesQuery("customerId", innerQueryCustomer);
      if (productId !== "") {
        innerQueryProduct = new Parse.Query("ProductItem");
        innerQueryProduct.equalTo("objectId", productId);
        queryNonExpiredOpenReq.matchesQuery("product", innerQueryProduct);
      }
      queryNonExpiredOpenReq.equalTo("status", "open");
      queryNonExpiredOpenReq.greaterThanOrEqualTo("createdAt", queryDate);
      if (selectedFilters.length === 0) {
        otherRequestStatuses = ["cancelled", "pending_delivery", "failed_delivery", "successful"];
      } else {
        otherRequestStatuses = _.without(selectedFilters, "open");
      }
      queryOtherStatusReq = new Parse.Query("Request");
      innerQueryCustomer2 = new Parse.Query(Parse.User);
      innerQueryCustomer2.equalTo("objectId", customerId);
      queryOtherStatusReq.matchesQuery("customerId", innerQueryCustomer2);
      if (productId !== "") {
        innerQueryProduct2 = new Parse.Query("ProductItem");
        innerQueryProduct2.equalTo("objectId", productId);
        queryOtherStatusReq.matchesQuery("product", innerQueryProduct2);
      }
      queryOtherStatusReq.containedIn("status", otherRequestStatuses);
      if ((_.indexOf(selectedFilters, "open") > -1) || (selectedFilters.length === 0)) {
        queryRequest = Parse.Query.or(queryNonExpiredOpenReq, queryOtherStatusReq);
      } else {
        queryRequest = queryOtherStatusReq;
      }
    } else if (requestType === "all") {
      queryRequest = new Parse.Query("Request");
      innerQueryCustomer = new Parse.Query(Parse.User);
      innerQueryCustomer.equalTo("objectId", customerId);
      queryRequest.matchesQuery("customerId", innerQueryCustomer);
      if (productId !== "") {
        innerQueryProduct = new Parse.Query("ProductItem");
        innerQueryProduct.equalTo("objectId", productId);
        queryRequest.matchesQuery("product", innerQueryProduct);
      }
    }
    queryRequest.include("product");
    if (descending === true) {
      queryRequest.descending("updatedAt");
    } else {
      queryRequest.ascending("updatedAt");
    }
    queryRequest.limit(displayLimit);
    queryRequest.skip(page * displayLimit);
    return queryRequest.find().then(function(requests) {
      var pastRequests;
      pastRequests = _.map(requests, function(requestObj) {
        var createdDate, diff, differenceInDays, pastReq, product, requestStatus;
        currentDate = new Date();
        createdDate = requestObj.createdAt;
        diff = currentDate.getTime() - createdDate.getTime();
        differenceInDays = Math.floor(diff / (1000 * 60 * 60 * 24));
        requestStatus = requestObj.get("status");
        if (differenceInDays >= 1) {
          if (requestStatus === "open") {
            requestStatus = "expired";
          }
        }
        product = {
          "name": requestObj.get("product").get("name"),
          "images": requestObj.get("product").get("images"),
          "mrp": requestObj.get("product").get("mrp")
        };
        pastReq = {
          "id": requestObj.id,
          "product": product,
          "status": requestStatus,
          "createdAt": requestObj.createdAt,
          "updatedAt": requestObj.updatedAt,
          "differenceInDays": differenceInDays,
          "address": requestObj.get("address"),
          "comments": requestObj.get("comments"),
          "offerCount": requestObj.get("offerCount")
        };
        return pastReq;
      });
      return response.success(pastRequests);
    }, function(error) {
      return response.error(error);
    });
  });

  Parse.Cloud.define('getSingleRequest', function(request, response) {
    var queryRequest, requestId, sellerDetails;
    requestId = request.params.requestId;
    sellerDetails = {
      "id": request.params.sellerId,
      "geoPoint": request.params.sellerGeoPoint
    };
    queryRequest = new Parse.Query("Request");
    queryRequest.equalTo("objectId", requestId);
    queryRequest.select("address,addressGeoPoint,category,brand,product,comments,customerId,status");
    queryRequest.include("product");
    queryRequest.include("category");
    queryRequest.include("category.parent_category");
    queryRequest.include("brand");
    return queryRequest.first().then(function(requestObj) {
      return getRequestData(requestObj, sellerDetails).then(function(requestData) {
        return response.success(requestData);
      }, function(error) {
        return response.error(error);
      });
    }, function(error) {
      return response.error(error);
    });
  });

  getRequestData = function(filteredRequest, seller) {
    var innerQueryRequest, innerQuerySeller, promise, queryNotification, sellerGeoPoint, sellerId;
    promise = new Parse.Promise();
    sellerId = seller.id;
    sellerGeoPoint = seller.geoPoint;
    queryNotification = new Parse.Query("Notification");
    innerQuerySeller = new Parse.Query(Parse.User);
    innerQuerySeller.equalTo("objectId", sellerId);
    queryNotification.matchesQuery("recipientUser", innerQuerySeller);
    queryNotification.equalTo("type", "Request");
    innerQueryRequest = new Parse.Query("Request");
    innerQueryRequest.equalTo("objectId", filteredRequest.id);
    queryNotification.matchesQuery("requestObject", innerQueryRequest);
    queryNotification.first().then(function(notificationObject) {
      var brand, brandObj, category, categoryObj, notification, prodObj, product, radiusDiffInKm, requestObj, reuqestGeoPoint;
      if (!_.isEmpty(notificationObject)) {
        notification = {
          "hasSeen": notificationObject.get("hasSeen")
        };
      } else {
        notification = {
          "hasSeen": ""
        };
      }
      prodObj = filteredRequest.get("product");
      product = {
        "id": prodObj.id,
        "name": prodObj.get("name"),
        "mrp": prodObj.get("mrp"),
        "image": prodObj.get("images")
      };
      categoryObj = filteredRequest.get("category");
      category = {
        "id": categoryObj.id,
        "name": categoryObj.get("name"),
        "parent": (categoryObj.get("parent_category")).get("name")
      };
      brandObj = filteredRequest.get("brand");
      brand = {
        "id": brandObj.id,
        "name": brandObj.get("name")
      };
      reuqestGeoPoint = filteredRequest.get("addressGeoPoint");
      radiusDiffInKm = reuqestGeoPoint.kilometersTo(sellerGeoPoint);
      requestObj = {
        id: filteredRequest.id,
        radius: radiusDiffInKm,
        product: product,
        category: category,
        brand: brand,
        createdAt: filteredRequest.createdAt,
        notification: notification,
        comments: filteredRequest.get("comments"),
        status: filteredRequest.get("status")
      };
      return promise.resolve(requestObj);
    }, function(error) {
      return promise.reject(error);
    });
    return promise;
  };

  getCategoryBasedSellers = function(categoryId, brandId, city, area) {
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

  getAreaBoundSellers = function(sellerId, sellerGeoPoint, sellerRadius, createdRequestId) {
    var promise, requestQuery;
    requestQuery = new Parse.Query("Request");
    requestQuery.equalTo("objectId", createdRequestId);
    requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius);
    promise = new Parse.Promise();
    requestQuery.find().then(function(requests) {
      var seller;
      if (requests.length === 0) {
        return promise.resolve();
      } else {
        seller = {
          sellerId: sellerId,
          sellerGeoPoint: sellerGeoPoint
        };
        return promise.resolve(seller);
      }
    }, function(error) {
      return promise.reject(error);
    });
    return promise;
  };

  Parse.Cloud.define('getLocationBasedSellers', function(request, response) {
    var Request, area, brandId, brandObj, categoryId, categoryObj, city, locationGeoPoint, point, status, tempRequest;
    locationGeoPoint = {
      "latitude": request.params.location.latitude,
      "longitude": request.params.location.longitude
    };
    categoryId = request.params.categoryId;
    brandId = request.params.brandId;
    city = request.params.city;
    area = request.params.area;
    status = "temporary";
    Request = Parse.Object.extend('Request');
    tempRequest = new Request();
    point = new Parse.GeoPoint(locationGeoPoint);
    tempRequest.set("addressGeoPoint", point);
    tempRequest.set("status", status);
    tempRequest.set("city", city);
    tempRequest.set("area", area);
    categoryObj = {
      "__type": "Pointer",
      "className": "Category",
      "objectId": categoryId
    };
    tempRequest.set("category", categoryObj);
    brandObj = {
      "__type": "Pointer",
      "className": "Brand",
      "objectId": brandId
    };
    tempRequest.set("brand", brandObj);
    return tempRequest.save().then(function(requestObject) {
      var createdRequestId, sellersArray;
      createdRequestId = requestObject.id;
      city = requestObject.get("city");
      area = requestObject.get("area");
      sellersArray = [];
      return getCategoryBasedSellers(categoryId, brandId, city, area).then(function(categoryBasedSellers) {
        var findQs;
        findQs = [];
        findQs = _.map(categoryBasedSellers, function(catBasedSeller) {
          var sellerGeoPoint, sellerId, sellerRadius;
          sellerId = catBasedSeller.id;
          sellerGeoPoint = catBasedSeller.get("addressGeoPoint");
          sellerRadius = catBasedSeller.get("deliveryRadius");
          return getAreaBoundSellers(sellerId, sellerGeoPoint, sellerRadius, createdRequestId);
        });
        return Parse.Promise.when(findQs).then(function() {
          var locationBasedSellers;
          requestObject.destroy();
          locationBasedSellers = _.flatten(_.toArray(arguments));
          return response.success(locationBasedSellers);
        }, function(error) {
          return response.error(error);
        });
      });
    });
  });

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
