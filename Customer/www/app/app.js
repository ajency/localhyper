angular.module('LocalHyper', ['ionic', 'ngCordova', 'ngIOS9UIWebViewPatch', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products', 'LocalHyper.aboutUs', 'LocalHyper.googleMaps', 'LocalHyper.suggestProduct', 'LocalHyper.myRequests', 'ionic.rating']).run([
  '$rootScope', 'App', 'User', '$timeout', function($rootScope, App, User, $timeout) {
    Parse.initialize(APP_ID, JS_KEY);
    $rootScope.App = App;
    App.notification = {
      icon: User.isLoggedIn(),
      openRequests: 0,
      offers: 0,
      badge: false,
      count: 0,
      increment: function() {
        this.badge = true;
        return this.count = this.count + 1;
      },
      decrement: function() {
        this.count = this.count - 1;
        if (this.count <= 0) {
          return this.badge = false;
        }
      }
    };
    App.logo = {
      small: true
    };
    App.search = {
      icon: false,
      categoryID: ''
    };
    return $rootScope.$on('$stateChangeSuccess', function(ev, to, toParams, from, fromParams) {
      var bool, hideForStates, showSearchForStates;
      App.previousState = from.name;
      App.currentState = to.name;
      hideForStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual'];
      bool = !_.contains(hideForStates, App.currentState);
      App.menuEnabled.left = bool;
      showSearchForStates = ['products', 'single-product'];
      if (_.contains(showSearchForStates, App.currentState)) {
        return $timeout(function() {
          return App.search.icon = true;
        }, 500);
      } else {
        return App.search.icon = false;
      }
    });
  }
]).config([
  '$ionicConfigProvider', function($ionicConfigProvider) {
    $ionicConfigProvider.views.swipeBackEnabled(false);
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    $ionicConfigProvider.navBar.alignTitle('center');
    return $ionicConfigProvider.tabs.style('striped').position('top');
  }
]);
