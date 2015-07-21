angular.module('LocalHyper.profile', []).controller('ProfileCtrl', ['$scope', function($scope) {}]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('profile', {
      url: '/verify-begin',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'ProfileCtrl',
          templateUrl: 'views/profile.html'
        }
      }
    });
  }
]);
