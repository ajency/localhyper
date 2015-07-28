angular.module('LocalHyper.myRequests').factory('MyRequestsAPI', [
  '$q', '$http', 'User', '$timeout', function($q, $http, User, $timeout) {
    var MyRequestsAPI;
    MyRequestsAPI = {};
    MyRequestsAPI.getOpenRequests = function(opts) {
      var defer, params, user;
      defer = $q.defer();
      user = User.getCurrent();
      params = {
        "customerId": user.id,
        "productId": "",
        "page": opts.page,
        "displayLimit": 3,
        "openStatus": true
      };
      $http.post('functions/getCustomerRequests', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return MyRequestsAPI;
  }
]);
