angular.module('LocalHyper.requestsOffers').controller('MyOfferHistoryCtrl', [
  '$scope', 'App', 'OffersAPI', '$ionicModal', '$timeout', '$rootScope', 'CSpinner', function($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope, CSpinner) {
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
        pendingRequestId: "",
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
        },
        onNotificationClick: function(requestId) {
          var index, requests;
          requests = $scope.view.requests;
          index = _.findIndex(requests, (function(_this) {
            return function(request) {
              return request.request.id === requestId;
            };
          })(this));
          if (index === -1) {
            this.pendingRequestId = requestId;
            return this.modal.show();
          } else {
            return this.show(requests[index]);
          }
        },
        handlePendingRequest: function() {
          var index, requests;
          if (this.pendingRequestId !== "") {
            requests = $scope.view.requests;
            index = _.findIndex(requests, (function(_this) {
              return function(request) {
                return request.request.id === _this.pendingRequestId;
              };
            })(this));
            if (index !== -1) {
              this.data = requests[index];
              this.showExpiry = true;
              return this.pendingRequestId = "";
            } else {
              this.modal.hide();
              CSpinner.show('', 'Sorry, this request has been cancelled');
              return $timeout((function(_this) {
                return function() {
                  return CSpinner.hide();
                };
              })(this), 2000);
            }
          }
        },
        removeRequestCard: function(offerId) {
          var spliceIndex;
          spliceIndex = _.findIndex($scope.view.requests, function(offer) {
            return offer.id === offerId;
          });
          if (spliceIndex !== -1) {
            return $scope.view.requests.splice(spliceIndex, 1);
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
          acceptedOffers: false,
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
        return this.offerDetails.handlePendingRequest();
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
      $scope.view.offerDetails.pendingRequestId = "";
      return $timeout(function() {
        return $scope.view.offerDetails.showExpiry = false;
      }, 1000);
    });
    $rootScope.$on('make:offer:success', function() {
      App.scrollTop();
      return $scope.view.reFetch();
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var offerId, payload;
      payload = obj.payload;
      switch (payload.type) {
        case 'cancelled_request':
          App.scrollTop();
          return $scope.view.reFetch();
        case 'accepted_offer':
          offerId = payload.id;
          return $scope.view.offerDetails.removeRequestCard(offerId);
      }
    });
    return $rootScope.$on('cancelled:request', function(e, obj) {
      return $scope.view.offerDetails.onNotificationClick(obj.requestId);
    });
  }
]);
