angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.auth']).run([
  '$rootScope', 'App', function($rootScope, App) {
    return $rootScope.App = App;
  }
]).controller('InitCtrl', [
  '$ionicPlatform', '$scope', 'App', function($ionicPlatform, $scope, App) {
    return $ionicPlatform.ready(function() {
      App.hideKeyboardAccessoryBar();
      App.setStatusBarStyle();
      return App.navigate('start', {}, {
        animate: false,
        back: false
      });
    });
  }
]).config([
  '$stateProvider', '$ionicConfigProvider', '$urlRouterProvider', function($stateProvider, $ionicConfigProvider, $urlRouterProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    $stateProvider.state('init', {
      url: '/init',
      controller: 'InitCtrl',
      templateUrl: 'views/init.html'
    });
    return $urlRouterProvider.otherwise('/init');
  }
]);
