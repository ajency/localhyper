angular.module('LocalHyper.creditHistory', []).controller('creditHistoryCtrl', [
  '$scope', 'App', 'creditHistoryAPI', 'User', function($scope, App, creditHistoryAPI, User) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      page: 0,
      canLoadMore: true,
      refresh: false,
      availableCredit: '',
      creditHistoryData: [],
      getAllCreditHistory: false,
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onInfiniteScroll: function() {
        this.getTotalCredit();
        this.refresh = false;
        return this.creditHistory();
      },
      onPullToRefresh: function() {
        this.getAllHistory = false;
        this.refresh = true;
        this.page = 0;
        this.canLoadMore = true;
        return this.creditHistory();
      },
      getTotalCredit: function() {
        var user;
        user = User.getCurrent();
        this.availableCredit = parseInt(user._serverData.addedCredit) - parseInt(user._serverData.subtractedCredit);
        return this.creditUsed = user._serverData.subtractedCredit;
      },
      onSuccess: function(data, displayLimit) {
        var creditHistory;
        console.log('--creditr history details');
        console.log(data);
        this.display = 'noError';
        creditHistory = _.size(data);
        if (creditHistory > 0) {
          if (creditHistory < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            this.onScrollComplete();
          }
          if (this.refresh) {
            this.creditHistoryData = data;
          } else {
            this.creditHistoryData = this.creditHistoryData.concat(data);
          }
        } else {
          this.canLoadMore = false;
        }
        if (!this.canLoadMore) {
          return this.getAllHistory = true;
        }
      },
      onError: function(type) {
        this.creditHistoryData = [];
        this.display = 'error';
        this.errorType = type;
        return this.canLoadMore = false;
      },
      creditHistory: function() {
        var params;
        params = {
          page: this.page,
          displayLimit: 3
        };
        return creditHistoryAPI.getCreditHistory(params).then((function(_this) {
          return function(data) {
            return _this.onSuccess(data, params.displayLimit);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"]((function(_this) {
          return function() {
            App.resize();
            _this.page = _this.page + 1;
            return $scope.$broadcast('scroll.refreshComplete');
          };
        })(this));
      },
      onTapToRetry: function() {
        this.display = 'loader';
        this.page = 0;
        return this.canLoadMore = true;
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
  }
]).controller('EachDisplayDateCtrl', [
  '$scope', '$interval', 'TimeString', function($scope, $interval, TimeString) {
    var date, format, iso, now;
    iso = $scope.request.createdAt.iso;
    format = 'DD/MM/YYYY HH:mm:ss';
    now = moment().format(format);
    date = now.split(" ");
    return $scope.request.timeStr = date[0];
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('credit-history', {
      url: '/credit-history',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          templateUrl: 'views/credit-history/credit-history.html',
          controller: 'creditHistoryCtrl'
        }
      }
    });
  }
]);
