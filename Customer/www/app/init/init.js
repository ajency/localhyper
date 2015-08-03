angular.module('LocalHyper.init', []).controller('InitCtrl', [
  '$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', 'Storage', function($ionicPlatform, $scope, App, Push, $rootScope, Storage) {
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
        goto = _.isNull(value) ? "tutorial" : "categories";
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
      cache: false,
      controller: 'InitCtrl',
      templateUrl: 'views/init/init.html'
    });
    return $urlRouterProvider.otherwise('/init');
  }
]);
