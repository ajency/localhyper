angular.module('LocalHyper.requestsOffers', []).directive('ajRemoveBoxShadow', [
  '$timeout', function($timeout) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          return $('.bar-header').removeClass('bar-light');
        });
      }
    };
  }
]).directive('ajAddBoxShadow', [
  '$timeout', function($timeout) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          return $('.bar-header').addClass('bar-light');
        });
      }
    };
  }
]).factory('TimeString', [
  function() {
    var TimeString;
    TimeString = {};
    TimeString.get = function(obj) {
      var createdAt, day, days, diff, duration, format, hours, hr, iso, min, minutes, now, timeStr, week, weeks;
      iso = obj.iso;
      format = 'DD/MM/YYYY HH:mm:ss';
      now = moment().format(format);
      createdAt = moment(iso).format(format);
      diff = moment(now, format).diff(moment(createdAt, format));
      duration = moment.duration(diff);
      minutes = parseInt(duration.asMinutes().toFixed(0));
      hours = parseInt(duration.asHours().toFixed(0));
      days = parseInt(duration.asDays().toFixed(0));
      weeks = parseInt(duration.asWeeks().toFixed(0));
      if (minutes < 1) {
        timeStr = 'Just now';
      } else if (minutes < 60) {
        min = minutes === 1 ? 'min' : 'mins';
        timeStr = "" + minutes + " " + min + " ago";
      } else if (minutes >= 60 && minutes < 1440) {
        hr = hours === 1 ? 'hr' : 'hrs';
        timeStr = "" + hours + " " + hr + " ago";
      } else if (minutes >= 1440 && days < 7) {
        day = days === 1 ? 'day' : 'days';
        timeStr = "" + days + " " + day + " ago";
      } else if (days >= 7 && weeks <= 4) {
        week = weeks === 1 ? 'week' : 'weeks';
        timeStr = "" + weeks + " " + week + " ago";
      } else {
        timeStr = "On " + (moment(iso).format('DD-MM-YYYY'));
      }
      return timeStr;
    };
    return TimeString;
  }
]).controller('EachRequestTimeCtrl', [
  '$scope', '$interval', 'TimeString', function($scope, $interval, TimeString) {
    var interval, setTime;
    setTime = function() {
      return $scope.request.timeStr = TimeString.get($scope.request.createdAt);
    };
    setTime();
    interval = $interval(setTime, 60000);
    return $scope.$on('$destroy', function() {
      return $interval.cancel(interval);
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('tabs', {
      url: "/tab",
      abstract: true,
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/requests-offers/tabs.html'
        }
      }
    }).state('new-requests', {
      url: '/new-requests',
      parent: 'tabs',
      views: {
        "newRequestsTab": {
          controller: 'NewRequestCtrl',
          templateUrl: 'views/requests-offers/new-requests.html'
        }
      }
    }).state('my-offer-history', {
      url: '/my-offer-history',
      parent: 'tabs',
      views: {
        "myOfferHistoryTab": {
          controller: 'MyOfferHistoryCtrl',
          templateUrl: 'views/requests-offers/my-offer-history.html'
        }
      }
    }).state('successful-offers', {
      url: '/successful-offers',
      parent: 'tabs',
      views: {
        "successfulOffersTab": {
          controller: 'SuccessfulOffersCtrl',
          templateUrl: 'views/requests-offers/successful-offers.html'
        }
      }
    });
  }
]);
