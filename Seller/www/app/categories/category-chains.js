angular.module('LocalHyper.categories').controller('CategoryChainsCtrl', [
  '$scope', 'App', 'CategoriesAPI', function($scope, App, CategoriesAPI) {
    return $scope.view = {
      categoryChains: [],
      setCategoryChains: function() {
        return this.categoryChains = CategoriesAPI.categoryChains('get');
      },
      getBrands: function(brands) {
        var brandNames;
        brandNames = _.pluck(brands, 'name');
        return brandNames.join(', ');
      },
      removeItemFromChains: function(subCategoryId) {
        var spliceIndex;
        this.setCategoryChains();
        spliceIndex = _.findIndex(this.categoryChains, function(chains) {
          return chains.subCategory.id === subCategoryId;
        });
        this.categoryChains.splice(spliceIndex, 1);
        return CategoriesAPI.categoryChains('set', this.categoryChains);
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
