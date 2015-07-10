angular.module('LocalHyper.categories').factory('CategoriesAPI', [
  '$q', '$http', function($q, $http) {
    var CategoriesAPI, allCategories, categoryChains, subCategories;
    CategoriesAPI = {};
    allCategories = [];
    subCategories = [];
    categoryChains = [];
    CategoriesAPI.getAll = function() {
      var defer;
      defer = $q.defer();
      if (_.isEmpty(allCategories)) {
        $http.post('functions/getCategories', {
          "sortBy": "sort_order"
        }).then(function(data) {
          return defer.resolve(allCategories = data.data.result.data);
        }, function(error) {
          return defer.reject(error);
        });
      } else {
        defer.resolve(allCategories);
      }
      return defer.promise;
    };
    CategoriesAPI.subCategories = function(action, data) {
      if (data == null) {
        data = {};
      }
      switch (action) {
        case 'set':
          return subCategories = data;
        case 'get':
          return subCategories;
      }
    };
    CategoriesAPI.categoryChains = function(action, data) {
      if (data == null) {
        data = {};
      }
      switch (action) {
        case 'set':
          return categoryChains = data;
        case 'unset':
          return categoryChains = data;
        case 'get':
          return categoryChains;
      }
    };
    return CategoriesAPI;
  }
]);
