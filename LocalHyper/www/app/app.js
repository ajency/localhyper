angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.products', 'LocalHyper.test']).run([
  '$rootScope', 'App', 'Push', '$timeout', function($rootScope, App, Push, $timeout) {
    Parse.initialize('bv6HajGGe6Ver72lkjIiV0jYbJL5ll0tTWNG3obY', 'uxqIu6soZAOzPXHuLQDhOwBuA3KWAAuuK75l1Z3x');
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
    return $ionicConfigProvider.backButton.previousTitleText(false).text('');
  }
]);
