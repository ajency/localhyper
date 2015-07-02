angular.module('LocalHyper.init', []).controller('InitCtrl', [
  '$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', 'Storage', function($ionicPlatform, $scope, App, Push, $rootScope, Storage) {
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
          console.log(productOffers);
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
      Storage.slideTutorial('get').then(function(value) {
        var goto;
        goto = _.isNull(value) ? "tutorial" : "categories";
        return App.navigate(goto, {}, {
          animate: false,
          back: false
        });
      });
      return Push.register();
    });
  }
]).config([
  '$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    $stateProvider.state('init', {
      url: '/init',
      controller: 'InitCtrl',
      templateUrl: 'views/init/init.html'
    });
    return $urlRouterProvider.otherwise('/init');
  }
]);
