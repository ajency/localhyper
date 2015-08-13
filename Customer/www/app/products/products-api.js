angular.module('LocalHyper.products').factory('ProductsAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
    var ProductsAPI, productDetails;
    ProductsAPI = {};
    productDetails = {};
    ProductsAPI.getAll = function(opts) {
      var brands, defer, otherFilters, params, price, selectedFilters;
      defer = $q.defer();
      selectedFilters = opts.selectedFilters;
      brands = selectedFilters.brands;
      price = selectedFilters.price;
      otherFilters = selectedFilters.otherFilters;
      if (_.isEmpty(brands) && _.isEmpty(price) && _.isEmpty(otherFilters)) {
        selectedFilters = "all";
      }
      params = {
        "categoryId": opts.categoryID,
        "selectedFilters": selectedFilters,
        "sortBy": opts.sortBy,
        "ascending": opts.ascending,
        "page": opts.page,
        "displayLimit": opts.displayLimit,
        "searchKeywords": opts.searchKeywords
      };
      $http.post('functions/getProductsNew', params).then(function(data) {
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
    ProductsAPI.productDetails = function(action, data) {
      if (data == null) {
        data = {};
      }
      switch (action) {
        case 'set':
          return productDetails = data;
        case 'get':
          return productDetails;
      }
    };
    ProductsAPI.findSellers = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/getLocationBasedSellers', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return ProductsAPI;
  }
]);
