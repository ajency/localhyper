angular.module('LocalHyper.requestsOffers').controller('MyOfferHistoryCtrl', [
  '$scope', 'App', 'RequestsAPI', 'OfferHistoryAPI', '$ionicModal', function($scope, App, RequestsAPI, OfferHistoryAPI, $ionicModal) {
    return $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      page: 0,
      canLoadMore: true,
      requestDetails: {
        modal: null,
        data: {},
        display: 'noError',
        errorType: '',
        requestId: null,
        offerPrice: '',
        reply: {
          button: true,
          text: ''
        },
        deliveryTime: {
          display: false,
          value: 1,
          unit: 'hr',
          unitText: 'Hour',
          setDuration: function() {
            if (!_.isNull(this.value)) {
              switch (this.unit) {
                case 'hr':
                  return this.unitText = this.value === 1 ? 'Hour' : 'Hours';
                case 'day':
                  return this.unitText = this.value === 1 ? 'Day' : 'Days';
              }
            }
          },
          done: function() {
            if (_.isNull(this.value)) {
              this.value = 1;
              this.unit = 'hr';
              this.unitText = 'Hour';
            }
            this.display = false;
            return App.resize();
          }
        }
      },
      incrementPage: function() {
        $scope.$broadcast('scroll.refreshComplete');
        return this.page = this.page + 1;
      },
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onSuccess: function(data) {
        var offerhistory;
        this.display = 'noError';
        offerhistory = data;
        if (offerhistory.length > 0) {
          this.canLoadMore = true;
          return this.requests = this.requests.concat(offerhistory);
        } else {
          return this.canLoadMore = false;
        }
      },
      onError: function(type) {
        this.display = 'error';
        this.errorType = type;
        return this.canLoadMore = false;
      },
      onTapToRetry: function() {
        this.display = 'error';
        this.canLoadMore = true;
        return this.page = 0;
      },
      onPullToRefresh: function() {
        this.requests = [];
        this.page = 0;
        return this.showOfferHistory();
      },
      onInfiniteScroll: function() {
        return this.showOfferHistory();
      },
      showOfferHistory: function() {
        return OfferHistoryAPI.offerhistory({
          page: this.page
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
      init: function() {
        return this.loadOfferDetails();
      },
      loadOfferDetails: function() {
        return $ionicModal.fromTemplateUrl('views/requests-offers/offer-history-details.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.requestDetails.modal = modal;
          };
        })(this));
      },
      show: function() {
        return view.modal.show();
      },
      showRequestDetails: function(request) {
        this.requestDetails.data = request;
        return this.requestDetails.modal.show();
      }
    };
  }
]);
