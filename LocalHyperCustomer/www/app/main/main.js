angular.module('LocalHyper.main', []).controller('SideMenuCtrl', ['$scope', function($scope) {}]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('main', {
      url: '/main',
      abstract: true,
      templateUrl: 'views/main.html'
    });
  }
]);
