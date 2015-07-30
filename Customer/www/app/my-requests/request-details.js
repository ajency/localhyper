angular.module('LocalHyper.myRequests').controller('RequestDetailsCtrl', [
  '$scope', 'RequestAPI', '$interval', 'TimeString', 'App', '$timeout', 'CSpinner', 'CToast', '$rootScope', function($scope, RequestAPI, $interval, TimeString, App, $timeout, CSpinner, CToast, $rootScope) {
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
      offers: {
        all: [],
        limitTo: 1,
        received: true
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
      init: function() {
        console.log($scope.view.request);
        this.setRequestTime();
        return this.getOffers();
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
      showAllOffers: function() {
        this.offers.limitTo = 100;
        return App.resize();
      },
      getOffers: function() {
        return RequestAPI.getOffers(this.request.id).then((function(_this) {
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
      onSuccess: function(offers) {
        console.log(offers);
        this.display = 'noError';
        this.offers.all = offers;
        return this.cancelRequest.set();
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getOffers();
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
    return $scope.$on('$destroy', function() {
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
    $scope.offer.deliveryTimeStr = value + " " + unit;
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
        str = minsLeft >= 0 ? minsLeft + " " + min : "0";
      } else if (hoursLeft < 24) {
        hr = hoursLeft === 1 ? 'hr' : 'hrs';
        str = hoursLeft + " " + hr;
      } else {
        day = daysLeft === 1 ? 'day' : 'days';
        str = daysLeft + " " + day;
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
