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
        "requestId": requestId
      };
      $http.post('functions/getRequestOffers', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return RequestAPI;
  }
]);
