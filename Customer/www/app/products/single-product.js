angular.module('LocalHyper.products').controller('SingleProductCtrl', [
  '$scope', '$stateParams', 'ProductsAPI', 'User', 'CToast', 'App', '$ionicModal', 'GPS', 'GoogleMaps', 'CSpinner', 'CDialog', '$timeout', 'UIMsg', function($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GPS, GoogleMaps, CSpinner, CDialog, $timeout, UIMsg) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      productID: $stateParams.productID,
      product: {},
      specificationModal: null,
      makeRequestModal: null,
      confirmedAddress: '',
      comments: {
        modal: null,
        text: ''
      },
      location: {
        modal: null,
        map: null,
        marker: null,
        latLng: null,
        address: null,
        addressFetch: true,
        showAlert: function() {
          var positiveBtn;
          positiveBtn = App.isAndroid() ? 'Open Settings' : 'Ok';
          return CDialog.confirm('Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']).then(function(btnIndex) {
            if (btnIndex === 1) {
              return GPS.switchToLocationSettings();
            }
          });
        },
        onMapCreated: function(map) {
          this.map = map;
          return google.maps.event.addListener(this.map, 'click', (function(_this) {
            return function(event) {
              return _this.addMarker(event.latLng);
            };
          })(this));
        },
        setMapCenter: function(loc) {
          var latLng;
          latLng = new google.maps.LatLng(loc.lat, loc.long);
          this.map.setCenter(latLng);
          return latLng;
        },
        getCurrent: function() {
          return GPS.isLocationEnabled().then((function(_this) {
            return function(enabled) {
              if (!enabled) {
                return _this.showAlert();
              } else {
                CToast.show('Getting current location');
                return GPS.getCurrentLocation().then(function(loc) {
                  var latLng;
                  latLng = _this.setMapCenter(loc);
                  _this.map.setZoom(15);
                  return _this.addMarker(latLng);
                }, function(error) {
                  return CToast.show('Error locating your position');
                });
              }
            };
          })(this));
        },
        addMarker: function(latLng) {
          this.latLng = latLng;
          this.setAddress();
          if (this.marker) {
            this.marker.setMap(null);
          }
          this.marker = new google.maps.Marker({
            position: latLng,
            map: this.map,
            draggable: true
          });
          this.marker.setMap(this.map);
          return google.maps.event.addListener(this.marker, 'dragend', (function(_this) {
            return function(event) {
              _this.latLng = event.latLng;
              return _this.setAddress();
            };
          })(this));
        },
        setAddress: function() {
          this.addressFetch = false;
          return GoogleMaps.getAddress(this.latLng).then((function(_this) {
            return function(address) {
              return _this.address = address;
            };
          })(this), function(error) {
            return console.log('Geocode error: ' + error);
          })["finally"]((function(_this) {
            return function() {
              return _this.addressFetch = true;
            };
          })(this));
        }
      },
      init: function() {
        this.loadSpecificationsModal();
        this.loadMakeRequestModal();
        this.loadLocationModal();
        this.loadCommentsModal();
        return this.getSingleProductDetails();
      },
      loadSpecificationsModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/specification.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.specificationModal = modal;
          };
        })(this));
      },
      loadMakeRequestModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/make-request.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.makeRequestModal = modal;
          };
        })(this));
      },
      loadLocationModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/location.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.location.modal = modal;
          };
        })(this));
      },
      loadCommentsModal: function() {
        return $ionicModal.fromTemplateUrl('views/products/comments.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.comments.modal = modal;
          };
        })(this));
      },
      getSingleProductDetails: function() {
        return ProductsAPI.getSingleProduct(this.productID).then((function(_this) {
          return function(data) {
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
        return this.product = data;
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getSingleProductDetails();
      },
      getPrimaryAttrs: function() {
        var attrs, unit, value;
        if (!_.isUndefined(this.product.primaryAttributes)) {
          attrs = this.product.primaryAttributes[0];
          value = s.humanize(attrs.value);
          unit = '';
          if (_.has(attrs.attribute, 'unit')) {
            unit = s.humanize(attrs.attribute.unit);
          }
          return "" + value + " " + unit;
        } else {
          return '';
        }
      },
      onEditLocation: function() {
        var mapHeight;
        this.location.modal.show();
        mapHeight = $('.map-content').height();
        $('.aj-big-map').css({
          'height': mapHeight
        });
        if (_.isNull(this.location.latLng)) {
          return $timeout((function(_this) {
            return function() {
              var loc;
              loc = {
                lat: GEO_DEFAULT.lat,
                long: GEO_DEFAULT.lng
              };
              _this.location.setMapCenter(loc);
              return _this.location.getCurrent();
            };
          })(this), 200);
        }
      },
      onConfirmLocation: function() {
        if (!_.isNull(this.location.latLng) && this.location.addressFetch) {
          return CDialog.confirm('Confirm Location', 'Do you want to confirm this location?', ['Confirm', 'Cancel']).then((function(_this) {
            return function(btnIndex) {
              if (btnIndex === 1) {
                _this.confirmedAddress = _this.location.address.full;
                return _this.location.modal.hide();
              }
            };
          })(this));
        } else {
          return CToast.show('Please wait, getting location details...');
        }
      },
      checkUserLogin: function() {
        var address, user;
        if (!User.isLoggedIn()) {
          return App.navigate('verify-begin');
        } else {
          user = User.getCurrent();
          address = user.get('address');
          this.confirmedAddress = _.isUndefined(address) ? '' : address.full;
          return this.makeRequestModal.show();
        }
      },
      beforeMakeRequest: function() {
        if (this.confirmedAddress === '') {
          return CToast.show('Please select your location');
        } else {
          return this.makeRequest();
        }
      },
      makeRequest: function() {
        var geoPoint, params, user;
        if (!App.isOnline()) {
          return CToast.show(UIMsg.noInternet);
        } else {
          CSpinner.show('', 'Please wait...');
          user = User.getCurrent();
          params = {
            "customerId": user.id,
            "productId": this.productID,
            "categoryId": this.product.category.objectId,
            "brandId": this.product.brand.objectId,
            "comments": this.comments.text,
            "status": "open",
            "deliveryStatus": ""
          };
          if (!_.isNull(this.location.latLng)) {
            params["location"] = {
              latitude: this.location.latLng.lat(),
              longitude: this.location.latLng.lng()
            };
            params["address"] = this.location.address;
            params["city"] = this.location.address.city;
            params["area"] = this.location.address.city;
          } else {
            geoPoint = user.get('addressGeoPoint');
            params["location"] = {
              latitude: geoPoint.latitude,
              longitude: geoPoint.longitude
            };
            params["address"] = user.get('address');
            params["city"] = user.get('city');
            params["area"] = user.get('area');
          }
          return User.update({
            "address": params.address,
            "addressGeoPoint": new Parse.GeoPoint(params.location),
            "area": params.area,
            "city": params.city
          }).then(function() {
            return ProductsAPI.makeRequest(params);
          }).then((function(_this) {
            return function() {
              _this.makeRequestModal.hide();
              return CToast.show('Your request has been made');
            };
          })(this), function(error) {
            return CToast.show('Request failed, please try again');
          })["finally"](function() {
            return CSpinner.hide();
          });
        }
      }
    };
    return $scope.$on('$destroy', function() {
      $scope.view.specificationModal.remove();
      $scope.view.makeRequestModal.remove();
      $scope.view.location.modal.remove();
      return $scope.view.comments.modal.remove();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('single-product', {
      url: '/single-product:productID',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          templateUrl: 'views/products/single-product.html',
          controller: 'SingleProductCtrl',
          resolve: {
            Maps: function(GoogleMaps) {
              return GoogleMaps.loadScript();
            }
          }
        }
      }
    });
  }
]);
