angular.module('LocalHyper.products').controller('SingleProductCtrl', [
  '$scope', '$stateParams', 'ProductsAPI', 'User', 'CToast', 'App', '$ionicModal', 'GoogleMaps', 'CSpinner', '$rootScope', 'RequestAPI', function($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GoogleMaps, CSpinner, $rootScope, RequestAPI) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      footer: false,
      productID: $stateParams.productID,
      product: {},
      request: {
        page: 0,
        all: [],
        active: false,
        limitTo: 1,
        canLoadMore: false,
        onScrollComplete: function() {
          return $scope.$broadcast('scroll.infiniteScrollComplete');
        },
        checkIfActive: function() {
          this.active = false;
          if (User.isLoggedIn()) {
            return this.active = !_.isEmpty($scope.view.product.activeRequest);
          }
        },
        reset: function() {
          this.page = 0;
          this.all = [];
          this.active = false;
          this.limitTo = 1;
          return this.canLoadMore = false;
        },
        showAllRequests: function() {
          this.limitTo = 1000;
          this.canLoadMore = true;
          return App.scrollBottom();
        },
        get: function() {
          var params;
          params = {
            productId: $scope.view.productID,
            page: this.page,
            displayLimit: 2,
            openStatus: false
          };
          return RequestAPI.get(params).then((function(_this) {
            return function(data) {
              return _this.success(data, params.displayLimit);
            };
          })(this), (function(_this) {
            return function(error) {
              return console.log(error);
            };
          })(this))["finally"]((function(_this) {
            return function() {
              _this.page = _this.page + 1;
              return App.resize();
            };
          })(this));
        },
        success: function(data, limit) {
          if (_.size(data) > 0) {
            if (_.size(data) < limit) {
              this.canLoadMore = false;
            } else {
              this.onScrollComplete();
            }
            return this.all = this.all.concat(data);
          } else {
            return this.canLoadMore = false;
          }
        }
      },
      reset: function() {
        this.display = 'loader';
        this.footer = false;
        this.request.reset();
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
            return _this.onSuccess();
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"](function() {
          return App.resize();
        });
      },
      onSuccess: function() {
        this.footer = true;
        this.display = 'noError';
        this.request.checkIfActive();
        if (User.isLoggedIn()) {
          return this.request.get();
        }
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
      }
    };
    $rootScope.$on('make:request:success', function() {
      return $scope.view.request.active = true;
    });
    $rootScope.$on('on:session:expiry', function() {
      return $scope.view.reset();
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
