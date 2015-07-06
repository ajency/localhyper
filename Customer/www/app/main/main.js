angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', function($scope, App) {
    return $scope.view = {
      onBackClick: function() {
        var count;
        if (App.currentState === 'verify-manual') {
          count = App.isAndroid() ? -2 : -1;
        } else {
          count = -1;
        }
        return App.goBack(count);
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('main', {
      url: '/main',
      abstract: true,
      cache: false,
      templateUrl: 'views/main.html'
    });
  }
]);
