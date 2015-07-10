angular.module('LocalHyper.products').controller('SingleProductCtrl', [
  '$scope', '$stateParams', 'ProductsAPI', 'User', 'CToast', 'App', '$ionicModal', 'GPS', function($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GPS) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      productID: $stateParams.productID,
      product: {},
      specificationModal: null,
      makeRequestModal: null,
      init: function() {
        this.loadSpecificationsModal();
        return this.loadMakeRequestModal();
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
      loadMakeRequestModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/make-request.html', {
          scope: $scope,
          animation: 'slide-in-up'
        }).then((function(_this) {
          return function(modal) {
            return _this.makeRequestModal = modal;
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
          return this.makeRequestModal.show();
        } else {
          return App.navigate('verify-begin');
        }
      },
      getCurrentLocation: function() {
        CToast.show('Getting current location');
        return GPS.getCurrentLocation().then((function(_this) {
          return function(loc) {
            var latLng;
            return latLng = new google.maps.LatLng(loc.lat, loc.long);
          };
        })(this), function(err) {
          return CToast.show('Error locating your position');
        });
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
          controller: 'SingleProductCtrl',
          resolve: {
            Maps: function(GoogleMaps) {
              if (typeof google === "undefined") {
                return GoogleMaps.loadScript();
              }
            }
          }
        }
      }
    });
  }
]);
