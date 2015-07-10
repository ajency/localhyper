angular.module('LocalHyper.products').factory('ProductsAPI', [
  '$q', '$http', function($q, $http) {
    var ProductsAPI;
    ProductsAPI = {};
    ProductsAPI.getAll = function(opts) {
      var defer, params;
      defer = $q.defer();
      params = {
        "categoryId": "" + opts.categoryID,
        "selectedFilters": "all",
        "sortBy": opts.sortBy,
        "ascending": opts.ascending,
        "page": opts.page,
        "displayLimit": 10
      };
      $http.post('functions/getProducts', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    ProductsAPI.getSingleProduct = function(productId) {
      var defer;
      defer = $q.defer();
      $http.post('functions/getProduct', {
        "productId": productId
      }).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    ProductsAPI.makeRequest = function(productId) {
      var defer;
      defer = $q.defer();
      $http.post('functions/makeRequest', {
        "productId": productId
      }).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return ProductsAPI;
  }
]);
