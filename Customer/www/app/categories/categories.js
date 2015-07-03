angular.module('LocalHyper.categories', []).controller('CategoriesCtrl', [
  '$scope', 'App', '$ionicPopover', 'CategoriesAPI', function($scope, App, $ionicPopover, CategoriesAPI) {
    var getCategories;
    $scope.view = {
      display: 'loader',
      errorMsg: '',
      parentCategories: [],
      onSuccess: function(data) {
        this.display = 'noError';
        return this.parentCategories = data;
      },
      onError: function(msg) {
        this.display = 'error';
        return this.errorMsg = msg;
      }
    };
    $ionicPopover.fromTemplateUrl('views/right-popover.html', {
      scope: $scope
    }).then(function(popover) {
      return $scope.rightPopover = popover;
    });
    $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
    $scope.openRightPopover = function($event) {
      return $scope.rightPopover.show($event);
    };
    getCategories = function() {
      return CategoriesAPI.getAll().then(function(data) {
        console.log(data);
        return $scope.view.onSuccess(data);
      }, function(error) {
        return $scope.view.onError('Could not connect to server');
      });
    };
    $scope.onTryAgain = function() {
      $scope.view.display = 'loader';
      return getCategories();
    };
    if (App.isOnline()) {
      return getCategories();
    } else {
      return $scope.view.onError('No internet availability');
    }
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
