angular.module('LocalHyper.myRequests').factory('RequestAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
    var RequestAPI, requestDetails;
    RequestAPI = {};
    requestDetails = {};
    RequestAPI.get = function(opts) {
      var defer, params, productId;
      defer = $q.defer();
      productId = opts.productId;
      productId = _.isUndefined(productId) ? "" : productId;
      params = {
        "customerId": User.getId(),
        "productId": productId,
        "page": opts.page,
        "displayLimit": opts.displayLimit,
        "requestType": opts.requestType,
        "selectedFilters": opts.selectedFilters,
        "sortBy": "updatedAt",
        "descending": true
      };
      $http.post('functions/getCustomerRequests', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.getRequestDetails = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/getRequestDetails', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.requestDetails = function(action, data) {
      if (data == null) {
        data = {};
      }
      switch (action) {
        case 'set':
          return requestDetails = data;
        case 'get':
          return requestDetails;
      }
    };
    RequestAPI.getOffers = function(requestId) {
      var defer, params;
      defer = $q.defer();
      params = {
        "requestId": requestId,
        "customerId": User.getId()
      };
      $http.post('functions/getRequestOffers', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.acceptOffer = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/acceptOffer', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.updateRequestStatus = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/updateRequestStatus', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.getNotifications = function() {
      var defer, params;
      defer = $q.defer();
      params = {
        "userId": User.getId(),
        "type": "Offer"
      };
      $http.post('functions/getUnseenNotifications', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.isNotificationSeen = function(requestId) {
      var defer, params;
      defer = $q.defer();
      params = {
        "userId": User.getId(),
        "requestId": requestId
      };
      $http.post('functions/isOfferNotificationSeen', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.updateNotificationStatus = function(offerIds) {
      var defer, params;
      defer = $q.defer();
      params = {
        "notificationTypeId": offerIds,
        "recipientId": User.getId(),
        "notificationType": "Offer",
        "hasSeen": true
      };
      $http.post('functions/updateNotificationStatus', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.getOpenRequestCount = function() {
      var defer, params;
      defer = $q.defer();
      params = {
        "customerId": User.getId()
      };
      $http.post('functions/getOpenRequestCount', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestAPI.updateSellerRating = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/updateSellerRating', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return RequestAPI;
  }
]);
