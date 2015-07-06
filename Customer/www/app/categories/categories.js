angular.module('LocalHyper.categories', []).controller('CategoriesCtrl', [
  '$scope', 'App', '$ionicPopover', 'CategoriesAPI', function($scope, App, $ionicPopover, CategoriesAPI) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      userPopover: null,
      parentCategories: [],
      loadPopOver: function() {
        return $ionicPopover.fromTemplateUrl('views/right-popover.html', {
          scope: $scope
        }).then((function(_this) {
          return function(popover) {
            return _this.userPopover = popover;
          };
        })(this));
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
      }
    };
    $scope.$on('$ionicView.enter', function() {
      $scope.view.loadPopOver();
      return $scope.view.getCategories();
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('categories', {
      url: '/categories',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/categories/categories.html',
          controller: 'CategoriesCtrl'
        }
      }
    });
  }
]);
