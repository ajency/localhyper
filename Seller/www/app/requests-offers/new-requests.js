angular.module('LocalHyper.requestsOffers').controller('NewRequestCtrl', [
  '$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate', '$q', '$timeout', '$ionicLoading', '$ionicPlatform', 'CDialog', function($scope, App, RequestsAPI, $rootScope, $ionicModal, User, CToast, OffersAPI, CSpinner, $ionicScrollDelegate, $q, $timeout, $ionicLoading, $ionicPlatform, CDialog) {
    var onDeviceBack;
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      pendingRequestIds: [],
      sortBy: '-createdAt.iso',
      sortName: 'Most Recent',
      filter: {
        modal: null,
        attribute: 'category',
        allAttributes: [],
        attrValues: {},
        originalValues: {},
        defaultRadius: User.getCurrent().get('deliveryRadius'),
        selectedFilters: {
          categories: [],
          brands: [],
          mrp: [],
          radius: this.defaultRadius
        },
        plus: function() {
          if (this.attrValues['radius'] < 100) {
            return this.attrValues['radius']++;
          }
        },
        minus: function() {
          if (this.attrValues['radius'] > 1) {
            return this.attrValues['radius']--;
          }
        },
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/requests-offers/new-request-filter.html', {
            scope: $scope,
            animation: 'slide-in-up',
            hardwareBackButtonClose: false
          }).then((function(_this) {
            return function(modal) {
              return _this.modal = modal;
            };
          })(this));
        },
        getPriceRange: function(priceRange) {
          var increment, max, min, prices;
          prices = [];
          min = priceRange[0];
          max = priceRange[1];
          if (max <= 1000) {
            increment = 100;
          } else if (max <= 5000) {
            increment = 1000;
          } else if (max <= 25000) {
            increment = 5000;
          } else if (max <= 50000) {
            increment = 10000;
          } else if (max <= 75000) {
            increment = 15000;
          } else if (max <= 100000) {
            increment = 20000;
          } else {
            increment = 25000;
          }
          priceRange = _.range(min, max, increment);
          _.each(priceRange, function(start, index) {
            var end;
            end = priceRange[index + 1];
            if (_.isUndefined(end)) {
              end = max;
            }
            return prices.push({
              start: start,
              end: end,
              name: "Rs " + start + " - Rs " + end
            });
          });
          return prices;
        },
        setAttrValues: function() {
          var allMRPs, priceRange, requests;
          this.allAttributes.push({
            value: 'category',
            name: 'Category',
            selected: 0
          });
          this.allAttributes.push({
            value: 'brand',
            name: 'Brand',
            selected: 0
          });
          this.allAttributes.push({
            value: 'mrp',
            name: 'MRP',
            selected: 0
          });
          this.allAttributes.push({
            value: 'distance',
            name: 'Distance',
            selected: 0
          });
          requests = $scope.view.requests;
          this.attrValues['category'] = _.uniq(_.pluck(requests, 'category'), function(val) {
            return val.id;
          });
          this.attrValues['brand'] = _.uniq(_.pluck(requests, 'brand'), function(val) {
            return val.id;
          });
          allMRPs = _.pluck(_.pluck(requests, 'product'), 'mrp');
          priceRange = [_.min(allMRPs), _.max(allMRPs)];
          this.attrValues['mrp'] = this.getPriceRange([_.min(allMRPs), _.max(allMRPs)]);
          this.attrValues['radius'] = this.defaultRadius;
          return _.each(this.attrValues, function(values) {
            return _.each(values, function(val) {
              return val.selected = false;
            });
          });
        },
        showAttrCount: function() {
          return _.each(this.attrValues, (function(_this) {
            return function(values, index) {
              var attrIndex, count;
              if (_.isObject(values)) {
                count = 0;
                _.each(values, function(val) {
                  if (val.selected) {
                    return count++;
                  }
                });
                attrIndex = _.findIndex(_this.allAttributes, function(attrs) {
                  return attrs.value === index;
                });
                return _this.allAttributes[attrIndex].selected = count;
              }
            };
          })(this));
        },
        onRadiusChange: function() {
          return this.allAttributes[3].selected = 1;
        },
        clearFilters: function() {
          _.each(this.attrValues, function(values) {
            return _.each(values, function(val) {
              return val.selected = false;
            });
          });
          _.each(this.allAttributes, function(attrs) {
            return attrs.selected = 0;
          });
          return this.selectedFilters = {
            categories: [],
            brands: [],
            mrp: [],
            radius: this.defaultRadius
          };
        },
        resetFilters: function() {
          this.attribute = 'category';
          return this.clearFilters();
        },
        noChangeInSelection: function() {
          return _.isEqual(_.sortBy(this.originalValues), _.sortBy(this.attrValues));
        },
        openModal: function() {
          this.originalValues = JSON.parse(JSON.stringify(this.attrValues));
          return this.modal.show();
        },
        closeModal: function() {
          var msg;
          if (this.noChangeInSelection()) {
            return this.modal.hide();
          } else {
            msg = 'Your filter selection will go away';
            return CDialog.confirm('Exit Filter?', msg, ['Exit Anyway', 'Apply & Exit']).then((function(_this) {
              return function(btnIndex) {
                switch (btnIndex) {
                  case 1:
                    _this.attrValues = _this.originalValues;
                    _this.showAttrCount();
                    return _this.modal.hide();
                  case 2:
                    return _this.onApply();
                }
              };
            })(this));
          }
        },
        onApply: function() {
          _.each(this.attrValues, (function(_this) {
            return function(_values, attribute) {
              var end, selected, start;
              switch (attribute) {
                case 'price':
                  start = [];
                  end = [];
                  _.each(_values, function(price) {
                    if (price.selected) {
                      start.push(price.start);
                      return end.push(price.end);
                    }
                  });
                  if (_.isEmpty(start)) {
                    return _this.selectedFilters.price = [];
                  } else {
                    return _this.selectedFilters.price = [_.min(start), _.max(end)];
                  }
                  break;
                case 'brand':
                  selected = [];
                  _.each(_values, function(brand) {
                    if (brand.selected) {
                      return selected.push(brand.id);
                    }
                  });
                  return _this.selectedFilters.brands = selected;
              }
            };
          })(this));
          this.modal.hide();
          return $scope.view.reFetch();
        }
      },
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
            $ionicModal.fromTemplateUrl('views/requests-offers/new-request-details.html', {
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
          console.log(request);
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
            return RequestsAPI.updateNotificationStatus(request.id).then((function(_this) {
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
              priceValue = this.data.platformPrice;
              break;
            case 'onlinePrice':
              priceValue = this.data.onlinePrice;
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
        this.filter.loadModal();
        return this.requestDetails.loadModal();
      },
      autoFetch: function() {
        this.page = 0;
        this.requests = [];
        this.display = 'loader';
        this.errorType = '';
        return this.getRequests();
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
        if (_.isEmpty(this.filter.attrValues['category'])) {
          this.filter.setAttrValues();
        }
        App.notification.newRequests = _.size(this.requests);
        return this.markPendingNotificationsAsSeen();
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onPullToRefresh: function() {
        this.display = 'noError';
        $rootScope.$broadcast('get:unseen:notifications');
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
            return RequestsAPI.updateNotificationStatus(requestId).then(function(data) {
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
      },
      showSortOptions: function() {
        return $ionicLoading.show({
          scope: $scope,
          templateUrl: 'views/requests-offers/new-request-sort.html',
          hideOnStateChange: true
        });
      },
      simulateFetch: function() {
        App.scrollTop();
        this.display = 'loader';
        return $timeout((function(_this) {
          return function() {
            _this.display = 'noError';
            return App.resize();
          };
        })(this), 500);
      },
      onSort: function(sortBy, sortName) {
        $ionicLoading.hide();
        switch (sortBy) {
          case '-createdAt.iso':
            if (this.sortBy !== '-createdAt.iso') {
              this.sortBy = '-createdAt.iso';
              this.sortName = sortName;
              return this.simulateFetch();
            }
            break;
          case '-product.mrp':
            if (this.sortBy !== '-product.mrp') {
              this.sortBy = '-product.mrp';
              this.sortName = sortName;
              return this.simulateFetch();
            }
            break;
          case 'product.mrp':
            if (this.sortBy !== 'product.mrp') {
              this.sortBy = 'product.mrp';
              this.sortName = sortName;
              return this.simulateFetch();
            }
            break;
          case '-radius':
            if (this.sortBy !== '-radius') {
              this.sortBy = '-radius';
              this.sortName = sortName;
              return this.simulateFetch();
            }
            break;
          case 'radius':
            if (this.sortBy !== 'radius') {
              this.sortBy = 'radius';
              this.sortName = sortName;
              return this.simulateFetch();
            }
            break;
          case '-offerCount':
            if (this.sortBy !== '-offerCount') {
              this.sortBy = '-offerCount';
              this.sortName = sortName;
              return this.simulateFetch();
            }
            break;
          case 'offerCount':
            if (this.sortBy !== 'offerCount') {
              this.sortBy = 'offerCount';
              this.sortName = sortName;
              return this.simulateFetch();
            }
        }
      }
    };
    onDeviceBack = function() {
      var filter;
      filter = $scope.view.filter;
      if ($('.loading-container').hasClass('visible')) {
        return $ionicLoading.hide();
      } else if (filter.modal.isShown()) {
        return filter.closeModal();
      } else {
        return App.goBack(-1);
      }
    };
    $scope.$on('$ionicView.enter', function() {
      return $ionicPlatform.onHardwareBackButton(onDeviceBack);
    });
    $scope.$on('$ionicView.leave', function() {
      return $ionicPlatform.offHardwareBackButton(onDeviceBack);
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      switch (payload.type) {
        case 'new_request':
          return $scope.view.getRequests();
        case 'cancelled_request':
          $rootScope.$broadcast('get:unseen:notifications');
          return $scope.view.requestDetails.removeRequestCard(payload.id);
        case 'accepted_offer':
          return $rootScope.$broadcast('get:accepted:offer:count');
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
          RequestsAPI.cancelledRequestId('set', payload.id);
          return App.navigate('my-offer-history');
        case 'accepted_offer':
          OffersAPI.acceptedOfferId('set', payload.id);
          return App.navigate('successful-offers');
      }
    });
    $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
    return $rootScope.$on('category:chain:changed', function() {
      return $scope.view.autoFetch();
    });
  }
]).controller('EachRequestTimeCtrl', [
  '$scope', '$interval', 'TimeString', function($scope, $interval, TimeString) {
    var interval, setTime;
    setTime = function() {
      return $scope.request.timeStr = TimeString.get($scope.request.createdAt);
    };
    setTime();
    interval = $interval(setTime, 60000);
    return $scope.$on('$destroy', function() {
      return $interval.cancel(interval);
    });
  }
]);
