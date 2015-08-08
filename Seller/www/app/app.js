angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.businessDetails', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.brands', 'LocalHyper.googleMaps', 'LocalHyper.requestsOffers', 'LocalHyper.requestsOffers', 'LocalHyper.profile', 'LocalHyper.aboutUs', 'LocalHyper.suggestProduct', 'LocalHyper.creditHistory']).run([
  '$rootScope', 'App', 'Push', '$timeout', 'GoogleMaps', 'User', function($rootScope, App, Push, $timeout, GoogleMaps, User) {
    Parse.initialize(APP_ID, JS_KEY);
    $rootScope.App = App;
    App.notification = {
      icon: false,
      newRequests: 0,
      accptedOffers: 0,
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
    return $rootScope.$on('$stateChangeSuccess', function(ev, to, toParams, from, fromParams) {
      var bool, businessDetails, hideForStates;
      App.previousState = from.name;
      App.currentState = to.name;
      if (App.currentState === 'business-details') {
        businessDetails = User.isLoggedIn() ? '' : 'business-details';
        console.log(businessDetails);
      }
      hideForStates = ['tutorial', businessDetails, 'verify-begin', 'verify-auto', 'verify-manual', 'categories', 'sub-categories', 'brands', 'category-chains'];
      bool = !_.contains(hideForStates, App.currentState);
      App.menuEnabled.left = bool;
      return App.notification.icon = bool;
    });
  }
]).config([
  '$ionicConfigProvider', function($ionicConfigProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    $ionicConfigProvider.navBar.alignTitle('center');
    return $ionicConfigProvider.tabs.style('striped').position('top');
  }
]);
