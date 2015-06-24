angular.module('LocalHyper.test').controller('OffersCtrl', [
  '$scope', '$rootScope', function($scope, $rootScope) {
    var unbindOffersWatch;
    $scope.view = {
      offers: []
    };
    $rootScope.checkGlobalNotification();
    unbindOffersWatch = $rootScope.$watch('product.offers', function(newOffers) {
      var offers;
      if (!_.isEmpty(newOffers)) {
        offers = _.filter(newOffers, function(offer) {
          return offer.request === $rootScope.product.request;
        });
        return $scope.view.offers = offers;
      }
    });
    return $scope.$on('$ionicView.unloaded', function() {
      return unbindOffersWatch();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('offers', {
      url: '/offers',
      parent: 'auth',
      cache: false,
      views: {
        "authContent": {
          controller: 'OffersCtrl',
          templateUrl: 'views/offers.html'
        }
      }
    });
  }
]);
