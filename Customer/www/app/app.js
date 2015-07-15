angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products', 'LocalHyper.test', 'LocalHyper.aboutUs', 'LocalHyper.googleMaps']).run([
  '$rootScope', 'App', 'Push', '$timeout', 'GoogleMaps', function($rootScope, App, Push, $timeout, GoogleMaps) {
    Parse.initialize(APP_ID, JS_KEY);
    $rootScope.App = App;
    GoogleMaps.loadScript();
    $rootScope.product = {
      offers: [],
      globalNotification: false,
      localNotification: false,
      request: ''
    };
    App.notification = {
      icon: false
    };
    App.logo = {
      small: true
    };
    return $rootScope.$on('$stateChangeSuccess', function(ev, to, toParams, from, fromParams) {
      var bool, hideForStates;
      $rootScope.previousState = from.name;
      $rootScope.currentState = to.name;
      App.previousState = from.name;
      App.currentState = to.name;
      hideForStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual'];
      bool = !_.contains(hideForStates, App.currentState);
      App.menuEnabled.left = bool;
      App.notification.icon = bool;
      return App.logo.small = App.currentState !== 'categories';
    });
  }
]).config([
  '$ionicConfigProvider', function($ionicConfigProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    return $ionicConfigProvider.navBar.alignTitle('center');
  }
]);
