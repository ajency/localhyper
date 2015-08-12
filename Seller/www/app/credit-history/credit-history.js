angular.module('LocalHyper.creditHistory', []).controller('creditHistoryCtrl', [
  '$scope', 'App', 'CreditHistoryAPI', 'User', function($scope, App, CreditHistoryAPI, User) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      page: 0,
      canLoadMore: true,
      refresh: false,
      creditHistoryData: [],
      gotAllRecords: false,
      init: function() {
        return this.getCreditDetails();
      },
      getCreditDetails: function() {
        return User.update().then((function(_this) {
          return function(user) {
            return _this.setCreditDetails(user);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.setCreditDetails(User.getCurrent());
          };
        })(this));
      },
      setCreditDetails: function(user) {
        return $scope.$apply((function(_this) {
          return function() {
            var totalCredit, usedCredit;
            totalCredit = user.get('addedCredit');
            usedCredit = user.get('subtractedCredit');
            _this.creditAvailable = parseInt(totalCredit) - parseInt(usedCredit);
            return _this.creditUsed = usedCredit;
          };
        })(this));
      },
      onInfiniteScroll: function() {
        this.refresh = false;
        return this.getCreditHistory();
      },
      onPullToRefresh: function() {
        this.gotAllRecords = false;
        this.refresh = true;
        this.page = 0;
        this.canLoadMore = true;
        this.getCreditDetails();
        return this.getCreditHistory();
      },
      getCreditHistory: function() {
        var params;
        params = {
          page: this.page,
          displayLimit: 10
        };
        return CreditHistoryAPI.getAll(params).then((function(_this) {
          return function(data) {
            return _this.onSuccess(data, params.displayLimit);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"]((function(_this) {
          return function() {
            _this.page = _this.page + 1;
            $scope.$broadcast('scroll.refreshComplete');
            return App.resize();
          };
        })(this));
      },
      onSuccess: function(data, displayLimit) {
        var totalRecords;
        this.display = 'noError';
        totalRecords = _.size(data);
        if (totalRecords > 0) {
          if (totalRecords < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            $scope.$broadcast('scroll.infiniteScrollComplete');
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
          return this.gotAllRecords = true;
        }
      },
      onError: function(type) {
        this.display = 'error';
        this.errorType = type;
        return this.canLoadMore = false;
      },
      onTapToRetry: function() {
        this.creditHistoryData = [];
        this.getCreditDetails();
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
]).controller('EachCreditRecordCtrl', [
  '$scope', function($scope) {
    var createdAt;
    createdAt = $scope.credit.createdAt;
    return $scope.credit.date = {
      month: moment(createdAt.iso).format('MMM'),
      day: moment(createdAt.iso).format('DD'),
      year: moment(createdAt.iso).format('YYYY')
    };
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
