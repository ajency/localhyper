angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage', 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products', 'LocalHyper.test']).constant('PARSE', {
  APP_ID: 'bv6HajGGe6Ver72lkjIiV0jYbJL5ll0tTWNG3obY',
  JS_KEY: 'uxqIu6soZAOzPXHuLQDhOwBuA3KWAAuuK75l1Z3x'
}).run([
  '$rootScope', 'App', 'Push', '$timeout', 'PARSE', function($rootScope, App, Push, $timeout, PARSE) {
    Parse.initialize(PARSE.APP_ID, PARSE.JS_KEY);
    $rootScope.App = App;
    $rootScope.product = {
      offers: [],
      globalNotification: false,
      localNotification: false,
      request: ''
    };
    return $rootScope.$on('$stateChangeSuccess', function(ev, to, toParams, from, fromParams) {
      var hideMenuStates;
      $rootScope.previousState = from.name;
      $rootScope.currentState = to.name;
      hideMenuStates = ['start', 'login', 'sign-up'];
      if (_.contains(hideMenuStates, $rootScope.currentState)) {
        App.menuEnabled.left = false;
      } else {
        App.menuEnabled.left = true;
      }
      if ($rootScope.currentState === 'requests') {
        return $timeout(function() {
          return $rootScope.product.localNotification = false;
        }, 500);
      }
    });
  }
]).config([
  '$ionicConfigProvider', function($ionicConfigProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    return $ionicConfigProvider.navBar.alignTitle('center');
  }
]);
