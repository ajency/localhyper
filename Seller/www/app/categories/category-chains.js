angular.module('LocalHyper.categories').controller('CategoryChainsCtrl', [
  '$scope', 'App', 'CategoriesAPI', function($scope, App, CategoriesAPI) {
    return $scope.view = {
      categoryChains: null,
      setCategoryChains: function() {
        return this.categoryChains = CategoriesAPI.categoryChains('get');
      },
      getBrands: function(brands) {
        var brandNames;
        brandNames = _.pluck(brands, 'name');
        return brandNames.join(', ');
      },
      removeItemFromChains: function(subCategoryId) {
        this.setCategoryChains();
        _.each(this.categoryChains, (function(_this) {
          return function(chains, index) {
            if (chains.subCategory.id === subCategoryId) {
              return _this.categoryChains.splice(index, 1);
            }
          };
        })(this));
        if (_.isEmpty(this.categoryChains)) {
          return App.goBack(-3);
        } else {
          return CategoriesAPI.categoryChains('set', this.categoryChains);
        }
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
