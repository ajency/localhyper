angular.module('LocalHyper.categories').factory('CategoriesAPI', [
  '$q', function($q) {
    var CategoriesAPI, allCategories;
    CategoriesAPI = {};
    allCategories = [];
    CategoriesAPI.getAll = function() {
      var defer;
      defer = $q.defer();
      if (_.isEmpty(allCategories)) {
        Parse.Cloud.run('getCategories', {
          "sortBy": "sort_order"
        }).then(function(data) {
          return defer.resolve(allCategories = data.data);
        }, function(error) {
          return defer.reject(error);
        });
      } else {
        defer.resolve(allCategories);
      }
      return defer.promise;
    };
    return CategoriesAPI;
  }
]);
