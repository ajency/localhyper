angular.module('LocalHyper.categories').controller('CategoryChainsCtrl', [
  '$scope', 'App', 'CategoriesAPI', 'Storage', function($scope, App, CategoriesAPI, Storage) {
    return $scope.view = {
      showDelete: false,
      categoryChains: [],
      setCategoryChains: function() {
        return Storage.categoryChains('get').then((function(_this) {
          return function(chains) {
            if (!_.isNull(chains)) {
              _this.categoryChains = chains;
              return CategoriesAPI.categoryChains('set', chains);
            }
          };
        })(this));
      },
      getBrands: function(brands) {
        var brandNames;
        brandNames = _.pluck(brands, 'name');
        return brandNames.join(', ');
      },
      removeItemFromChains: function(subCategoryId) {
        var spliceIndex;
        this.categoryChains = CategoriesAPI.categoryChains('get');
        spliceIndex = _.findIndex(this.categoryChains, function(chains) {
          return chains.subCategory.id === subCategoryId;
        });
        this.categoryChains.splice(spliceIndex, 1);
        CategoriesAPI.categoryChains('set', this.categoryChains);
        return Storage.categoryChains('set', this.categoryChains);
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('category-chains', {
      url: '/category-chains',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          templateUrl: 'views/categories/category-chains.html',
          controller: 'CategoryChainsCtrl'
        }
      }
    });
  }
]);
