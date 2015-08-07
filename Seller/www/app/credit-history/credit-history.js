angular.module('LocalHyper.creditHistory', []).controller('creditHistoryCtrl', [
  '$scope', 'App', 'creditHistoryAPI', function($scope, App, creditHistoryAPI) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onInfiniteScroll: function() {
        this.getTotalCredit();
        return this.refresh = false;
      },
      onPullToRefresh: function() {
        this.refresh = true;
        this.page = 0;
        return this.canLoadMore = true;
      },
      getTotalCredit: function() {
        return creditHistoryAPI.getCreditBalance();
      },
      onSuccess: function(data) {
        var offerDataSize;
        console.log(data);
        this.display = 'noError';
        offerDataSize = _.size(offerData);
        if (offerDataSize > 0) {
          if (offerDataSize < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            this.onScrollComplete();
          }
          if (this.refresh) {
            return this.requests = offerData;
          } else {
            return this.requests = this.requests.concat(offerData);
          }
        } else {
          return this.canLoadMore = false;
        }
      },
      onError: function(type) {
        this.display = 'error';
        this.errorType = type;
        return this.canLoadMore = false;
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
