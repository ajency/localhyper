angular.module('LocalHyper.requestsOffers').controller('NewRequestCtrl', [
  '$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal', 'Push', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate', function($scope, App, RequestsAPI, $rootScope, $ionicModal, Push, User, CToast, OffersAPI, CSpinner, $ionicScrollDelegate) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      requestIds: [],
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
        },
        resetModal: function() {
          this.display = 'noError';
          this.price = null;
          this.offerPrice = '';
          this.deliveryTime.display = false;
          this.deliveryTime.value = 1;
          this.deliveryTime.unit = 'hr';
          this.deliveryTime.unitText = 'Hour';
          this.reply.button = true;
          this.reply.text = '';
          return $ionicScrollDelegate.$getByHandle('request-details').scrollTop();
        },
        showModal: function(requestId) {
          this.requestId = requestId;
          this.modal.show();
          return this.get();
        },
        get: function() {
          this.display = 'loader';
          return RequestsAPI.getById(this.requestId).then((function(_this) {
            return function(request) {
              console.log(request);
              _this.display = 'noError';
              _this.data = request;
              return $scope.view.markNotificationAsSeen(request.objectId);
            };
          })(this), (function(_this) {
            return function(type) {
              _this.display = 'error';
              return _this.errorType = type;
            };
          })(this));
        },
        makeOffer: function() {
          var params, priceValue, user;
          user = User.getCurrent();
          priceValue = '';
          switch (this.price) {
            case 'localPrice':
              priceValue = '9000';
              break;
            case 'onlinePrice':
              priceValue = '9000';
              break;
            case 'yourPrice':
              priceValue = this.offerPrice;
          }
          params = {
            "sellerId": user.id,
            "requestId": this.data.id,
            "priceValue": priceValue,
            "deliveryTime": {
              "value": this.deliveryTime.value,
              "unit": this.deliveryTime.unit
            },
            "comments": this.reply.text,
            "status": "open"
          };
          if (_.isNull(this.price)) {
            return CToast.show('Please select price');
          } else if (_.isNull(priceValue) || priceValue === '') {
            return CToast.show('Please enter your offer price');
          } else {
            CSpinner.show('', 'Please wait...');
            return OffersAPI.makeOffer(params).then((function(_this) {
              return function(data) {
                _this.modal.hide();
                return CToast.show('Your offer has been made');
              };
            })(this), (function(_this) {
              return function(type) {
                return CToast.show('Failed to make offer, please try again');
              };
            })(this))["finally"](function() {
              return CSpinner.hide();
            });
          }
        }
      },
      init: function() {
        Push.register();
        this.getRequests();
        return this.loadRequestDetails();
      },
      loadRequestDetails: function() {
        return $ionicModal.fromTemplateUrl('views/requests-offers/request-details.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.requestDetails.modal = modal;
          };
        })(this));
      },
      getRequests: function() {
        return RequestsAPI.getNotifications().then((function(_this) {
          return function(requestIds) {
            var notifications;
            _this.requestIds = requestIds;
            notifications = _.size(requestIds);
            if (notifications > 0) {
              App.notification.badge = true;
              App.notification.count = notifications;
            }
            return RequestsAPI.getAll();
          };
        })(this)).then((function(_this) {
          return function(data) {
            console.log(data);
            return _this.onSuccess(data);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this));
      },
      onSuccess: function(data) {
        this.display = 'noError';
        return this.requests = data.requests;
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      isNew: function(requestId) {
        return _.contains(this.requestIds, requestId);
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getRequests();
      },
      showRequestDetails: function(request) {
        this.requestDetails.data = request;
        this.requestDetails.resetModal();
        this.requestDetails.modal.show();
        return this.markNotificationAsSeen(request.id);
      },
      markNotificationAsSeen: function(requestId) {
        var index, newRequest;
        index = _.findIndex(this.requests, function(val) {
          return val.id === requestId;
        });
        if (index !== -1) {
          newRequest = this.requests[index]["new"];
          if (newRequest) {
            return RequestsAPI.updateStatus(requestId).then((function(_this) {
              return function(data) {
                App.notification.decrement();
                return _this.requests[index]["new"] = false;
              };
            })(this));
          }
        }
      }
    };
    $rootScope.$on('on:new:request', function() {
      return $scope.view.getRequests();
    });
    $rootScope.$on('on:notification:click', function(e, obj) {
      return $scope.view.requestDetails.showModal(obj.payload.id);
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]).controller('EachRequestCtrl', [
  '$scope', function($scope) {
    var at, diff, duration, format, hours, hr, iso, min, minutes, now, timeStr;
    iso = $scope.request.createdAt.iso;
    format = 'DD/MM/YYYY HH:mm:ss';
    now = moment().format(format);
    at = moment(iso).format(format);
    diff = moment(now, format).diff(moment(at, format));
    duration = moment.duration(diff);
    minutes = parseInt(duration.asMinutes().toFixed(0));
    hours = parseInt(duration.asHours().toFixed(0));
    if (minutes <= 5) {
      timeStr = 'Just now';
    } else if (minutes < 60) {
      min = minutes === 1 ? 'min' : 'mins';
      timeStr = "" + minutes + " " + min + " ago";
    } else {
      hr = hours === 1 ? 'hr' : 'hrs';
      timeStr = "" + hours + " " + hr + " ago";
    }
    return $scope.request.timeStr = timeStr;
  }
]);
