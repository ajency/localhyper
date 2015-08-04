angular.module('LocalHyper.requestsOffers').controller('NewRequestCtrl', [
  '$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate', '$q', '$timeout', function($scope, App, RequestsAPI, $rootScope, $ionicModal, User, CToast, OffersAPI, CSpinner, $ionicScrollDelegate, $q, $timeout) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      pendingRequestIds: [],
      requestDetails: {
        modal: null,
        data: {},
        display: 'noError',
        errorType: '',
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
        loadModal: function() {
          var defer;
          defer = $q.defer();
          if (_.isNull(this.modal)) {
            $ionicModal.fromTemplateUrl('views/requests-offers/request-details.html', {
              scope: $scope,
              animation: 'slide-in-up',
              hardwareBackButtonClose: true
            }).then((function(_this) {
              return function(modal) {
                return defer.resolve(_this.modal = modal);
              };
            })(this));
          } else {
            defer.resolve();
          }
          return defer.promise;
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
        show: function(request) {
          this.data = request;
          this.resetModal();
          this.modal.show();
          return this.markNotificationAsSeen(request);
        },
        markNotificationAsSeen: function(request) {
          var index, requests;
          if (!request.notification.hasSeen) {
            requests = $scope.view.requests;
            index = _.findIndex(requests, function(val) {
              return val.id === request.id;
            });
            return RequestsAPI.updateStatus(request.id).then((function(_this) {
              return function(data) {
                App.notification.decrement();
                return requests[index].notification.hasSeen = true;
              };
            })(this));
          }
        },
        onNotificationClick: function(requestId) {
          var index, requests;
          requests = $scope.view.requests;
          index = _.findIndex(requests, function(val) {
            return val.id === requestId;
          });
          if (index !== -1) {
            return this.show(requests[index]);
          } else {
            return this.loadModal().then((function(_this) {
              return function() {
                $scope.view.pendingRequestIds.push(requestId);
                _this.display = 'loader';
                _this.modal.show();
                return RequestsAPI.getSingleRequest(requestId).then(function(request) {
                  if (request.status === 'cancelled') {
                    CSpinner.show('', 'Sorry, this request has been cancelled');
                    return $timeout(function() {
                      _this.modal.hide();
                      return CSpinner.hide();
                    }, 2000);
                  } else {
                    _this.display = 'noError';
                    return _this.data = request;
                  }
                }, function(type) {
                  _this.display = 'error';
                  return _this.errorType = type;
                });
              };
            })(this));
          }
        },
        makeOffer: function() {
          var params, priceValue, requestId;
          requestId = this.data.id;
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
            "sellerId": User.getId(),
            "requestId": requestId,
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
                _this.removeRequestCard(requestId);
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
        removeRequestCard: function(requestId) {
          var spliceIndex;
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
        return this.requestDetails.loadModal();
      },
      getRequests: function() {
        return RequestsAPI.getAll().then((function(_this) {
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
        this.requests = data.requests;
        return this.markPendingNotificationsAsSeen();
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onPullToRefresh: function() {
        this.display = 'noError';
        return this.getRequests();
      },
      onTapToRetry: function() {
        this.display = 'loader';
        $rootScope.$broadcast('get:unseen:notifications');
        return this.getRequests();
      },
      markPendingNotificationsAsSeen: function() {
        _.each(this.pendingRequestIds, (function(_this) {
          return function(requestId) {
            return RequestsAPI.updateStatus(requestId).then(function(data) {
              var index;
              index = _.findIndex(_this.requests, function(val) {
                return val.id === requestId;
              });
              if (index !== -1) {
                App.notification.decrement();
                return _this.requests[index].notification.hasSeen = true;
              }
            });
          };
        })(this));
        return this.pendingRequestIds = [];
      }
    };
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      switch (payload.type) {
        case 'new_request':
          return $scope.view.getRequests();
        case 'cancelled_request':
          $rootScope.$broadcast('get:unseen:notifications');
          return $scope.view.requestDetails.removeRequestCard(payload.id);
      }
    });
    $rootScope.$on('push:notification:click', function(e, obj) {
      var payload;
      payload = obj.payload;
      switch (payload.type) {
        case 'new_request':
          App.navigate('new-requests');
          return $scope.view.requestDetails.onNotificationClick(payload.id);
        case 'cancelled_request':
          return App.navigate('my-offer-history', {
            requestId: payload.id
          });
        case 'accepted_offer':
          return App.navigate('successful-offers', {
            offerId: payload.id
          });
      }
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]);
