angular.module('LocalHyper.myRequests').controller('RequestsHistoryCtrl', [
  '$scope', 'App', 'RequestAPI', '$timeout', '$rootScope', function($scope, App, RequestAPI, $timeout, $rootScope) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      expiredRequests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      gotAllRequests: false,
      shouldRefetch: false,
      reFetch: function() {
        this.display = 'loader';
        this.refresh = false;
        this.page = 0;
        this.expiredRequests = [];
        this.canLoadMore = true;
        this.gotAllRequests = false;
        return $timeout((function(_this) {
          return function() {
            return _this.onScrollComplete();
          };
        })(this));
      },
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onInfiniteScroll: function() {
        this.refresh = false;
        return this.getExpiredRequests();
      },
      onPullToRefresh: function() {
        this.gotAllRequests = false;
        this.page = 0;
        this.refresh = true;
        this.canLoadMore = false;
        return this.getExpiredRequests();
      },
      getExpiredRequests: function() {
        var options;
        options = {
          page: this.page,
          requestType: 'expired',
          selectedFilters: [],
          displayLimit: 5
        };
        return RequestAPI.get(options).then((function(_this) {
          return function(data) {
            return _this.onSuccess(data, options.displayLimit);
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
        var requestsSize, _requests;
        this.display = 'noError';
        _requests = data;
        requestsSize = _.size(_requests);
        if (requestsSize > 0) {
          if (requestsSize < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            this.onScrollComplete();
          }
          if (this.refresh) {
            this.expiredRequests = _requests;
          } else {
            this.expiredRequests = this.expiredRequests.concat(_requests);
          }
        } else {
          this.canLoadMore = false;
        }
        if (!this.canLoadMore) {
          return this.gotAllRequests = true;
        }
      },
      onError: function(type) {
        this.canLoadMore = false;
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.canLoadMore = true;
        this.display = 'loader';
        return this.page = 0;
      },
      onRequestClick: function(request) {
        RequestAPI.requestDetails('set', request);
        return App.navigate('request-details');
      },
      onImageClick: function(productID, e) {
        e.stopPropagation();
        return App.navigate('single-product', {
          productID: productID
        });
      }
    };
    $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      var cacheForStates;
      if (!viewData.enableBack) {
        viewData.enableBack = true;
      }
      if ($scope.view.shouldRefetch) {
        $scope.view.shouldRefetch = false;
        $scope.view.reFetch();
      }
      cacheForStates = ['my-requests', 'request-details'];
      if (!_.contains(cacheForStates, App.previousState)) {
        return $scope.view.reFetch();
      }
    });
    return $rootScope.$on('re:fetch:expired:requests', function() {
      return $scope.view.shouldRefetch = true;
    });
  }
]);
