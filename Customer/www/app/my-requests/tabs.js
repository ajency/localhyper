angular.module('LocalHyper.myRequests', []).directive('ajRemoveBoxShadow', [
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
]).directive('ajCountDown', [
  '$timeout', function($timeout) {
    return {
      restrict: 'A',
      scope: {
        createdAt: '=',
        countDownFinish: '&'
      },
      link: function(scope, el, attrs) {
        return $timeout(function() {
          var createdAt, total, totalStr;
          createdAt = moment(scope.createdAt.iso);
          total = moment(createdAt).add(24, 'hours');
          totalStr = moment(total).format('YYYY/MM/DD HH:mm:ss');
          return $(el).countdown(totalStr, function(event) {
            return $(el).html(event.strftime('%-H:%-M:%-S'));
          }).on('finish.countdown', function(event) {
            return scope.$apply(function() {
              return scope.countDownFinish();
            });
          });
        });
      }
    };
  }
]).factory('DeliveryTime', [
  function() {
    var DeliveryTime;
    return DeliveryTime = {
      humanize: function(obj) {
        var unitText, value;
        if (!_.isUndefined(obj)) {
          value = obj.value;
          switch (obj.unit) {
            case 'hr':
              unitText = value === 1 ? 'Hour' : 'Hours';
              break;
            case 'day':
              unitText = value === 1 ? 'Day' : 'Days';
          }
          return "" + value + " " + unitText;
        }
      },
      left: function(timeObj) {
        var day, daysLeft, deliveryDate, duration, format, hoursLeft, hr, min, minsLeft, str, timeLeft;
        format = 'DD/MM/YYYY HH:mm:ss';
        deliveryDate = moment(timeObj.iso).format(format);
        timeLeft = moment(deliveryDate, format).diff(moment());
        duration = moment.duration(timeLeft);
        daysLeft = parseInt(duration.asDays().toFixed(0));
        hoursLeft = parseInt(duration.asHours().toFixed(0));
        minsLeft = parseInt(duration.asMinutes().toFixed(0));
        if (minsLeft < 60) {
          min = minsLeft === 1 ? 'min' : 'mins';
          str = minsLeft >= 0 ? "" + minsLeft + " " + min : "0";
        } else if (hoursLeft < 24) {
          hr = hoursLeft === 1 ? 'hr' : 'hrs';
          str = "" + hoursLeft + " " + hr;
        } else {
          day = daysLeft === 1 ? 'day' : 'days';
          str = "" + daysLeft + " " + day;
        }
        return str;
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
          templateUrl: 'views/my-requests/tabs.html'
        }
      }
    }).state('my-requests', {
      url: '/my-requests',
      parent: 'tabs',
      views: {
        "myRequestsTab": {
          controller: 'MyRequestCtrl',
          templateUrl: 'views/my-requests/my-requests.html'
        }
      }
    }).state('requests-history', {
      url: '/requests-history',
      parent: 'tabs',
      views: {
        "requestHistoryTab": {
          controller: 'RequestsHistoryCtrl',
          templateUrl: 'views/my-requests/requests-history.html'
        }
      }
    });
  }
]);
