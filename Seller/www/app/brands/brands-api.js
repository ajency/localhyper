angular.module('LocalHyper.brands').factory('BrandsAPI', [
  '$q', '$http', function($q, $http) {
    var BrandsAPI;
    BrandsAPI = {};
    BrandsAPI.getAll = function(categoryID) {
      var defer, params;
      defer = $q.defer();
      params = {
        "categoryId": categoryID
      };
      $http.post('functions/getCategoryBasedBrands', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return BrandsAPI;
  }
]);
