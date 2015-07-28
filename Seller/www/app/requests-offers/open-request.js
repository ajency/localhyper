angular.module('LocalHyper.requestsProducts', []).controller('OpenRequestCtrl', [
  '$scope', 'App', function($scope, App) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      parentCategories: [],
      init: function() {
        return this.getCategories();
      },
      getCategories: function() {
        return CategoriesAPI.getAll().then((function(_this) {
          return function(data) {
            console.log(data);
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
        return this.parentCategories = data;
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getCategories();
      },
      onSubcategoryClick: function(children, categoryID) {
        CategoriesAPI.subCategories('set', children);
        return App.navigate('products', {
          categoryID: categoryID
        });
      }
    };
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]);
