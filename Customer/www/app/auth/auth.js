angular.module('LocalHyper.auth', []).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('verify-begin', {
      url: '/verify-begin',
      parent: 'main',
      views: {
        "appContent": {
          controller: 'VerifyBeginCtrl',
          templateUrl: 'views/auth/verify-begin.html'
        }
      }
    }).state('verify-auto', {
      url: '/verify-auto',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'VerifyAutoCtrl',
          templateUrl: 'views/auth/verify-auto.html'
        }
      }
    }).state('verify-manual', {
      url: '/verify-manual',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'VerifyManualCtrl',
          templateUrl: 'views/auth/verify-manual.html'
        }
      }
    }).state('verify-success', {
      url: '/verify-success',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'VerifySuccessCtrl',
          templateUrl: 'views/auth/verify-success.html'
        }
      }
    });
  }
]);
