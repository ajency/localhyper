angular.module('LocalHyper.suggestProduct', []).controller('suggestProductCtrl', [
  '$q', '$scope', '$http', '$location', 'CToast', 'CategoriesAPI', 'CSpinner', function($q, $scope, $http, $location, CToast, CategoriesAPI, CSpinner) {
    $scope.suggest = {};
    CategoriesAPI.getAll().then(function(categories) {
      console.log(categories);
      return $scope.suggest.items = categories;
    });
    $scope.suggest = {
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
            "comments": this.yourComments,
            "userType": "Seller"
          };
          return $http.post('functions/sendMail', param).then(function(data) {
            return CToast.showLongBottom('Thank you for your time. We will do our best to accommodate your suggestion at the earliest.');
          }, function(error) {
            return CToast.show('Request failed, please try again');
          })["finally"](function() {
            return CSpinner.hide();
          });
        }
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
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
