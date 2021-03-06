angular.module('LocalHyper.init', []).controller('InitCtrl', [
  '$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', 'Storage', 'User', function($ionicPlatform, $scope, App, Push, $rootScope, Storage, User) {
    $rootScope.$on('$cordovaPush:notificationReceived', function(e, p) {
      var payload;
      payload = Push.getPayload(p);
      if (!_.isEmpty(payload)) {
        return Push.handlePayload(payload);
      }
    });
    return $ionicPlatform.ready(function() {
      App.hideKeyboardAccessoryBar();
      App.setStatusBarStyle();
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
