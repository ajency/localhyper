angular.module('LocalHyper.myRequests').controller('RequestsHistoryCtrl', [
  '$scope', 'App', 'RequestAPI', function($scope, App, RequestAPI) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      openRequests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
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
        this.page = 0;
        this.refresh = true;
        this.getMyOffers();
        return this.canLoadMore = true;
      },
      onTapToRetry: function() {
        this.canLoadMore = true;
        this.display = 'error';
        return this.page = 0;
      },
      getMyOffers: function() {
        return RequestAPI.get({
          page: this.page,
          displayLimit: 3,
          requestType: 'expired',
          selectedFilters: []
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
            return _this.incrementPage();
          };
        })(this));
      },
      onSuccess: function(data) {
        var openRequest;
        this.display = 'noError';
        openRequest = data;
        if (openRequest.length > 0) {
          if (_.size(openRequest) < 3) {
            this.canLoadMore = false;
          } else {
            this.onScrollComplete();
          }
          if (this.refresh) {
            return this.openRequests = openRequest;
          } else {
            return this.openRequests = this.openRequests.concat(openRequest);
          }
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
        this.refresh = false;
        return this.getMyOffers();
      },
      onClick: function(request) {
        RequestAPI.requestDetails('set', request);
        return App.navigate('request-details');
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      return viewData.enableBack = true;
    });
  }
]);
