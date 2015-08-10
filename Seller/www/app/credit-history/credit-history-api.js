angular.module('LocalHyper.creditHistory').factory('CreditHistoryAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
    var CreditHistoryAPI;
    CreditHistoryAPI = {};
    CreditHistoryAPI.getAll = function(param) {
      var defer, params;
      defer = $q.defer();
      params = {
        "sellerId": User.getId(),
        "displayLimit": param.displayLimit,
        "page": param.page
      };
      $http.post('functions/getCreditHistory', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return CreditHistoryAPI;
  }
]);
