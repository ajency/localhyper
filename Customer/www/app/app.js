angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products', 'LocalHyper.aboutUs', 'LocalHyper.googleMaps', 'LocalHyper.suggestProduct', 'LocalHyper.profile', 'LocalHyper.myRequests']).run([
  '$rootScope', 'App', 'GoogleMaps', 'User', function($rootScope, App, GoogleMaps, User) {
    Parse.initialize(APP_ID, JS_KEY);
    $rootScope.App = App;
    GoogleMaps.loadScript();
    App.notification = {
      icon: User.isLoggedIn(),
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
      hideForStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual'];
      bool = !_.contains(hideForStates, App.currentState);
      return App.menuEnabled.left = bool;
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
