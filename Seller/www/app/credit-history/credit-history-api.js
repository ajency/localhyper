angular.module('LocalHyper.creditHistory').factory('creditHistoryAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
    var creditHistoryAPI;
    creditHistoryAPI = {};
    creditHistoryAPI.getCreditHistory = function(param) {
      var defer, params, user;
      user = User.getCurrent();
      params = {
        "sellerId": "hay0Mhspc1",
        "displayLimit": param.displayLimit,
        "page": param.page
      };
      defer = $q.defer();
      $http.post('functions/getCreditHistory', params).then(function(data) {
        var allCategories;
        return defer.resolve(allCategories = data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return creditHistoryAPI;
  }
]);
