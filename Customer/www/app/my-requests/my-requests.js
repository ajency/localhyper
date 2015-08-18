angular.module('LocalHyper.myRequests').controller('MyRequestCtrl', [
  '$scope', 'App', 'RequestAPI', '$timeout', '$ionicModal', 'CDialog', '$ionicPlatform', '$rootScope', function($scope, App, RequestAPI, $timeout, $ionicModal, CDialog, $ionicPlatform, $rootScope) {
    var onDeviceBack;
    $scope.view = {
      display: 'loader',
      errorType: '',
      openRequests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      gotAllRequests: false,
      filter: {
        modal: null,
        excerpt: '',
        selected: [],
        originalAttrs: [],
        attributes: [
          {
            name: 'Open requests',
            value: 'open',
            selected: false
          }, {
            name: 'Cancelled requests',
            value: 'cancelled',
            selected: false
          }, {
            name: 'Successful delivery',
            value: 'successful',
            selected: false
          }, {
            name: 'Sent for delivery',
            value: 'sent_for_delivery',
            selected: false
          }, {
            name: 'Pending delivery',
            value: 'pending_delivery',
            selected: false
          }, {
            name: 'Failed delivery',
            value: 'failed_delivery',
            selected: false
          }
        ],
        reset: function() {
          this.excerpt = '';
          return this.clearFilters();
        },
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/my-requests/my-requests-filter.html', {
            scope: $scope,
            animation: 'slide-in-up',
            hardwareBackButtonClose: false
          }).then((function(_this) {
            return function(modal) {
              return _this.modal = modal;
            };
          })(this));
        },
        noChangeInSelection: function() {
          return _.isEqual(_.sortBy(this.originalAttrs), _.sortBy(this.attributes));
        },
        openModal: function() {
          this.originalAttrs = JSON.parse(JSON.stringify(this.attributes));
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
                    _this.attributes = _this.originalAttrs;
                    return _this.modal.hide();
                  case 2:
                    return _this.onApply();
                }
              };
            })(this));
          }
        },
        clearFilters: function() {
          this.selected = [];
          return _.each(this.attributes, function(attr) {
            return attr.selected = false;
          });
        },
        onApply: function() {
          _.each(this.attributes, (function(_this) {
            return function(attr) {
              if (attr.selected) {
                if (!_.contains(_this.selected, attr.value)) {
                  return _this.selected.push(attr.value);
                }
              } else {
                return _this.selected = _.without(_this.selected, attr.value);
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
          _.each(this.selected, (function(_this) {
            return function(val) {
              var attribute;
              attribute = _.filter(_this.attributes, function(attr) {
                return attr.value === val;
              });
              return filterNames.push(attribute[0].name);
            };
          })(this));
          return this.excerpt = filterNames.join(', ');
        }
      },
      init: function() {
        return this.filter.loadModal();
      },
      reFetch: function() {
        this.display = 'loader';
        this.refresh = false;
        this.page = 0;
        this.openRequests = [];
        this.canLoadMore = true;
        this.gotAllRequests = false;
        return $timeout((function(_this) {
          return function() {
            return _this.onScrollComplete();
          };
        })(this));
      },
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      onInfiniteScroll: function() {
        this.refresh = false;
        return this.getMyRequests();
      },
      onPullToRefresh: function() {
        this.gotAllRequests = false;
        this.page = 0;
        this.refresh = true;
        this.canLoadMore = false;
        return this.getMyRequests();
      },
      getMyRequests: function() {
        var options;
        options = {
          page: this.page,
          requestType: 'nonexpired',
          selectedFilters: this.filter.selected,
          displayLimit: 5
        };
        return RequestAPI.get(options).then((function(_this) {
          return function(data) {
            return _this.onSuccess(data, options.displayLimit);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this))["finally"]((function(_this) {
          return function() {
            _this.page = _this.page + 1;
            $scope.$broadcast('scroll.refreshComplete');
            return App.resize();
          };
        })(this));
      },
      onSuccess: function(data, displayLimit) {
        var _requests, requestsSize;
        this.display = 'noError';
        _requests = data;
        requestsSize = _.size(_requests);
        if (requestsSize > 0) {
          if (requestsSize < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            this.onScrollComplete();
          }
          if (this.refresh) {
            this.openRequests = _requests;
          } else {
            this.openRequests = this.openRequests.concat(_requests);
          }
        } else {
          this.canLoadMore = false;
        }
        if (!this.canLoadMore) {
          return this.gotAllRequests = true;
        }
      },
      onError: function(type) {
        this.canLoadMore = false;
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.canLoadMore = true;
        this.display = 'loader';
        return this.page = 0;
      },
      onRequestClick: function(request) {
        RequestAPI.requestDetails('set', request);
        return App.navigate('request-details');
      }
    };
    onDeviceBack = function() {
      var filter;
      filter = $scope.view.filter;
      if (filter.modal.isShown()) {
        return filter.closeModal();
      } else {
        return App.goBack(-1);
      }
    };
    $scope.$on('$ionicView.enter', function() {
      return $ionicPlatform.onHardwareBackButton(onDeviceBack);
    });
    $scope.$on('$stateChangeSuccess', function(ev, to) {
      if (to.name !== 'my-requests') {
        return $ionicPlatform.offHardwareBackButton(onDeviceBack);
      }
    });
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      var cacheForStates;
      if (!viewData.enableBack) {
        viewData.enableBack = true;
      }
      cacheForStates = ['requests-history', 'request-details'];
      if (!_.contains(cacheForStates, App.previousState)) {
        $scope.view.reFetch();
        $scope.view.filter.reset();
        return $rootScope.$broadcast('re:fetch:expired:requests');
      }
    });
  }
]);
