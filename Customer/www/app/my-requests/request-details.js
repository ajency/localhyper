angular.module('LocalHyper.myRequests').controller('RequestDetailsCtrl', [
  '$scope', 'RequestAPI', '$interval', 'TimeString', function($scope, RequestAPI, $interval, TimeString) {
    $scope.view = {
      request: RequestAPI.requestDetails('get'),
      offers: [],
      init: function() {
        console.log($scope.view.request);
        this.setRequestTime();
        return this.getOffers();
      },
      setRequestTime: function() {
        var set;
        set = (function(_this) {
          return function() {
            return _this.request.timeStr = TimeString.get(_this.request.createdAt);
          };
        })(this);
        set();
        return this.interval = $interval((function(_this) {
          return function() {
            return set();
          };
        })(this), 60000);
      },
      getOffers: function() {
        return RequestAPI.getOffers(this.request.id).then((function(_this) {
          return function(offers) {
            return console.log(offers);
          };
        })(this));
      }
    };
    return $scope.$on('$destroy', function() {
      return $interval.cancel($scope.view.interval);
    });
  }
]).controller('EachOfferTimeCtrl', [
  '$scope', '$interval', 'TimeString', function($scope, $interval, TimeString) {
    var interval, setTime;
    setTime = function() {
      return $scope.offer.timeStr = TimeString.get($scope.offer.createdAt);
    };
    setTime();
    interval = $interval(setTime, 60000);
    return $scope.$on('$destroy', function() {
      return $interval.cancel(interval);
    });
  }
]).directive('ajCountDown', [
  '$timeout', '$parse', function($timeout, $parse) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          var createdAt, total, totalStr;
          createdAt = $parse(attrs.createdAt)(scope);
          total = moment(moment(createdAt.iso)).add(24, 'hours');
          totalStr = moment(total).format('YYYY/MM/DD HH:mm:ss');
          return $(el).countdown(totalStr, function(event) {
            return $(el).html(event.strftime('%-H:%-M:%-S'));
          });
        });
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('request-details', {
      url: '/request-details',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          templateUrl: 'views/my-requests/request-details.html',
          controller: 'RequestDetailsCtrl'
        }
      }
    });
  }
]);
