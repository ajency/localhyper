angular.module('LocalHyper.test', []).controller('RequestCtrl', [
  '$scope', '$rootScope', 'App', function($scope, $rootScope, App) {
    $scope.view = {
      one: false,
      two: false,
      three: false
    };
    $rootScope.checkGlobalNotification = function() {
      if (!$scope.view.one && !$scope.view.two && !$scope.view.three) {
        return $rootScope.product.globalNotification = false;
      }
    };
    $scope.$on('$ionicView.enter', function() {
      $rootScope.product.request = 'other';
      return $rootScope.checkGlobalNotification();
    });
    $scope.seeOffers = function(request) {
      $rootScope.product.request = request;
      App.navigate('offers');
      return $scope.view[request] = false;
    };
    return $rootScope.$watch('product.offers', function(newOffers, oldOffers) {
      var latestOffer;
      if (_.size(newOffers) !== _.size(oldOffers)) {
        latestOffer = _.last(newOffers);
        if ($rootScope.product.request !== latestOffer.request) {
          return $scope.view[latestOffer.request] = true;
        }
      }
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('requests', {
      url: '/requests',
      parent: 'auth',
      views: {
        "authContent": {
          controller: 'RequestCtrl',
          templateUrl: 'views/requests.html'
        }
      }
    });
  }
]);
