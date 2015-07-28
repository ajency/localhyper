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
]);
