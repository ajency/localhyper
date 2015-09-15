angular.module('LocalHyper.requestsOffers').controller('NewRequestCtrl', [
  '$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate', '$q', '$timeout', '$ionicLoading', '$ionicPlatform', 'CDialog', 'LowestPrice', function($scope, App, RequestsAPI, $rootScope, $ionicModal, User, CToast, OffersAPI, CSpinner, $ionicScrollDelegate, $q, $timeout, $ionicLoading, $ionicPlatform, CDialog, LowestPrice) {
    var onDeviceBack;
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      pendingRequestIds: [],
      sortBy: '-createdAt.iso',
      sortName: 'Most Recent',
      resetSort: function() {
        this.sortBy = '-createdAt.iso';
        return this.sortName = 'Most Recent';
      },
      filter: {
        modal: null,
        reset: function() {
          this.attribute = 'category';
          this.excerpt = '';
          this.allAttributes = [];
          this.attrValues = {};
          this.originalValues = {};
          this.other = {};
          this.defaultRadius = User.getCurrent().get('deliveryRadius');
          this.selectedCategories = 'default';
          this.selectedBrands = 'default';
          this.selectedMrp = 'default';
          return this.selectedRadius = 'default';
        },
        plus: function() {
          if (this.attrValues['radius'] < 25) {
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
        getPriceRange: function() {
          var prices;
          return prices = [
            {
              start: -1,
              end: 1000,
              name: "Rs 1000 & Below"
            }, {
              start: 1000,
              end: 5000,
              name: "Rs 1000 - Rs 5000"
            }, {
              start: 5000,
              end: 10000,
              name: "Rs 5000 - Rs 10000"
            }, {
              start: 10000,
              end: 15000,
              name: "Rs 10000 - Rs 15000"
            }, {
              start: 15000,
              end: 20000,
              name: "Rs 15000 - Rs 20000"
            }, {
              start: 20000,
              end: 25000,
              name: "Rs 20000 - Rs 25000"
            }, {
              start: 25000,
              end: 30000,
              name: "Rs 25000 - Rs 30000"
            }, {
              start: 30000,
              end: 35000,
              name: "Rs 30000 - Rs 35000"
            }, {
              start: 35000,
              end: 40000,
              name: "Rs 35000 - Rs 40000"
            }, {
              start: 40000,
              end: 45000,
              name: "Rs 40000 - Rs 45000"
            }, {
              start: 45000,
              end: 50000,
              name: "Rs 45000 - Rs 50000"
            }, {
              start: 50000,
              end: -1,
              name: "Rs 50000 & Above"
            }
          ];
        },
        setAttrValues: function() {
          this.attrValues['category'] = this.other.sellerCategories;
          this.attrValues['brand'] = this.other.sellerBrands;
          this.attrValues['mrp'] = this.getPriceRange();
          this.attrValues['radius'] = this.defaultRadius;
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
            value: 'radius',
            name: 'Distance'
          });
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
        clearFilters: function() {
          _.each(this.attrValues, function(values) {
            return _.each(values, function(val) {
              return val.selected = false;
            });
          });
          this.attrValues['radius'] = this.defaultRadius;
          _.each(this.allAttributes, function(attrs) {
            return attrs.selected = 0;
          });
          this.selectedCategories = 'default';
          this.selectedBrands = 'default';
          this.selectedMrp = 'default';
          return this.selectedRadius = 'default';
        },
        noChangeInSelection: function() {
          this.attrValues['radius'] = parseInt(this.attrValues['radius']);
          this.originalValues['radius'] = parseInt(this.originalValues['radius']);
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
              var end, radius, selected, start;
              switch (attribute) {
                case 'category':
                  selected = [];
                  _.each(_values, function(category) {
                    if (category.selected) {
                      return selected.push(category.id);
                    }
                  });
                  return _this.selectedCategories = _.isEmpty(selected) ? 'default' : selected;
                case 'brand':
                  selected = [];
                  _.each(_values, function(brand) {
                    if (brand.selected) {
                      return selected.push(brand.id);
                    }
                  });
                  return _this.selectedBrands = _.isEmpty(selected) ? 'default' : selected;
                case 'mrp':
                  start = [];
                  end = [];
                  _.each(_values, function(mrp) {
                    if (mrp.selected) {
                      start.push(mrp.start);
                      return end.push(mrp.end);
                    }
                  });
                  return _this.selectedMrp = _.isEmpty(start) ? 'default' : [_.min(start), _.max(end)];
                case 'radius':
                  radius = parseInt(_values);
                  return _this.selectedRadius = radius === _this.defaultRadius ? 'default' : radius;
              }
            };
          })(this));
          this.setExcerpt();
          this.modal.hide();
          return $scope.view.reFetch();
        },
        setExcerpt: function() {
          var filterNames;
          filterNames = [];
          _.each(this.allAttributes, (function(_this) {
            return function(attr, index) {
              if (attr.name === 'Distance') {
                if (parseInt(_this.attrValues['radius']) !== parseInt(_this.defaultRadius)) {
                  return filterNames.push(attr.name);
                }
              } else {
                if (attr.selected > 0) {
                  return filterNames.push(attr.name);
                }
              }
            };
          })(this));
          return this.excerpt = filterNames.join(', ');
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
          unit: 'day',
          unitText: 'Day',
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
          plus: function() {
            this.value++;
            return this.setDuration();
          },
          minus: function() {
            if (this.value > 1) {
              this.value--;
            }
            return this.setDuration();
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
              hardwareBackButtonClose: false
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
          this.deliveryTime.unit = 'day';
          this.deliveryTime.unitText = 'Day';
          this.reply.button = true;
          this.reply.text = '';
          return $ionicScrollDelegate.$getByHandle('request-details').scrollTop();
        },
        show: function(request) {
          this.data = request;
          this.resetModal();
          this.modal.show();
          this.makeOfferBtn = false;
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
          var index, onError, requests;
          requests = $scope.view.requests;
          index = _.findIndex(requests, function(val) {
            return val.id === requestId;
          });
          onError = (function(_this) {
            return function(msg) {
              CSpinner.show('', msg);
              return $timeout(function() {
                _this.modal.hide();
                return CSpinner.hide();
              }, 2000);
            };
          })(this);
          if (index !== -1) {
            return this.show(requests[index]);
          } else {
            return this.loadModal().then((function(_this) {
              return function() {
                $scope.view.pendingRequestIds.push(requestId);
                _this.display = 'loader';
                _this.makeOfferBtn = false;
                _this.modal.show();
                return RequestsAPI.getSingleRequest(requestId).then(function(request) {
                  var reqIndex;
                  if (request.status === 'cancelled') {
                    return onError('Sorry, this request has been cancelled');
                  } else if (_.isEmpty(requests)) {
                    _this.display = 'noError';
                    LowestPrice.get(request);
                    return _this.data = request;
                  } else {
                    reqIndex = _.findIndex(requests, function(val) {
                      return val.id === request.id;
                    });
                    if (reqIndex === -1) {
                      return onError('You have already made an offer');
                    } else {
                      _this.display = 'noError';
                      LowestPrice.get(request);
                      return _this.data = request;
                    }
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
          } else if (_.isNull(this.deliveryTime.value) || this.deliveryTime.value === 0) {
            return CToast.show('Please enter delivery time');
          } else {
            CSpinner.show('', 'Please wait...');
            return OffersAPI.makeOffer(params).then((function(_this) {
              return function(data) {
                _this.removeRequestCard(requestId);
                _this.makeOfferBtn = true;
                _this.modal.hide();
                CToast.showLongBottom('Your offer has been made. For more details, please check your offer history.');
                return $rootScope.$broadcast('make:offer:success');
              };
            })(this), (function(_this) {
              return function(type) {
                if (!_.isUndefined(type.data)) {
                  if (type.data.error === 'auto_offer_made') {
                    _this.removeRequestCard(requestId);
                    return CToast.show('You have made an offer through auto offer');
                  } else {
                    return CToast.show('Failed to make offer, please try again');
                  }
                } else {
                  return CToast.show('Failed to make offer, please try again');
                }
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
            $scope.view.requests.splice(spliceIndex, 1);
          }
          return $scope.view.setRequestsCount();
        }
      },
      init: function() {
        this.filter.reset();
        this.filter.loadModal();
        this.requestDetails.loadModal();
        return this.getRequests();
      },
      reFetch: function() {
        App.scrollTop();
        this.requests = [];
        this.display = 'loader';
        return this.getRequests();
      },
      setRequestsCount: function() {
        return App.notification.newRequests = _.size(this.requests);
      },
      getRequests: function() {
        var options;
        options = {
          sellerRadius: this.filter.selectedRadius,
          categories: this.filter.selectedCategories,
          brands: this.filter.selectedBrands,
          productMrp: this.filter.selectedMrp
        };
        return RequestsAPI.getAll(options).then((function(_this) {
          return function(data) {
            console.log(data);
            return _this.onSuccess(data);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"](function() {
          $scope.$broadcast('scroll.refreshComplete');
          return App.resize();
        });
      },
      onSuccess: function(data) {
        this.display = 'noError';
        this.requests = data.requests;
        this.filter.other['sellerBrands'] = data.sellerBrands;
        this.filter.other['sellerCategories'] = data.sellerCategories;
        if (_.isEmpty(this.filter.attrValues)) {
          this.filter.setAttrValues();
        }
        this.setRequestsCount();
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
      },
      displayFooter: function() {
        if (this.display === 'error') {
          return false;
        } else if (this.filter.excerpt === '') {
          if (this.requests.length > 0) {
            return true;
          }
        } else if (this.filter.excerpt !== '') {
          return true;
        } else {
          return false;
        }
      }
    };
    onDeviceBack = function() {
      var detailsModal, filter;
      filter = $scope.view.filter;
      detailsModal = $scope.view.requestDetails.modal;
      if ($('.loading-container').hasClass('visible')) {
        return $ionicLoading.hide();
      } else if (filter.modal.isShown()) {
        return filter.closeModal();
      } else if (detailsModal.isShown()) {
        return detailsModal.hide();
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
    $rootScope.$on('category:chain:updated', function() {
      $scope.view.resetSort();
      $scope.view.filter.reset();
      return $scope.view.reFetch();
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
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]).controller('EachRequestTimeCtrl', [
  '$scope', '$interval', 'TimeString', 'LowestPrice', function($scope, $interval, TimeString, LowestPrice) {
    var interval, setTime;
    LowestPrice.get($scope.request);
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
