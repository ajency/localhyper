angular.module('LocalHyper.requestsOffers').controller('SuccessfulOffersCtrl', [
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
        pendingOfferId: "",
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/requests-offers/successful-offer-details.html', {
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
        },
        onNotificationClick: function(offerId) {
          var index, requests;
          requests = $scope.view.requests;
          index = _.findIndex(requests, (function(_this) {
            return function(offer) {
              return offer.id === offerId;
            };
          })(this));
          if (index === -1) {
            this.pendingOfferId = offerId;
            return this.modal.show();
          } else {
            return this.show(requests[index]);
          }
        },
        handlePendingOffer: function() {
          var index, requests;
          if (this.pendingOfferId !== "") {
            requests = $scope.view.requests;
            index = _.findIndex(requests, (function(_this) {
              return function(offer) {
                return offer.id === _this.pendingOfferId;
              };
            })(this));
            this.data = requests[index];
            this.showExpiry = true;
            return this.pendingOfferId = "";
          }
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
          acceptedOffers: true,
          displayLimit: 3
        };
        return OffersAPI.getSellerOffers(params).then((function(_this) {
          return function(data) {
            console.log(data);
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
            this.requests = offerData;
          } else {
            this.requests = this.requests.concat(offerData);
          }
        } else {
          this.canLoadMore = false;
        }
        return this.offerDetails.handlePendingOffer();
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
      $scope.view.offerDetails.pendingOfferId = "";
      return $timeout(function() {
        return $scope.view.offerDetails.showExpiry = false;
      }, 1000);
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'accepted_offer') {
        App.scrollTop();
        return $scope.view.reFetch();
      }
    });
    return $rootScope.$on('accepted:offer', function(e, obj) {
      return $scope.view.offerDetails.onNotificationClick(obj.offerId);
    });
  }
]);
