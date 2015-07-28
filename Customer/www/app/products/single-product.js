angular.module('LocalHyper.products').controller('SingleProductCtrl', [
  '$scope', '$stateParams', 'ProductsAPI', 'User', 'CToast', 'App', '$ionicModal', 'GoogleMaps', 'CSpinner', '$rootScope', 'RequestAPI', function($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GoogleMaps, CSpinner, $rootScope, RequestAPI) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      footer: false,
      productID: $stateParams.productID,
      product: {},
      request: {
        active: false,
        check: function() {
          this.active = false;
          if (User.isLoggedIn()) {
            return this.active = !_.isEmpty($scope.view.product.activeRequest);
          }
        }
      },
      requests: {
        all: []
      },
      reset: function() {
        this.display = 'loader';
        this.footer = false;
        this.requests.all = [];
        return this.getSingleProductDetails();
      },
      getSingleProductDetails: function() {
        return ProductsAPI.getSingleProduct(this.productID).then((function(_this) {
          return function(productData) {
            _this.product = productData;
            return ProductsAPI.getNewOffers(_this.productID);
          };
        })(this)).then((function(_this) {
          return function(details) {
            _.each(details, function(val, key) {
              return _this.product[key] = val;
            });
            console.log(_this.product);
            return _this.onSuccess();
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this));
      },
      onSuccess: function() {
        this.footer = true;
        App.resize();
        this.request.check();
        this.display = 'noError';
        return this.getRequests();
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getSingleProductDetails();
      },
      getPrimaryAttrs: function() {
        var attrs, unit, value;
        if (!_.isUndefined(this.product.primaryAttributes)) {
          attrs = this.product.primaryAttributes[0];
          value = s.humanize(attrs.value);
          unit = '';
          if (_.has(attrs.attribute, 'unit')) {
            unit = s.humanize(attrs.attribute.unit);
          }
          return value + " " + unit;
        } else {
          return '';
        }
      },
      checkUserLogin: function() {
        if (!User.isLoggedIn()) {
          return App.navigate('verify-begin');
        } else if (_.isUndefined(window.google)) {
          CSpinner.show('', 'Please wait...');
          return GoogleMaps.loadScript().then((function(_this) {
            return function() {
              return _this.getBestPrices();
            };
          })(this), function(error) {
            return CToast.show('Error loading content, please check your network settings');
          })["finally"](function() {
            return CSpinner.hide();
          });
        } else {
          return this.getBestPrices();
        }
      },
      getBestPrices: function() {
        ProductsAPI.productDetails('set', this.product);
        return App.navigate('make-request');
      },
      getRequests: function() {
        var params;
        params = {
          productId: this.productID,
          page: 0,
          openStatus: true
        };
        return RequestAPI.get(params).then((function(_this) {
          return function(data) {
            console.log('getRequests');
            console.log(data);
            return _this.requests.all = data;
          };
        })(this))["finally"](function() {
          return App.resize();
        });
      }
    };
    $rootScope.$on('make:request:success', function() {
      return $scope.view.request.active = true;
    });
    return $scope.$on('$ionicView.beforeEnter', function() {
      if (_.contains(['products', 'verify-success'], App.previousState)) {
        return $scope.view.reset();
      }
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
