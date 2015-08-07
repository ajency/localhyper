angular.module('LocalHyper.creditHistory').factory('creditHistoryAPI', [
  '$q', '$http', function($q, $http) {
    var creditHistoryAPI;
    creditHistoryAPI = {};
    creditHistoryAPI.getCreditBalance = function() {
      var defer;
      defer = $q.defer();
      $http.post('functions/getCreditBalance', {
        "sellerId": "hay0Mhspc1"
      }).then(function(data) {
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
