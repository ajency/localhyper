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
        var totalCredit, usedCredit;
        totalCredit = user.get('addedCredit');
        usedCredit = user.get('subtractedCredit');
        this.creditAvailable = parseInt(totalCredit) - parseInt(usedCredit);
        return this.creditUsed = usedCredit;
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
          displayLimit: 5
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
          this.gotAllRecords = true;
        }
        return console.log(this.creditHistoryData);
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
      },
      getTransactionDate: function(createdAt) {
        return moment(createdAt.iso).format('DD/MM/YYYY');
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
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
