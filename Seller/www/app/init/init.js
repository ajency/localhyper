angular.module('LocalHyper.init', []).controller('InitCtrl', [
  '$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', 'Storage', 'User', function($ionicPlatform, $scope, App, Push, $rootScope, Storage, User) {
    $rootScope.$on('$cordovaPush:notificationReceived', function(e, p) {
      return console.log(p);
    });
    return $ionicPlatform.ready(function() {
      App.hideKeyboardAccessoryBar();
      App.setStatusBarStyle();
      Push.register();
      return Storage.slideTutorial('get').then(function(value) {
        var goto;
        if (_.isNull(value)) {
          goto = "tutorial";
        } else if (User.isLoggedIn()) {
          goto = "new-requests";
        } else {
          goto = 'business-details';
        }
        return App.navigate(goto, {}, {
          animate: false,
          back: false
        });
      });
    });
  }
]).config([
  '$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    $stateProvider.state('init', {
      url: '/init',
      controller: 'InitCtrl',
      templateUrl: 'views/init/init.html'
    });
    return $urlRouterProvider.otherwise('/init');
  }
]);
