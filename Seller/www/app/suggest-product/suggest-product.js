angular.module('LocalHyper.suggestProduct', []).controller('suggestProductCtrl', [
  '$q', '$scope', '$http', '$location', 'CToast', 'CategoriesAPI', 'CSpinner', function($q, $scope, $http, $location, CToast, CategoriesAPI, CSpinner) {
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
        var param;
        if (this.productName === null) {
          return CToast.show('Please enter product Name');
        } else if (this.brand === null) {
          return CToast.show('Please enter brand Name');
        } else if (this.category === null) {
          return CToast.show('Please Select Category');
        } else {
          CSpinner.show('', 'Please wait...');
          param = {
            "productName": this.productName,
            "category": this.category.name,
            "brand": this.brand,
            "description": this.productDescription,
            "comments": this.yourComments
          };
          return $http.post('functions/sendMail', param).then(function(data) {
            return CToast.show('your product has been suggested');
          }, function(error) {
            return CToast.show('Request failed, please try again');
          })["finally"](function() {
            return CSpinner.hide();
          });
        }
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
