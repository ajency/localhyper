angular.module('LocalHyper.products').controller('SingleProductCtrl', [
  '$scope', '$stateParams', 'ProductsAPI', 'User', 'CToast', 'App', '$ionicModal', 'GPS', 'GoogleMaps', 'CSpinner', function($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GPS, GoogleMaps, CSpinner) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      productID: $stateParams.productID,
      product: {},
      specificationModal: null,
      makeRequestModal: null,
      addrReqComplete: true,
      latLng: null,
      address: null,
      fullAddress: '',
      init: function() {
        this.loadSpecificationsModal();
        return this.loadMakeRequestModal();
      },
      loadSpecificationsModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/specification.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.specificationModal = modal;
          };
        })(this));
      },
      loadMakeRequestModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/make-request.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
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
      checkUserLogin: function() {
        if (User.isLoggedIn()) {
          this.makeRequestModal.show();
          return this.getCurrentLocation();
        } else {
          return App.navigate('verify-begin');
        }
      },
      getCurrentLocation: function() {
        CToast.show('Getting current location');
        return GPS.getCurrentLocation().then((function(_this) {
          return function(loc) {
            _this.latLng = new google.maps.LatLng(loc.lat, loc.long);
            return _this.setAddress();
          };
        })(this), function(err) {
          return CToast.show('Error locating your position');
        });
      },
      setAddress: function() {
        this.addrReqComplete = false;
        return GoogleMaps.getAddress(this.latLng).then((function(_this) {
          return function(address) {
            _this.address = address;
            return _this.fullAddress = address.full;
          };
        })(this), function(error) {
          return console.log('Geocode error: ' + error);
        })["finally"]((function(_this) {
          return function() {
            return _this.addrReqComplete = true;
          };
        })(this));
      },
      beforeMakeRequest: function() {
        if (_.isNull(this.latLng) || !this.addrReqComplete) {
          return CToast.show('Please wait...');
        } else {
          return this.makeRequest();
        }
      },
      makeRequest: function() {
        var params;
        CSpinner.show('', 'Please wait...');
        params = {
          "customerId": User.getId(),
          "productId": this.productID,
          "location": {
            latitude: this.latLng.lat(),
            longitude: this.latLng.lng()
          },
          "categoryId": this.product.category.objectId,
          "brandId": this.product.brand.objectId,
          "address": this.address,
          "city": this.address.city,
          "area": this.address.city,
          "comments": "",
          "status": "open",
          "deliveryStatus": ""
        };
        return ProductsAPI.makeRequest(params).then((function(_this) {
          return function(res) {
            _this.makeRequestModal.hide();
            return CToast.show('Your request has been made');
          };
        })(this), function(error) {
          return CToast.show('Request failed, please try again');
        })["finally"](function() {
          return CSpinner.hide();
        });
      }
    };
    $scope.$on('$ionicView.loaded', function() {
      return $scope.view.getSingleProductDetails();
    });
    return $scope.$on('$destroy', function() {
      $scope.view.specificationModal.remove();
      return $scope.view.makeRequestModal.remove();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('single-product', {
      url: '/single-product:productID',
      parent: 'main',
      cache: false,
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
