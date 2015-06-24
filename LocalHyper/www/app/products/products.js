angular.module('LocalHyper.products', []).controller('ProductsCtrl', [
  '$scope', function($scope) {
    return console.log('Products');
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('products', {
      url: '/products',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/products.html',
          controller: 'ProductsCtrl'
        }
      }
    });
  }
]);
