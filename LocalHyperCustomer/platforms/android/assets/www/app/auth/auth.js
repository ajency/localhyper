angular.module('LocalHyper.auth', []).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('register', {
      url: '/register',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'RegisterCtrl',
          templateUrl: 'views/auth/register.html'
        }
      }
    });
  }
]);
