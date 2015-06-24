angular.module('LocalHyper', ['ionic', 'ngCordova', 'LocalHyper.common', 'LocalHyper.auth', 'LocalHyper.test']).run([
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
      $rootScope.previousState = from.name;
      $rootScope.currentState = to.name;
      if ($rootScope.currentState === 'requests') {
        return $timeout(function() {
          return $rootScope.product.localNotification = false;
        }, 500);
      }
    });
  }
]).controller('InitCtrl', [
  '$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', function($ionicPlatform, $scope, App, Push, $rootScope) {
    var getOffers;
    getOffers = function() {
      var Offers, ids, productOffers, query;
      Offers = Parse.Object.extend("Offers");
      query = new Parse.Query(Offers);
      productOffers = $rootScope.product.offers;
      if (!_.isEmpty(productOffers)) {
        ids = _.pluck(productOffers, 'id');
        query.notContainedIn("objectId", ids);
      }
      return query.find().then(function(offers) {
        _.each(offers, function(offer, i) {
          var obj;
          obj = {
            id: offer.id,
            request: offer.get('request'),
            location: offer.get('location'),
            price: offer.get('price'),
            deliveryTime: offer.get('deliveryTime'),
            updatedAt: offer.get('updatedAt')
          };
          return productOffers = productOffers.concat(obj);
        });
        return $scope.$apply(function() {
          return $rootScope.product.offers = productOffers;
        });
      });
    };
    getOffers();
    $rootScope.$on('$cordovaPush:notificationReceived', function(e, p) {
      var payload;
      payload = Push.getPayload(p);
      console.log(payload);
      if (!_.has(payload, 'coldstart')) {
        getOffers();
      }
      if (_.has(payload, 'coldstart') && payload.coldstart === true) {
        return getOffers();
      }
    });
    $rootScope.$watch('product.offers', function(newOffers, oldOffers) {
      var latestOffer;
      if ((_.size(newOffers) !== _.size(oldOffers)) && !$rootScope.App.start) {
        if ($rootScope.currentState === 'offers') {
          latestOffer = _.last(newOffers);
          if (latestOffer.request !== $rootScope.product.request) {
            $rootScope.product.globalNotification = true;
          } else if (latestOffer.request === $rootScope.product.request) {
            $rootScope.product.localNotification = true;
          }
        } else {
          $rootScope.product.globalNotification = true;
        }
      }
      return $rootScope.App.start = false;
    });
    return $ionicPlatform.ready(function() {
      App.hideKeyboardAccessoryBar();
      App.setStatusBarStyle();
      App.navigate('start', {}, {
        animate: false,
        back: false
      });
      return Push.register();
    });
  }
]).config([
  '$stateProvider', '$ionicConfigProvider', '$urlRouterProvider', function($stateProvider, $ionicConfigProvider, $urlRouterProvider) {
    $ionicConfigProvider.views.forwardCache(true);
    $ionicConfigProvider.backButton.previousTitleText(false).text('');
    $stateProvider.state('init', {
      url: '/init',
      controller: 'InitCtrl',
      templateUrl: 'views/init.html'
    });
    return $urlRouterProvider.otherwise('/init');
  }
]);
