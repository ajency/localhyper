angular.module('LocalHyper.myRequests').controller('RequestDetailsCtrl', [
  '$scope', 'RequestAPI', '$interval', 'TimeString', 'App', '$timeout', 'CSpinner', 'CToast', '$rootScope', function($scope, RequestAPI, $interval, TimeString, App, $timeout, CSpinner, CToast, $rootScope) {
    var inAppNotificationEvent;
    $scope.view = {
      request: RequestAPI.requestDetails('get'),
      display: 'loader',
      errorType: '',
      address: {
        show: false,
        toggle: function() {
          this.show = !this.show;
          return $timeout(function() {
            return App.resize();
          }, 500);
        }
      },
      comments: {
        show: false,
        toggle: function() {
          this.show = !this.show;
          return $timeout(function() {
            return App.resize();
          }, 500);
        }
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
        id: null,
        display: 'none',
        errorType: '',
        all: [],
        limitTo: 1,
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
          this.markOffersAsSeen();
          return $scope.view.cancelRequest.set();
        },
        onError: function(type) {
          this.display = 'error';
          return this.errorType = type;
        },
        markOffersAsSeen: function() {
          return RequestAPI.isNotificationSeen($scope.view.request.id).then((function(_this) {
            return function(obj) {
              var offerIds;
              if (!obj.hasSeen) {
                offerIds = _.pluck(_this.all, 'id');
                return RequestAPI.updateNotificationStatus(offerIds).then(function() {
                  return _.each(_this.all, function(offer) {
                    return App.notification.decrement();
                  });
                });
              }
            };
          })(this));
        }
      },
      init: function() {
        if (_.has(this.request, 'pushOfferId')) {
          this.offers.id = this.request.pushOfferId;
          return this.getRequestForOffer();
        } else {
          this.display = 'noError';
          this.setRequestTime();
          return this.offers.get();
        }
      },
      getRequestForOffer: function() {
        this.display = 'loader';
        return RequestAPI.getRequestForOffer(this.offers.id).then((function(_this) {
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
        console.log('onRequestExpiry');
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
          "unacceptedOfferIds": unacceptedOfferIds
        };
        return RequestAPI.acceptOffer(params).then((function(_this) {
          return function(data) {
            _.each(_this.offers.all, function(offer) {
              if (offer.id === offerId) {
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
        CSpinner.show('', 'Please wait...');
        return RequestAPI.updateRequestStatus({
          "requestId": this.request.id,
          "status": "cancelled"
        }).then((function(_this) {
          return function() {
            _this.request.status = 'cancelled';
            _this.cancelRequest.set();
            $rootScope.$broadcast('request:cancelled');
            return CToast.show('Your request has been cancelled');
          };
        })(this), function(error) {
          return CToast.show('Cancellation failed, please try again');
        })["finally"](function() {
          CSpinner.hide();
          return App.resize();
        });
      },
      callSeller: function(sellerNumber) {
        var telURI;
        telURI = "tel:" + sellerNumber;
        return document.location.href = telURI;
      }
    };
    inAppNotificationEvent = $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        if (_.size($scope.view.offers.all) === 0) {
          return $scope.view.offers.get();
        } else {
          return $scope.view.offers.getSilently();
        }
      }
    });
    return $scope.$on('$destroy', function() {
      inAppNotificationEvent();
      return $interval.cancel($scope.view.interval);
    });
  }
]).controller('EachOfferTimeCtrl', [
  '$scope', '$interval', 'TimeString', function($scope, $interval, TimeString) {
    var deliveryTime, getDeliveryTimeLeft, interval, setTime, unit, value;
    deliveryTime = $scope.offer.deliveryTime;
    value = deliveryTime.value;
    switch (deliveryTime.unit) {
      case 'hr':
        unit = value === 1 ? 'hr' : 'hrs';
        break;
      case 'day':
        unit = value === 1 ? 'day' : 'days';
    }
    $scope.offer.deliveryTimeStr = "" + value + " " + unit;
    getDeliveryTimeLeft = function(obj) {
      var day, daysLeft, duration, format, hours, hoursLeft, hr, min, minsLeft, str, timeLeft, totalTime, updatedAt;
      hours = deliveryTime.unit === 'hr' ? value : value * 24;
      format = 'DD/MM/YYYY HH:mm:ss';
      updatedAt = moment(obj.iso).format(format);
      totalTime = moment(updatedAt, format).add(hours, 'h');
      timeLeft = totalTime.diff(moment());
      duration = moment.duration(timeLeft);
      daysLeft = parseInt(duration.asDays().toFixed(0));
      hoursLeft = parseInt(duration.asHours().toFixed(0));
      minsLeft = parseInt(duration.asMinutes().toFixed(0));
      if (minsLeft < 60) {
        min = minsLeft === 1 ? 'min' : 'mins';
        str = minsLeft >= 0 ? "" + minsLeft + " " + min : "0";
      } else if (hoursLeft < 24) {
        hr = hoursLeft === 1 ? 'hr' : 'hrs';
        str = "" + hoursLeft + " " + hr;
      } else {
        day = daysLeft === 1 ? 'day' : 'days';
        str = "" + daysLeft + " " + day;
      }
      return str;
    };
    setTime = function() {
      $scope.offer.timeStr = TimeString.get($scope.offer.createdAt);
      return $scope.offer.deliveryTimeLeftStr = getDeliveryTimeLeft($scope.offer.updatedAt);
    };
    setTime();
    interval = $interval(setTime, 60000);
    return $scope.$on('$destroy', function() {
      return $interval.cancel(interval);
    });
  }
]).directive('ajCountDown', [
  '$timeout', function($timeout) {
    return {
      restrict: 'A',
      scope: {
        createdAt: '=',
        countDownFinish: '&'
      },
      link: function(scope, el, attrs) {
        return $timeout(function() {
          var createdAt, total, totalStr;
          createdAt = moment(scope.createdAt.iso);
          total = moment(createdAt).add(24, 'hours');
          totalStr = moment(total).format('YYYY/MM/DD HH:mm:ss');
          return $(el).countdown(totalStr, function(event) {
            return $(el).html(event.strftime('%-H:%-M:%-S'));
          }).on('finish.countdown', function(event) {
            return scope.$apply(function() {
              return scope.countDownFinish();
            });
          });
        });
      }
    };
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
