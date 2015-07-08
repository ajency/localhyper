angular.module('LocalHyper.aboutUs', []).controller('AboutUsCtrl', ['$scope', function($scope) {}]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('about-us', {
      url: '/about-us',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'AboutUsCtrl',
          templateUrl: 'views/about-us.html'
        }
      }
    });
  }
]);
