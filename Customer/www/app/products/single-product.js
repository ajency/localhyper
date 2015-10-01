angular.module('LocalHyper.products').controller('SingleProductCtrl', [
  '$scope', '$stateParams', 'ProductsAPI', 'User', 'CToast', 'App', '$ionicModal', 'GoogleMaps', 'CSpinner', '$rootScope', 'RequestAPI', '$ionicScrollDelegate', '$ionicPlatform', 'PrimaryAttribute', '$cordovaNetwork', function($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GoogleMaps, CSpinner, $rootScope, RequestAPI, $ionicScrollDelegate, $ionicPlatform, PrimaryAttribute, $cordovaNetwork) {
    var onDeviceBack;
    $scope.view = {
      display: 'loader',
      errorType: '',
      footer: false,
      productID: $stateParams.productID,
      product: {},
      primaryAttribute: PrimaryAttribute,
      request: {
        page: 0,
        all: [],
        active: false,
        limitTo: 1,
        canLoadMore: false,
        display: 'none',
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
          this.canLoadMore = false;
          return this.display = 'none';
        },
        reFetch: function() {
          this.page = 0;
          this.all = [];
          this.limitTo = 1;
          this.canLoadMore = false;
          this.display = 'loader';
          this.get();
          return App.resize();
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
            requestType: 'all',
            selectedFilters: []
          };
          return RequestAPI.get(params).then((function(_this) {
            return function(data) {
              return _this.success(data, params.displayLimit);
            };
          })(this), (function(_this) {
            return function(error) {
              return _this.onError(error);
            };
          })(this))["finally"]((function(_this) {
            return function() {
              _this.page = _this.page + 1;
              return App.resize();
            };
          })(this));
        },
        success: function(data, limit) {
          this.display = 'noError';
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
        },
        onError: function(error) {
          console.log(error);
          this.display = 'error';
          return this.canLoadMore = false;
        },
        onTryAgain: function() {
          this.display = 'noError';
          this.page = 0;
          this.all = [];
          return this.canLoadMore = true;
        },
        onCardClick: function(request) {
          RequestAPI.requestDetails('set', request);
          return App.navigate('request-details');
        }
      },
      specifications: {
        modal: null,
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/products/specifications.html', {
            scope: $scope,
            animation: 'slide-in-up',
            hardwareBackButtonClose: false
          }).then((function(_this) {
            return function(modal) {
              return _this.modal = modal;
            };
          })(this));
        },
        openModal: function() {
          $ionicScrollDelegate.$getByHandle('specification-modal-handle').scrollTop(true);
          return this.modal.show();
        },
        set: function() {
          var general, generalSpecs, groups, warranty;
          groups = _.groupBy($scope.view.product.specifications, function(spec) {
            return spec.group;
          });
          general = groups['general'];
          generalSpecs = [];
          _.each(general, function(specs) {
            var str;
            if (_.isNull(specs.unit)) {
              str = App.humanize(specs.value);
            } else {
              str = (App.humanize(specs.value)) + " " + (App.humanize(specs.unit));
            }
            return generalSpecs.push(str);
          });
          this.excerpt = generalSpecs.join(', ');
          warranty = groups['warranty'];
          delete groups['general'];
          delete groups['warranty'];
          groups = _.toArray(groups);
          groups.unshift(general);
          if (!_.isUndefined(warranty)) {
            groups.push(warranty);
          }
          return this.groups = groups;
        }
      },
      init: function() {
        return this.specifications.loadModal();
      },
      reset: function() {
        this.display = 'loader';
        this.footer = false;
        this.request.reset();
        return this.getSingleProductDetails();
      },
      getDate: function(obj) {
        return moment(obj.iso).format('DD/MM/YYYY');
      },
      getSingleProductDetails: function() {
        return ProductsAPI.getSingleProduct(this.productID).then((function(_this) {
          return function(productData) {
            _this.product = productData;
            App.search.icon = true;
            App.search.categoryID = _this.product.category.id;
            App.search.categoryName = _this.product.category.name;
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
        this.specifications.set();
        this.request.checkIfActive();
        if (User.isLoggedIn()) {
          this.request.display = 'loader';
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
      checkNetwork: function() {
        if (App.isWebView() && !$cordovaNetwork.isOnline()) {
          return CToast.show('Error loading content, please check your network settings');
        } else {
          return this.getBestPrices();
        }
      },
      checkUserLogin: function() {
        if (!User.isLoggedIn()) {
          return App.navigate('verify-begin');
        } else if (_.isUndefined(window.google)) {
          CSpinner.show('', 'Please wait, loading resources');
          return GoogleMaps.loadScript().then((function(_this) {
            return function() {
              return _this.checkNetwork();
            };
          })(this), function(error) {
            return CToast.show('Error loading content, please check your network settings');
          })["finally"](function() {
            return CSpinner.hide();
          });
        } else {
          return this.checkNetwork();
        }
      },
      getBestPrices: function() {
        ProductsAPI.productDetails('set', this.product);
        return App.navigate('make-request');
      }
    };
    onDeviceBack = function() {
      var specificationModal;
      specificationModal = $scope.view.specifications.modal;
      if (!_.isNull(specificationModal) && specificationModal.isShown()) {
        return specificationModal.hide();
      } else {
        return App.goBack(-1);
      }
    };
    $scope.$on('$ionicView.enter', function() {
      return $ionicPlatform.onHardwareBackButton(onDeviceBack);
    });
    $scope.$on('$ionicView.leave', function() {
      return $ionicPlatform.offHardwareBackButton(onDeviceBack);
    });
    $rootScope.$on('make:request:success', function() {
      $scope.view.request.active = true;
      return $scope.view.request.reFetch();
    });
    $rootScope.$on('request:cancelled', function() {
      return $scope.view.request.active = false;
    });
    $rootScope.$on('offer:accepted', function() {
      return $scope.view.request.active = false;
    });
    $rootScope.$on('on:session:expiry', function() {
      return $scope.view.reset();
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload, refetchFor;
      payload = obj.payload;
      refetchFor = ['new_offer', 'request_delivery_changed'];
      if (_.contains(refetchFor, payload.type)) {
        return $scope.view.request.reFetch();
      }
    });
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (_.contains(['products', 'verify-success', 'products-search', 'my-requests', 'requests-history', 'request-details'], App.previousState)) {
        if (!viewData.enableBack) {
          viewData.enableBack = true;
        }
        $ionicScrollDelegate.$getByHandle('single-product-handle').scrollTop(true);
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
