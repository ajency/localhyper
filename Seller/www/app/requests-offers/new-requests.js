angular.module('LocalHyper.requestsOffers').controller('NewRequestCtrl', [
  '$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate', function($scope, App, RequestsAPI, $rootScope, $ionicModal, User, CToast, OffersAPI, CSpinner, $ionicScrollDelegate) {
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
                _this.removeRequestCard();
                _this.modal.hide();
                CToast.showLongBottom('Your offer has been made. For more details, please check your offer history.');
                return $rootScope.$broadcast('make:offer:success');
              };
            })(this), (function(_this) {
              return function(type) {
                return CToast.show('Failed to make offer, please try again');
              };
            })(this))["finally"](function() {
              return CSpinner.hide();
            });
          }
        },
        removeRequestCard: function() {
          var requestId, spliceIndex;
          requestId = this.data.id;
          spliceIndex = _.findIndex($scope.view.requests, function(request) {
            return request.id === requestId;
          });
          if (spliceIndex !== -1) {
            return $scope.view.requests.splice(spliceIndex, 1);
          }
        }
      },
      init: function() {
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
        })(this))["finally"](function() {
          return $scope.$broadcast('scroll.refreshComplete');
        });
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
      onPullToRefresh: function() {
        this.display = 'noError';
        return this.getRequests();
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
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_request') {
        return $scope.view.getRequests();
      }
    });
    $rootScope.$on('push:notification:click', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_request') {
        return $scope.view.requestDetails.showModal(payload.id);
      }
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]);
