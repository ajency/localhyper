angular.module('LocalHyper.products').factory('ProductsAPI', [
  '$q', '$http', function($q, $http) {
    var ProductsAPI;
    ProductsAPI = {};
    ProductsAPI.get = function(opts) {
      var defer, params;
      defer = $q.defer();
      params = {
        "categoryId": "" + opts.categoryID,
        "selectedFilters": "all",
        "sortBy": "popularity",
        "ascending": false,
        "page": opts.page,
        "displayLimit": 6
      };
      $http.post('getProducts', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return ProductsAPI;
  }
]);
