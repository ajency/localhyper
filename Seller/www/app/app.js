angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.businessDetails', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.brands', 'LocalHyper.googleMaps', 'LocalHyper.requestsOffers']).run([
  '$rootScope', 'App', 'Push', '$timeout', 'GoogleMaps', function($rootScope, App, Push, $timeout, GoogleMaps) {
    Parse.initialize(APP_ID, JS_KEY);
    $rootScope.App = App;
    GoogleMaps.loadScript();
    App.notification = {
      icon: false,
      badge: false,
      count: 0,
      increment: function() {
        this.badge = true;
        return this.count = this.count + 1;
      },
      decrement: function() {
        this.count = this.count - 1;
        if (this.count === 0) {
          return this.badge = false;
        }
      }
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
      App.notification.icon = bool;
      return App.logo.small = App.currentState !== 'requests';
    });
  }
]).config([
  '$ionicConfigProvider', function($ionicConfigProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    $ionicConfigProvider.navBar.alignTitle('center');
    return $ionicConfigProvider.tabs.position('top');
  }
]);
