angular.module('LocalHyper.suggestProduct', []).controller('suggestProductCtrl', [
  '$q', '$scope', function($q, $scope) {
    return $scope.suggest = {
      productName: null,
      category: null,
      brand: null,
      productDescription: null,
      yourComments: null,
      onSuggest: function() {
        var Product, defer, product;
        defer = $q.defer();
        Product = Parse.Object.extend("suggestProduct");
        product = new Product();
        product.set("productName", $scope.suggest.productName);
        product.set("category", $scope.suggest.category);
        product.set("brand", $scope.suggest.brand);
        product.set("productDescription", $scope.suggest.productDescription);
        product.set("Comments", $scope.suggest.yourComments);
        product.save().then(function() {
          return defer.resolve;
        }, function(error) {
          return defer.reject;
        });
        return defer.promise;
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('suggest-product', {
      url: '/suggest-product',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'suggestProductCtrl',
          templateUrl: 'views/suggest-product.html'
        }
      }
    });
  }
]);
