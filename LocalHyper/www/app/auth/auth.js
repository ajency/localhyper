angular.module('LocalHyper.auth', []).controller('StartCtrl', [
  '$scope', 'App', function($scope, App) {
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('start', {
      url: '/start',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/auth/start.html',
          controller: 'StartCtrl'
        }
      }
    }).state('login', {
      url: '/login',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'LoginCtrl',
          templateUrl: 'views/auth/login.html'
        }
      }
    }).state('sign-up', {
      url: '/signup',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'SignUpCtrl',
          templateUrl: 'views/auth/sign-up.html'
        }
      }
    });
  }
]);
