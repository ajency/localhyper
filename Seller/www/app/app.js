angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.businessDetails', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.brands', 'LocalHyper.googleMaps', 'LocalHyper.requestsOffers', 'LocalHyper.requestsOffers', 'LocalHyper.profile', 'LocalHyper.aboutUs', 'LocalHyper.suggestProduct', 'LocalHyper.creditHistory']).run([
  '$rootScope', 'App', 'Push', '$timeout', 'User', function($rootScope, App, Push, $timeout, User) {
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
      var bool, brands, business_details, categories, hideForStates, sub_categories;
      App.previousState = from.name;
      App.currentState = to.name;
      switch (App.currentState) {
        case 'business-details':
          business_details = User.isLoggedIn() ? '' : 'business-details';
          break;
        case 'brands':
          brands = User.isLoggedIn() ? '' : 'brands';
          break;
        case 'categories':
          categories = User.isLoggedIn() ? '' : 'categories';
          break;
        case 'sub-categories':
          sub_categories = User.isLoggedIn() ? '' : 'sub-categories';
      }
      hideForStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual', 'category-chains', categories, sub_categories, business_details, brands];
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
