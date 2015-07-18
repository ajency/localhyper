angular.module('LocalHyper.suggestProduct', []).controller('suggestProductCtrl', [
  '$q', '$scope', '$http', '$location', 'CToast', 'CategoriesAPI', function($q, $scope, $http, $location, CToast, CategoriesAPI) {
    $scope.suggest = {};
    CategoriesAPI.getAll().then(function(categories) {
      console.log(categories);
      return $scope.suggest.items = categories;
    });
    return $scope.suggest = {
      productName: null,
      category: null,
      brand: null,
      productDescription: null,
      yourComments: null,
      onSuggest: function() {
        var defer, param;
        defer = $q.defer();
        param = {
          "productName": $scope.suggest.productName,
          "category": $scope.suggest.category.name,
          "brand": $scope.suggest.brand,
          "description": $scope.suggest.productDescription,
          "comments": $scope.suggest.yourComments
        };
        $http.post('functions/sendMail', param).then(function(data) {
          defer.resolve;
          return $location.path('/categories');
        }, function(error) {
          return defer.reject(error);
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
