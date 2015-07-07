angular.module('LocalHyper.products', []).controller('ProductsCtrl', [
  '$scope', 'ProductsAPI', '$stateParams', 'Product', function($scope, ProductsAPI, $stateParams, Product) {
    return $scope.view = {
      title: Product.subCategoryTitle,
      products: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
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
        this.canLoadMore = true;
        this.page = 0;
        this.refresh = true;
        return this.getProducts();
      },
      onInfiniteScroll: function() {
        this.refresh = false;
        return this.getProducts();
      },
      getProducts: function() {
        return ProductsAPI.getAll({
          categoryID: $stateParams.categoryID,
          page: this.page
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
      }
    };
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
