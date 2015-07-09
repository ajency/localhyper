angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.businessDetails', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.brands', 'LocalHyper.googleMaps']).run([
  '$rootScope', 'App', 'Push', '$timeout', function($rootScope, App, Push, $timeout) {
    Parse.initialize(APP_ID, JS_KEY);
    $rootScope.App = App;
    App.notification = {
      icon: false
    };
    App.logo = {
      small: true
    };
    return $rootScope.$on('$stateChangeSuccess', function(ev, to, toParams, from, fromParams) {
      var bool, hideForStates;
      App.previousState = from.name;
      App.currentState = to.name;
      hideForStates = ['tutorial', 'business-details', 'verify-begin', 'verify-auto', 'verify-manual', 'categories', 'sub-categories', 'brands'];
      bool = !_.contains(hideForStates, App.currentState);
      App.menuEnabled.left = bool;
      return App.notification.icon = bool;
    });
  }
]).config([
  '$ionicConfigProvider', function($ionicConfigProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    return $ionicConfigProvider.navBar.alignTitle('center');
  }
]);
