angular.module('LocalHyper.products', []).controller('ProductsCtrl', [
  '$scope', 'ProductsAPI', '$stateParams', 'Product', '$ionicModal', '$timeout', 'App', 'CToast', 'UIMsg', function($scope, ProductsAPI, $stateParams, Product, $ionicModal, $timeout, App, CToast, UIMsg) {
    $scope.view = {
      title: Product.subCategoryTitle,
      products: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      sortModal: null,
      sortBy: 'popularity',
      ascending: true,
      init: function() {
        return this.loadSortModal();
      },
      reset: function() {
        this.products = [];
        this.page = 0;
        this.canLoadMore = true;
        this.refresh = false;
        this.sortBy = 'popularity';
        this.ascending = true;
        return this.onScrollComplete();
      },
      loadSortModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/sort.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.sortModal = modal;
          };
        })(this));
      },
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onRefreshComplete: function() {
        return $scope.$broadcast('scroll.refreshComplete');
      },
      incrementPage: function() {
        return this.page = this.page + 1;
      },
      onPullToRefresh: function() {
        if (App.isOnline()) {
          this.canLoadMore = true;
          this.page = 0;
          this.refresh = true;
          return this.getProducts();
        } else {
          this.onRefreshComplete();
          return CToast.show(UIMsg.noInternet);
        }
      },
      onInfiniteScroll: function() {
        this.refresh = false;
        return this.getProducts();
      },
      getProducts: function() {
        return ProductsAPI.getAll({
          categoryID: $stateParams.categoryID,
          page: this.page,
          sortBy: this.sortBy,
          ascending: this.ascending
        }).then((function(_this) {
          return function(data) {
            console.log(data);
            return _this.onSuccess(data);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"]((function(_this) {
          return function() {
            _this.incrementPage();
            return _this.onRefreshComplete();
          };
        })(this));
      },
      onError: function(error) {
        console.log(error);
        return this.canLoadMore = false;
      },
      onSuccess: function(data) {
        var _products;
        _products = data.products;
        if (_.size(_products) > 0) {
          if (_.size(_products) < 10) {
            this.canLoadMore = false;
          } else {
            this.onScrollComplete();
          }
          if (this.refresh) {
            return this.products = _products;
          } else {
            return this.products = this.products.concat(_products);
          }
        } else {
          return this.canLoadMore = false;
        }
      },
      getPrimaryAttrs: function(attrs) {
        var unit, value;
        attrs = attrs[0];
        value = s.humanize(attrs.value);
        unit = '';
        if (_.has(attrs.attribute, 'unit')) {
          unit = s.humanize(attrs.attribute.unit);
        }
        return "" + value + " " + unit;
      },
      onSort: function(sortBy, ascending) {
        var reFetch;
        this.sortModal.hide();
        reFetch = (function(_this) {
          return function() {
            _this.page = 0;
            _this.refresh = true;
            _this.products = [];
            _this.canLoadMore = true;
            return _this.onScrollComplete();
          };
        })(this);
        switch (sortBy) {
          case 'popularity':
            if (this.sortBy !== 'popularity') {
              this.sortBy = 'popularity';
              this.ascending = true;
              return reFetch();
            }
            break;
          case 'mrp':
            if (this.sortBy !== 'mrp') {
              this.sortBy = 'mrp';
              this.ascending = ascending;
              return reFetch();
            } else if (this.ascending !== ascending) {
              this.sortBy = 'mrp';
              this.ascending = ascending;
              return reFetch();
            }
        }
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function() {
      if (App.previousState === 'sub-categories') {
        return $scope.view.reset();
      }
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('products', {
      url: '/products:categoryID',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/products.html',
          controller: 'ProductsCtrl',
          resolve: {
            Product: function($stateParams, CategoriesAPI) {
              var childCategory, subCategories;
              subCategories = CategoriesAPI.subCategories('get');
              childCategory = _.filter(subCategories, function(category) {
                return category.id === $stateParams.categoryID;
              });
              return {
                subCategoryTitle: childCategory[0].name
              };
            }
          }
        }
      }
    });
  }
]);
