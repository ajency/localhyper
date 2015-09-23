angular.module('LocalHyper.myRequests').controller('RequestDetailsCtrl', [
  '$scope', 'RequestAPI', '$interval', 'TimeString', 'App', '$timeout', 'CSpinner', 'CToast', '$rootScope', 'CDialog', '$ionicPopup', 'User', '$window', '$ionicLoading', '$ionicPlatform', function($scope, RequestAPI, $interval, TimeString, App, $timeout, CSpinner, CToast, $rootScope, CDialog, $ionicPopup, User, $window, $ionicLoading, $ionicPlatform) {
    var inAppNotificationEvent, onDeviceBack;
    $scope.view = {
      request: RequestAPI.requestDetails('get'),
      display: 'loader',
      errorType: '',
      pushParams: null,
      helpURL: $window.HELP_URL,
      address: {
        show: false,
        toggle: function() {
          this.show = !this.show;
          return $timeout(function() {
            return App.resize();
          }, 500);
        }
      },
      showComment: function(title, comment) {
        return $ionicPopup.alert({
          title: title,
          template: comment,
          okText: 'Close',
          okType: 'button-assertive'
        });
      },
      showInfo: function() {
        return $ionicPopup.alert({
          title: 'Info',
          template: 'Delivery date gets calculate based on customer request accepted and your working days',
          okText: 'Close',
          okType: 'button-assertive'
        });
      },
      cancelRequest: {
        footer: false,
        set: function() {
          var count, status;
          status = $scope.view.request.status;
          count = _.size($scope.view.offers.all);
          if (status === 'open' && count === 0) {
            return this.footer = true;
          } else {
            return this.footer = false;
          }
        }
      },
      offers: {
        display: 'none',
        errorType: '',
        all: [],
        limitTo: 1,
        rate: {
          star: '',
          score: 1,
          max: 5,
          comment: '',
          setScore: function(score) {
            var rateValue;
            rateValue = ['', 'Poor', 'Average', 'Good', 'Very Good', 'Excellent'];
            this.star = rateValue[score];
            return this.score = score;
          }
        },
        showAll: function() {
          this.limitTo = 100;
          return App.resize();
        },
        get: function() {
          this.display = 'loader';
          return RequestAPI.getOffers($scope.view.request.id).then((function(_this) {
            return function(offers) {
              return _this.onSuccess(offers);
            };
          })(this), (function(_this) {
            return function(error) {
              return _this.onError(error);
            };
          })(this))["finally"](function() {
            return App.resize();
          });
        },
        getSilently: function() {
          return RequestAPI.getOffers($scope.view.request.id).then((function(_this) {
            return function(offers) {
              return _this.onSuccess(offers);
            };
          })(this));
        },
        onSuccess: function(offers) {
          console.log(offers);
          this.display = 'noError';
          this.all = offers;
          return $scope.view.cancelRequest.set();
        },
        onError: function(type) {
          this.display = 'error';
          return this.errorType = type;
        },
        markAsSeen: function(offer) {
          var hasSeen;
          hasSeen = offer.notification.hasSeen;
          if (!hasSeen) {
            return RequestAPI.updateNotificationStatus([offer.id]).then(function() {
              App.notification.decrement();
              return $rootScope.$broadcast('get:open:request:count');
            });
          }
        },
        openRatePopup: function(seller) {
          if (seller.isSellerRated === false) {
            this.rate.sellerId = seller.id;
            this.rate.sellerName = seller.businessName;
            this.rate.star = 'Poor';
            this.rate.score = 1;
            this.rate.comment = '';
            return $ionicLoading.show({
              scope: $scope,
              templateUrl: 'views/my-requests/rate.html',
              hideOnStateChange: true
            });
          }
        },
        rateSeller: function() {
          $ionicLoading.hide();
          CSpinner.show('', 'Submitting your review...');
          return RequestAPI.updateSellerRating({
            "customerId": User.getId(),
            "sellerId": this.rate.sellerId,
            "ratingInStars": this.rate.score,
            "comments": this.rate.comment
          }).then(function() {
            return CToast.show('Thanks for your feedback');
          }, function(error) {
            return CToast.show('An error occurred, please try again');
          })["finally"](function() {
            return CSpinner.hide();
          });
        },
        DeliveryDate: function(date) {
          var deliveryDate, format;
          format = 'DD/MM/YYYY';
          deliveryDate = moment(date).format(format);
          return deliveryDate;
        }
      },
      init: function() {
        if (_.has(this.request, 'pushOfferId')) {
          this.pushParams = {
            "offerId": this.request.pushOfferId,
            "requestId": ''
          };
          return this.getRequestDetails();
        } else if (_.has(this.request, 'pushRequestId')) {
          this.pushParams = {
            "offerId": '',
            "requestId": this.request.pushRequestId
          };
          return this.getRequestDetails();
        } else {
          this.display = 'noError';
          this.setRequestTime();
          return this.offers.get();
        }
      },
      getRequestDetails: function() {
        this.display = 'loader';
        return RequestAPI.getRequestDetails(this.pushParams).then((function(_this) {
          return function(request) {
            return _this.onSuccess(request);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"](function() {
          return App.resize();
        });
      },
      onSuccess: function(request) {
        this.display = 'noError';
        this.request = request;
        this.setRequestTime();
        return this.offers.get();
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      setRequestTime: function() {
        var set;
        set = (function(_this) {
          return function() {
            return _this.request.timeStr = TimeString.get(_this.request.createdAt);
          };
        })(this);
        set();
        return this.interval = $interval((function(_this) {
          return function() {
            return set();
          };
        })(this), 60000);
      },
      onRequestExpiry: function() {
        this.request.status = 'expired';
        return this.cancelRequest.set();
      },
      onAcceptOffer: function(acceptedOffer) {
        var offerId, offerIds, params, unacceptedOfferIds;
        CSpinner.show('', 'Please wait...');
        offerId = acceptedOffer.id;
        offerIds = _.pluck(this.offers.all, 'id');
        unacceptedOfferIds = _.without(offerIds, offerId);
        params = {
          "offerId": offerId,
          "unacceptedOfferIds": unacceptedOfferIds,
          "acceptedDateIST": {
            "__type": "Date",
            "iso": new Date
          }
        };
        return RequestAPI.acceptOffer(params).then((function(_this) {
          return function(data) {
            _.each(_this.offers.all, function(offer) {
              if (offer.id === offerId) {
                offer.deliveryDate = data.deliveryDate;
                offer.status = 'accepted';
                return offer.updatedAt = data.offerUpdatedAt;
              } else {
                return offer.status = 'unaccepted';
              }
            });
            _this.request.status = 'pending_delivery';
            $rootScope.$broadcast('offer:accepted');
            return CToast.show('Thank you for accepting the offer. Seller will contact you soon.');
          };
        })(this), function(error) {
          return CToast.show('Request failed, please try again');
        })["finally"](function() {
          CSpinner.hide();
          return App.resize();
        });
      },
      onCancelRequest: function() {
        return CDialog.confirm('Cancel Request', 'Are you sure you wish to cancel this request?', ['Yes', 'No']).then((function(_this) {
          return function(btnIndex) {
            if (btnIndex === 1) {
              CSpinner.show('', 'Please wait...');
              return RequestAPI.updateRequestStatus({
                "requestId": _this.request.id,
                "status": "cancelled"
              }).then(function() {
                _this.request.status = 'cancelled';
                _this.cancelRequest.set();
                $rootScope.$broadcast('request:cancelled');
                return CToast.show('Your request has been cancelled');
              }, function(error) {
                return CToast.show('Cancellation failed, please try again');
              })["finally"](function() {
                CSpinner.hide();
                return App.resize();
              });
            }
          };
        })(this));
      },
      callSeller: function(sellerNumber) {
        var telURI;
        telURI = "tel:" + sellerNumber;
        return document.location.href = telURI;
      },
      checkStatus: function(status) {
        if (status === 'open') {
          return true;
        } else {
          return false;
        }
      },
      onImageClick: function(productID, e) {
        e.stopPropagation();
        return App.navigate('single-product', {
          productID: productID
        });
      }
    };
    onDeviceBack = function() {
      $ionicLoading.hide();
      return App.goBack(-1);
    };
    inAppNotificationEvent = $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        if (_.size($scope.view.offers.all) === 0) {
          $scope.view.offers.get();
        } else {
          $scope.view.offers.getSilently();
        }
      }
      if (payload.type === 'request_delivery_changed') {
        return $scope.view.request.status = payload.requestStatus;
      }
    });
    $scope.$on('$destroy', function() {
      inAppNotificationEvent();
      return $interval.cancel($scope.view.interval);
    });
    $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
    $scope.$on('$ionicView.enter', function() {
      return $ionicPlatform.onHardwareBackButton(onDeviceBack);
    });
    return $scope.$on('$ionicView.leave', function() {
      return $ionicPlatform.offHardwareBackButton(onDeviceBack);
    });
  }
]).controller('EachOfferTimeCtrl', [
  '$scope', '$interval', 'TimeString', 'DeliveryTime', function($scope, $interval, TimeString, DeliveryTime) {
    var interval, setTime;
    $scope.offer.deliveryTimeStr = DeliveryTime.humanize($scope.offer.deliveryTime);
    setTime = function() {
      $scope.offer.timeStr = TimeString.get($scope.offer.createdAt);
      return $scope.offer.deliveryTimeLeftStr = DeliveryTime.left($scope.offer.deliveryDate);
    };
    setTime();
    interval = $interval(setTime, 60000);
    return $scope.$on('$destroy', function() {
      return $interval.cancel(interval);
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('request-details', {
      url: '/request-details',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          templateUrl: 'views/my-requests/request-details.html',
          controller: 'RequestDetailsCtrl'
        }
      }
    });
  }
]);
