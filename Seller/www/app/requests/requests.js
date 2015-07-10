angular.module('LocalHyper.requests', []).controller('RequestCtrl', [
  '$scope', 'App', function($scope, App) {
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('requests', {
      url: '/requests',
      parent: 'main',
      views: {
        "appContent": {
          controller: 'RequestCtrl',
          templateUrl: 'views/requests/requests.html'
        }
      }
    });
  }
]);
