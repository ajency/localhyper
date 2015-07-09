angular.module('LocalHyper.categories').controller('CategoryChainsCtrl', [
  '$scope', 'App', 'CategoriesAPI', function($scope, App, CategoriesAPI) {
    return $scope.view = {
      categoryChains: CategoriesAPI.categoryChains('get'),
      init: function() {
        return console.log(CategoriesAPI.categoryChains('get'));
      },
      getBrands: function(brands) {
        var brandNames;
        brandNames = _.pluck(brands, 'name');
        return brandNames.join(', ');
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
