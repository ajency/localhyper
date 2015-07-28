angular.module('LocalHyper.myRequests').controller('RequestsHistoryCtrl', [
  '$scope', 'App', 'RequestAPI', function($scope, App, RequestAPI) {
    return $scope.view = {
      display: 'loader',
      errorType: '',
      openRequests: [],
      page: 0,
      canLoadMore: true,
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      incrementPage: function() {
        $scope.$broadcast('scroll.refreshComplete');
        return this.page = this.page + 1;
      },
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onPullToRefresh: function() {
        this.openRequests = [];
        this.page = 0;
        return this.getMyOffers();
      },
      onTapToRetry: function() {
        this.canLoadMore = true;
        this.display = 'error';
        return this.page = 0;
      },
      getMyOffers: function() {
        return RequestAPI.get({
          page: this.page,
          openStatus: false,
          displayLimit: 5
        }).then((function(_this) {
          return function(data) {
            return _this.onSuccess(data);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"]((function(_this) {
          return function() {
            _this.incrementPage();
            return _this.onScrollComplete();
          };
        })(this));
      },
      onSuccess: function(data) {
        var openRequest;
        this.display = 'noError';
        openRequest = data;
        if (openRequest.length > 0) {
          this.canLoadMore = true;
          return this.openRequests = this.openRequests.concat(openRequest);
        } else {
          return this.canLoadMore = false;
        }
      },
      onError: function(type) {
        this.canLoadMore = false;
        this.display = 'error';
        return this.errorType = type;
      },
      init: function() {},
      onInfiniteScroll: function() {
        return this.getMyOffers();
      }
    };
  }
]).controller('EachRequestTimeCtrl', [
  '$scope', function($scope) {
    var at, diff, duration, format, hours, hr, iso, min, minutes, now, timeStr;
    iso = $scope.openRequest.createdAt.iso;
    format = 'DD/MM/YYYY HH:mm:ss';
    now = moment().format(format);
    at = moment(iso).format(format);
    diff = moment(now, format).diff(moment(at, format));
    duration = moment.duration(diff);
    minutes = parseInt(duration.asMinutes().toFixed(0));
    hours = parseInt(duration.asHours().toFixed(0));
    if (minutes <= 5) {
      timeStr = 'Just now';
    } else if (minutes < 60) {
      min = minutes === 1 ? 'min' : 'mins';
      timeStr = "" + minutes + " " + min + " ago";
    } else {
      hr = hours === 1 ? 'hr' : 'hrs';
      timeStr = "" + hours + " " + hr + " ago";
    }
    return $scope.openRequest.timeStr = timeStr;
  }
]);
