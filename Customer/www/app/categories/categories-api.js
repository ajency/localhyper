angular.module('LocalHyper.categories').factory('CategoriesAPI', [
  '$q', '$http', function($q, $http) {
    var CategoriesAPI, allCategories, subCategories;
    CategoriesAPI = {};
    allCategories = [];
    subCategories = [];
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
    return CategoriesAPI;
  }
]);
