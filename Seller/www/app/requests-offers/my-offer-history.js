angular.module('LocalHyper.requestsOffers').controller('MyOfferHistoryCtrl', [
  '$scope', 'App', 'OffersAPI', '$ionicModal', '$timeout', '$rootScope', function($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      offerDetails: {
        modal: null,
        showExpiry: false,
        data: {},
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/requests-offers/offer-history-details.html', {
            scope: $scope,
            animation: 'slide-in-up',
            hardwareBackButtonClose: true
          }).then((function(_this) {
            return function(modal) {
              return _this.modal = modal;
            };
          })(this));
        },
        show: function(request) {
          this.data = request;
          this.modal.show();
          return this.showExpiry = true;
        }
      },
      init: function() {
        return this.offerDetails.loadModal();
      },
      reFetch: function() {
        this.page = 0;
        this.requests = [];
        return this.showOfferHistory();
      },
      showOfferHistory: function() {
        var params;
        params = {
          page: this.page,
          displayLimit: 3
        };
        return OffersAPI.getSellerOffers(params).then((function(_this) {
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
      onSuccess: function(offerData, displayLimit) {
        var offerDataSize;
        this.display = 'noError';
        offerDataSize = _.size(offerData);
        if (offerDataSize > 0) {
          if (offerDataSize < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            $scope.$broadcast('scroll.infiniteScrollComplete');
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
      },
      onPullToRefresh: function() {
        this.refresh = true;
        this.page = 0;
        this.canLoadMore = true;
        return this.showOfferHistory();
      },
      onInfiniteScroll: function() {
        this.refresh = false;
        return this.showOfferHistory();
      },
      onTapToRetry: function() {
        this.display = 'loader';
        this.page = 0;
        return this.canLoadMore = true;
      }
    };
    $scope.$on('modal.hidden', function() {
      return $timeout(function() {
        return $scope.view.offerDetails.showExpiry = false;
      }, 1000);
    });
    return $rootScope.$on('make:offer:success', function() {
      App.scrollTop();
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
