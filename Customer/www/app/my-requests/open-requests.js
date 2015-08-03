angular.module('LocalHyper.myRequests').controller('OpenRequestCtrl', [
  '$scope', 'App', 'RequestAPI', '$ionicLoading', function($scope, App, RequestAPI, $ionicLoading) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      openRequests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      getOpenProducts: false,
      selectedFilters: [],
      onClick: function(request) {
        RequestAPI.requestDetails('set', request);
        return App.navigate('request-details');
      },
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
        this.getOpenProducts = false;
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
          requestType: 'nonexpired',
          selectedFilters: this.selectedFilters
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
            this.openRequests = openRequest;
          } else {
            this.openRequests = this.openRequests.concat(openRequest);
          }
        } else {
          this.canLoadMore = false;
        }
        if (!this.canLoadMore) {
          return this.getOpenProducts = true;
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
      Filter: function() {
        return $ionicLoading.show({
          scope: $scope,
          templateUrl: 'views/my-requests/filter.html',
          hideOnStateChange: true
        });
      },
      onFilter: function(status) {
        this.canLoadMore = true;
        $ionicLoading.hide();
        if (status !== 'null') {
          this.selectedFilters = [status];
        } else {
          this.selectedFilters = [];
        }
        this.refresh = true;
        this.page = 0;
        this.openRequests = [];
        this.getOpenProducts = false;
        return this.onScrollComplete();
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      return viewData.enableBack = true;
    });
  }
]);
