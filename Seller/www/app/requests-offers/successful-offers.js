angular.module('LocalHyper.requestsOffers').controller('SuccessfulOffersCtrl', [
  '$scope', 'App', 'OffersAPI', '$ionicModal', '$timeout', '$rootScope', 'CDialog', '$ionicPlatform', 'DeliveryTime', '$ionicLoading', 'CToast', 'CSpinner', 'RequestsAPI', function($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope, CDialog, $ionicPlatform, DeliveryTime, $ionicLoading, CToast, CSpinner, RequestsAPI) {
    var onDeviceBack;
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      page: 0,
      canLoadMore: true,
      refresh: false,
      gotAllOffers: false,
      noAcceptedOffers: false,
      deliveryTime: DeliveryTime,
      sortBy: 'updatedAt',
      sortName: 'Recent Offers',
      descending: true,
      filter: {
        modal: null,
        excerpt: '',
        selected: [],
        originalAttrs: [],
        attributes: [
          {
            name: 'Pending delivery',
            value: 'pending_delivery',
            selected: false
          }, {
            name: 'Sent for delivery',
            value: 'sent_for_delivery',
            selected: false
          }, {
            name: 'Failed delivery',
            value: 'failed_delivery',
            selected: false
          }, {
            name: 'Successful delivery',
            value: 'successful',
            selected: false
          }
        ],
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/requests-offers/successful-offer-filter.html', {
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
          if (this.noChangeInSelection()) {
            return this.modal.hide();
          } else {
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
          }
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
      offerDetails: {
        modal: null,
        showExpiry: false,
        data: {},
        pendingOfferId: "",
        showChange: true,
        failedDelivery: {
          display: false,
          reason: ''
        },
        loadModal: function() {
          return $ionicModal.fromTemplateUrl('views/requests-offers/successful-offer-details.html', {
            scope: $scope,
            animation: 'slide-in-up',
            hardwareBackButtonClose: false
          }).then((function(_this) {
            return function(modal) {
              return _this.modal = modal;
            };
          })(this));
        },
        show: function(request, show) {
          if (show == null) {
            show = true;
          }
          this.data = request;
          console.log(this.data);
          this.showChange = true;
          if (show) {
            this.modal.show();
          }
          this.showExpiry = true;
          this.setDeliveryStatus();
          return this.checkIfFailedDelivery();
        },
        onNotificationClick: function(offerId) {
          var index, requests;
          requests = $scope.view.requests;
          index = _.findIndex(requests, (function(_this) {
            return function(offer) {
              return offer.id === offerId;
            };
          })(this));
          if (index === -1) {
            this.pendingOfferId = offerId;
            return this.modal.show();
          } else {
            return this.show(requests[index]);
          }
        },
        handlePendingOffer: function() {
          var index, requests;
          if (this.pendingOfferId !== "") {
            requests = $scope.view.requests;
            index = _.findIndex(requests, (function(_this) {
              return function(offer) {
                return offer.id === _this.pendingOfferId;
              };
            })(this));
            this.show(requests[index], false);
            return this.pendingOfferId = "";
          }
        },
        setDeliveryStatus: function() {
          var deliveryStatus;
          deliveryStatus = this.data.request.status;
          this.data.deliveryStatus = deliveryStatus;
          return this.originalStatus = this.data.deliveryStatus;
        },
        onDeliveryStatusChange: function() {
          return this.failedDelivery.display = this.data.deliveryStatus === 'failed_delivery';
        },
        checkIfFailedDelivery: function() {
          if (this.data.deliveryStatus === 'failed_delivery') {
            this.failedDelivery.display = true;
            return this.failedDelivery.reason = this.data.request.failedDeliveryReason;
          } else {
            this.failedDelivery.display = false;
            return this.failedDelivery.reason = '';
          }
        },
        onUpdateCancel: function() {
          this.data.deliveryStatus = this.originalStatus;
          this.checkIfFailedDelivery();
          return this.showChange = true;
        },
        updateDeliveryStatus: function() {
          var params;
          if (this.data.deliveryStatus === this.originalStatus) {
            CToast.show('Please Change status of delivery');
            return;
          }
          if (this.data.deliveryStatus === 'failed_delivery') {
            if (this.failedDelivery.reason === '') {
              CToast.show('Please provide reason for delivery failure');
              return;
            }
          }
          params = {
            "requestId": this.data.request.id,
            "status": this.data.deliveryStatus,
            "failedDeliveryReason": this.failedDelivery.reason
          };
          CSpinner.show('', 'Please wait...');
          return RequestsAPI.updateRequestStatus(params).then((function(_this) {
            return function() {
              _this.data.request.status = _this.data.deliveryStatus;
              _this.data.request.failedDeliveryReason = _this.failedDelivery.reason;
              _this.showChange = true;
              _this.modal.hide();
              return CToast.showLongBottom('Delivery status has been updated. ' + 'Customer will be notified about the status update.');
            };
          })(this), function(error) {
            return CToast.show('Failed to update status, please try again');
          })["finally"](function() {
            return CSpinner.hide();
          });
        },
        closeSuccessfulOfferDetail: function() {
          var msg;
          if (this.showChange) {
            return this.modal.hide();
          } else {
            msg = 'Your changes are not updated. Are you sure you want to exit?';
            return CDialog.confirm('Exit Details', msg, ['Exit Anyway', 'Update & Exit']).then((function(_this) {
              return function(btnIndex) {
                switch (btnIndex) {
                  case 1:
                    return _this.modal.hide();
                  case 2:
                    return _this.updateDeliveryStatus();
                }
              };
            })(this));
          }
        }
      },
      init: function() {
        this.offerDetails.loadModal();
        return this.filter.loadModal();
      },
      onScrollComplete: function() {
        return $scope.$broadcast('scroll.infiniteScrollComplete');
      },
      autoFetch: function() {
        this.page = 0;
        this.requests = [];
        this.gotAllOffers = false;
        this.noAcceptedOffers = false;
        return this.showOfferHistory();
      },
      reFetch: function(refresh) {
        if (refresh == null) {
          refresh = true;
        }
        this.refresh = refresh;
        this.page = 0;
        this.requests = [];
        this.canLoadMore = true;
        this.gotAllOffers = false;
        this.noAcceptedOffers = false;
        return $timeout((function(_this) {
          return function() {
            return _this.onScrollComplete();
          };
        })(this));
      },
      showSortOptions: function() {
        return $ionicLoading.show({
          scope: $scope,
          templateUrl: 'views/requests-offers/successful-offer-sort.html',
          hideOnStateChange: true
        });
      },
      showOfferHistory: function() {
        var params;
        params = {
          page: this.page,
          acceptedOffers: true,
          displayLimit: 5,
          sortBy: this.sortBy,
          descending: this.descending,
          selectedFilters: this.filter.selected
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
      onSuccess: function(data, displayLimit) {
        var offerData, offerDataSize;
        this.display = 'noError';
        this.imageSizes = data.imageSizes;
        offerData = data.sellerOffers;
        offerDataSize = _.size(offerData);
        if (offerDataSize > 0) {
          if (offerDataSize < displayLimit) {
            this.canLoadMore = false;
          } else {
            this.canLoadMore = true;
            this.onScrollComplete();
          }
          if (this.refresh) {
            this.requests = offerData;
          } else {
            this.requests = this.requests.concat(offerData);
          }
        } else {
          this.canLoadMore = false;
          if (_.size(this.requests) === 0) {
            this.noAcceptedOffers = true;
          }
        }
        if (!this.canLoadMore) {
          this.gotAllOffers = true;
        }
        return this.offerDetails.handlePendingOffer();
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
        this.gotAllOffers = false;
        this.noAcceptedOffers = false;
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
      },
      onSort: function(sortBy, sortName, descending) {
        $ionicLoading.hide();
        switch (sortBy) {
          case 'updatedAt':
            if (this.sortBy !== 'updatedAt') {
              this.sortBy = 'updatedAt';
              this.sortName = sortName;
              this.descending = descending;
              return this.reFetch();
            }
            break;
          case 'deliveryDate':
            if (this.sortBy !== 'deliveryDate') {
              this.sortBy = 'deliveryDate';
              this.sortName = sortName;
              this.descending = descending;
              return this.reFetch();
            } else if (this.descending !== descending) {
              this.sortBy = 'deliveryDate';
              this.sortName = sortName;
              this.descending = descending;
              return this.reFetch();
            }
        }
      }
    };
    onDeviceBack = function() {
      var detailsModal, filter;
      filter = $scope.view.filter;
      detailsModal = $scope.view.offerDetails.modal;
      if ($('.loading-container').hasClass('visible')) {
        return $ionicLoading.hide();
      } else if (filter.modal.isShown()) {
        return filter.closeModal();
      } else if (detailsModal.isShown()) {
        return $scope.view.offerDetails.closeSuccessfulOfferDetail();
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
    $scope.$on('modal.hidden', function() {
      $scope.view.offerDetails.pendingOfferId = "";
      return $timeout(function() {
        return $scope.view.offerDetails.showExpiry = false;
      }, 1000);
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'accepted_offer') {
        App.scrollTop();
        return $scope.view.autoFetch();
      }
    });
    return $scope.$on('$ionicView.enter', function() {
      var offerId;
      offerId = OffersAPI.acceptedOfferId('get');
      if (offerId !== '') {
        $scope.view.offerDetails.onNotificationClick(offerId);
      }
      return OffersAPI.acceptedOfferId('set', '');
    });
  }
]).controller('EachSuccessfulOfferCtrl', [
  '$scope', '$interval', 'DeliveryTime', function($scope, $interval, DeliveryTime) {
    var setTime;
    setTime = function() {
      var deliveryDate, format;
      format = 'DD/MM/YYYY';
      deliveryDate = moment($scope.request.offerDeliveryDate.iso).format(format);
      return $scope.request.leftDeliveryTimeStr = deliveryDate;
    };
    return setTime();
  }
]);
