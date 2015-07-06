angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products', 'LocalHyper.test']).run([
  '$rootScope', 'App', 'Push', '$timeout', function($rootScope, App, Push, $timeout) {
    Parse.initialize(APP_ID, JS_KEY);
    $rootScope.App = App;
    App.notification = {
      icon: false
    };
    return $rootScope.$on('$stateChangeSuccess', function(ev, to, toParams, from, fromParams) {
      var bool, hideForStates;
      $rootScope.previousState = from.name;
      $rootScope.currentState = to.name;
      App.previousState = from.name;
      App.currentState = to.name;
      hideForStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual'];
      bool = _.contains(hideForStates, App.currentState);
      App.menuEnabled.left = !bool;
      return App.notification.icon = !bool;
    });
  }
]).config([
  '$ionicConfigProvider', function($ionicConfigProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    return $ionicConfigProvider.navBar.alignTitle('center');
  }
]);
