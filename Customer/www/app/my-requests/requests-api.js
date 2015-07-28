angular.module('LocalHyper.myRequests').factory('RequestAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
    var RequestAPI;
    RequestAPI = {};
    RequestAPI.get = function(opts) {
      var defer, params, productId;
      defer = $q.defer();
      productId = opts.productId;
      productId = _.isUndefined(productId) ? "" : productId;
      params = {
        "customerId": User.getId(),
        "productId": productId,
        "page": opts.page,
        "displayLimit": 5,
        "openStatus": opts.openStatus
      };
      $http.post('functions/getCustomerRequests', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return RequestAPI;
  }
]);
