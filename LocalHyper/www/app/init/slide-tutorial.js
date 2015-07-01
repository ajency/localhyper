angular.module('LocalHyper.init').controller('SlideTutorialCtrl', [
  '$scope', 'App', 'Storage', function($scope, App, Storage) {
    $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
    return $scope.onGetStarted = function() {
      return Storage.slideTutorial('set').then(function() {
        return App.navigate("departments", {}, {
          animate: false,
          back: false
        });
      });
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('tutorial', {
      url: '/tutorial',
      templateUrl: 'views/slide-tutorial.html',
      controller: 'SlideTutorialCtrl'
    });
  }
]);
