angular.module('LocalHyper.categories').factory('CategoriesAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
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
          return defer.resolve(allCategories = data.data.result);
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
        case 'get':
          return categoryChains;
      }
    };
    CategoriesAPI.updateUnseenRequestNotification = function(param) {
      var defer, params, user;
      defer = $q.defer();
      user = User.getCurrent();
      params = {
        "sellerId": user.id,
        "changedData": param.changedData
      };
      $http.post('functions/updateUnseenRequestNotification', params).then(function(success) {
        return defer.resolve(success);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return CategoriesAPI;
  }
]);
