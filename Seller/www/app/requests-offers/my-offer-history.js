angular.module('LocalHyper.requestsOffers').controller('MyOfferHistoryCtrl', [
  '$scope', 'App', 'RequestsAPI', 'OfferHistoryAPI', '$ionicModal', '$timeout', '$rootScope', function($scope, App, RequestsAPI, OfferHistoryAPI, $ionicModal, $timeout, $rootScope) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      requestDetails: {
        modal: null,
        showExpiry: false,
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
      reFetch: function() {
        this.canLoadMore = true;
        this.page = 0;
        return this.showOfferHistory();
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
          if (_.size(offerhistory) < 3) {
            this.canLoadMore = false;
          } else {
            this.onScrollComplete();
          }
          if (this.refresh) {
            return this.requests = offerhistory;
          } else {
            return this.requests = this.requests.concat(offerhistory);
          }
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
        this.refresh = true;
        this.canLoadMore = true;
        this.page = 0;
        return this.showOfferHistory();
      },
      onInfiniteScroll: function() {
        this.refresh = false;
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
            return _this.incrementPage();
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
        this.requestDetails.modal.show();
        return this.requestDetails.showExpiry = true;
      }
    };
    $scope.$on('modal.hidden', function() {
      return $timeout(function() {
        return $scope.view.requestDetails.showExpiry = false;
      }, 1000);
    });
    return $rootScope.$on('offer:done:succ', function() {
      return $scope.view.reFetch();
    });
  }
]).directive('ajCountDown', [
  '$timeout', '$parse', function($timeout, $parse) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          var createdAt, total, totalStr;
          createdAt = $parse(attrs.createdAt)(scope);
          total = moment(moment(createdAt.iso)).add(24, 'hours');
          totalStr = moment(total).format('YYYY/MM/DD HH:mm:ss');
          return $(el).countdown(totalStr, function(event) {
            return $(el).html(event.strftime('%-H:%-M:%-S'));
          });
        });
      }
    };
  }
]);
