angular.module('LocalHyper.products').controller('SingleProductCtrl', [
  '$scope', '$stateParams', 'ProductsAPI', 'User', 'CToast', 'App', '$ionicModal', function($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      productID: $stateParams.productID,
      product: {},
      specificationModal: null,
      init: function() {
        return this.loadSpecificationsModal();
      },
      loadSpecificationsModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/specification.html', {
          scope: $scope,
          animation: 'slide-in-up'
        }).then((function(_this) {
          return function(modal) {
            return _this.specificationModal = modal;
          };
        })(this));
      },
      getSingleProductDetails: function() {
        return ProductsAPI.getSingleProduct(this.productID).then((function(_this) {
          return function(data) {
            return _this.onSuccess(data);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this));
      },
      onSuccess: function(data) {
        this.display = 'noError';
        this.product = data;
        return console.log(data);
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getSingleProductDetails();
      },
      onMakeRequest: function() {
        if (User.isLoggedIn()) {
          return CToast.show('User session active');
        } else {
          return App.navigate('verify-begin');
        }
      }
    };
    return $scope.$on('$ionicView.loaded', function() {
      return $scope.view.getSingleProductDetails();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('single-product', {
      url: '/single-product:productID',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/single-product.html',
          controller: 'SingleProductCtrl'
        }
      }
    });
  }
]);
