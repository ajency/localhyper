angular.module('LocalHyper.products').factory('ProductsAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
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
    ProductsAPI.makeRequest = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/makeRequest', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    ProductsAPI.getNewOffers = function(productId) {
      var defer, params;
      defer = $q.defer();
      if (User.isLoggedIn()) {
        params = {
          "productId": productId,
          "customerId": User.getId()
        };
        $http.post('functions/getNewOffers', params).then(function(data) {
          return defer.resolve(data.data.result);
        }, function(error) {
          return defer.reject(error);
        });
      } else {
        defer.resolve({});
      }
      return defer.promise;
    };
    return ProductsAPI;
  }
]);
