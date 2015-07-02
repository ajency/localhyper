angular.module('LocalHyper.categories', []).controller('CategoriesCtrl', [
  '$scope', 'App', '$ionicPopover', function($scope, App, $ionicPopover) {
    $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
    $ionicPopover.fromTemplateUrl('views/right-popover.html', {
      scope: $scope
    }).then(function(popover) {
      return $scope.rightPopover = popover;
    });
    return $scope.openRightPopover = function($event) {
      return $scope.rightPopover.show($event);
    };
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
