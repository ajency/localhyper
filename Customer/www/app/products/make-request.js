angular.module('LocalHyper.products').controller('MakeRequestCtrl', [
  '$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout', 'GoogleMaps', 'UIMsg', 'CSpinner', 'User', 'ProductsAPI', '$ionicPopup', '$rootScope', '$q', '$ionicModal', function($scope, App, GPS, CToast, CDialog, $timeout, GoogleMaps, UIMsg, CSpinner, User, ProductsAPI, $ionicPopup, $rootScope, $q, $ionicModal) {
    $scope.view = {
      latLng: null,
      addressFetch: true,
      sellerMarkers: [],
      sellers: {
        count: 0,
        displayCount: false,
        found: false
      },
      comments: {
        text: ''
      },
      latitude: '',
      longitude: '',
      city: null,
      userInfo: '',
      user: {
        full: ''
      },
      addressObj: '',
      display: 'loader',
      errorType: '',
      locationSet: true,
      location: {
        modal: null,
        map: null,
        marker: null,
        latLng: null,
        address: null,
        addressFetch: true,
        loadModal: function() {
          var defer;
          defer = $q.defer();
          if (_.isNull(this.modal)) {
            $ionicModal.fromTemplateUrl('views/products/location.html', {
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
              _this.address = address;
              console.log('--107--');
              return console.log(_this.address);
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
      beforeInit: function() {},
      init: function() {
        var userInfo;
        userInfo = User.getCurrent();
        this.userInfo = userInfo.attributes;
        if (_.isEmpty(this.userInfo.address)) {
          console.log('if user is not register');
          if (_.isNull(this.latLng)) {
            return $timeout((function(_this) {
              return function() {
                var loc;
                loc = {
                  lat: GEO_DEFAULT.lat,
                  long: GEO_DEFAULT.lng
                };
                return _this.getCurrent();
              };
            })(this), 200);
          } else {
            return this.getCurrent();
          }
        } else {
          this.locationSet = true;
          console.log('if user is register');
          this.display = 'noError';
          this.latitude = this.userInfo.addressGeoPoint._latitude;
          this.longitude = this.userInfo.addressGeoPoint._longitude;
          this.city = this.userInfo.address.city;
          this.user.full = this.userInfo.address.full;
          this.addressObj = this.userInfo.address;
          return this.loadSeller();
        }
      },
      toLatLng: function(loc) {
        var latLng;
        latLng = new google.maps.LatLng(loc.lat, loc.long);
        return latLng;
      },
      onMapCreated: function(map) {
        return this.map = map;
      },
      getCurrent: function() {
        return GPS.isLocationEnabled().then((function(_this) {
          return function(enabled) {
            if (!enabled) {
              _this.locationSet = false;
              return _this.display = 'noError';
            } else {
              CToast.show('Getting current location');
              return GPS.getCurrentLocation().then(function(loc) {
                var latLng;
                console.log(loc);
                latLng = _this.toLatLng(loc);
                _this.latLng = latLng;
                _this.addressFetch = false;
                return GoogleMaps.getAddress(_this.latLng).then(function(address) {
                  console.log('--197---');
                  console.log(address);
                  _this.addressObj = address;
                  _this.address = address;
                  _this.address.full = GoogleMaps.fullAddress(address);
                  console.log('full');
                  console.log(_this.address.full);
                  _this.addressFetch = true;
                  _this.latitude = _this.latLng.H;
                  _this.longitude = _this.latLng.L;
                  _this.city = _this.address.city;
                  _this.user.full = _this.address.full;
                  return _this.loadSeller();
                }, function(error) {
                  this.locationSet = false;
                  this.display = 'noError';
                  return console.log('Geocode error: ' + error);
                });
              }, function(error) {
                _this.locationSet = false;
                _this.display = 'noError';
                return CToast.show('Error locating your position');
              });
            }
          };
        })(this));
      },
      isLocationReady: function() {
        var ready;
        ready = this.latitude !== '' && this.longitude !== '' ? true : false;
        return ready;
      },
      loadSeller: function() {
        var params, product, sellers;
        sellers = [];
        console.log(this.userInfo);
        console.log(this.latitude);
        console.log(this.longitude);
        CSpinner.show('', 'Please wait as we find sellers for your location');
        product = ProductsAPI.productDetails('get');
        params = {
          "location": {
            latitude: this.latitude,
            longitude: this.longitude
          },
          "categoryId": product.category.id,
          "brandId": product.brand.id,
          "city": this.city,
          "area": this.city
        };
        return ProductsAPI.findSellers(params).then((function(_this) {
          return function(sellers) {
            console.log(sellers);
            _this.sellers.count = sellers.length;
            return _this.display = 'noError';
          };
        })(this), (function(_this) {
          return function(error) {
            CToast.show('Request failed, please try again');
            return _this.display = 'error';
          };
        })(this))["finally"](function() {
          App.resize();
          return CSpinner.hide();
        });
      },
      addComments: function() {
        this.comments.temp = this.comments.text;
        return $ionicPopup.show({
          template: '<div class="list"> <label class="item item-input"> <textarea placeholder="Comments" ng-model="view.comments.temp"> </textarea> </label> </div>',
          title: 'Add comments',
          scope: $scope,
          buttons: [
            {
              text: 'Cancel'
            }, {
              text: '<b>Save</b>',
              type: 'button-positive',
              onTap: (function(_this) {
                return function(e) {
                  return _this.comments.text = _this.comments.temp;
                };
              })(this)
            }
          ]
        });
      },
      makeRequest: function() {
        var params, product;
        console.log('make request button');
        console.log(this.addressObj);
        if (!this.isLocationReady()) {
          return CToast.show('Please select your location');
        } else {
          product = ProductsAPI.productDetails('get');
          CSpinner.show('', 'Please wait...');
          params = {
            "customerId": User.getId(),
            "productId": product.id,
            "categoryId": product.category.id,
            "brandId": product.brand.id,
            "comments": this.comments.text,
            "status": "open",
            "deliveryStatus": "",
            "location": {
              latitude: this.latitude,
              longitude: this.longitude
            },
            "address": this.addressObj,
            "city": this.city,
            "area": this.city
          };
          console.log(params);
          console.log('update');
          return User.update({
            "address": params.address,
            "addressGeoPoint": new Parse.GeoPoint(params.location),
            "area": params.area,
            "city": params.city
          }).then(function() {
            return ProductsAPI.makeRequest(params);
          }).then((function(_this) {
            return function() {
              CToast.show('Your request has been made');
              $rootScope.$broadcast('make:request:success');
              return $timeout(function() {
                return App.goBack(-1);
              }, 500);
            };
          })(this), function(error) {
            return CToast.show('Request failed, please try again');
          })["finally"](function() {
            return CSpinner.hide();
          });
        }
      },
      isGoogleMapsScriptLoaded: function() {
        var defer;
        defer = $q.defer();
        if (typeof google === 'undefined') {
          CSpinner.show('', 'Please wait, loading resources...');
          GoogleMaps.loadScript().then((function(_this) {
            return function() {
              return _this.location.loadModal();
            };
          })(this)).then(function() {
            return defer.resolve(true);
          }, function(error) {
            CToast.show('Could not connect to server. Please try again');
            return defer.resolve(false);
          })["finally"](function() {
            return CSpinner.hide();
          });
        } else {
          this.location.loadModal().then(function() {
            return defer.resolve(true);
          });
        }
        return defer.promise;
      },
      onChangeLocation: function() {
        return this.isGoogleMapsScriptLoaded().then((function(_this) {
          return function(loaded) {
            if (loaded) {
              _this.location.modal.show();
              return $timeout(function() {
                var children, container, latLng, loc, mapHeight;
                container = $('.map-content').height();
                children = $('.address-inputs').height() + $('.tap-div').height();
                mapHeight = container - children - 20;
                $('.aj-big-map').css({
                  'height': mapHeight
                });
                if (_this.latitude !== '') {
                  loc = {
                    lat: _this.latitude,
                    long: _this.longitude
                  };
                  latLng = _this.location.setMapCenter(loc);
                  _this.location.map.setZoom(15);
                  return _this.location.addMarker(latLng);
                } else {
                  loc = {
                    lat: GEO_DEFAULT.lat,
                    long: GEO_DEFAULT.lng
                  };
                  _this.location.setMapCenter(loc);
                  return _this.location.getCurrent();
                }
              }, 300);
            }
          };
        })(this));
      },
      onConfirmLocation: function() {
        var k;
        if (!_.isNull(this.location.latLng) && this.location.addressFetch) {
          k = GoogleMaps.fullAddress(this.location.address);
          this.address = k;
          console.log(this.address);
          this.addressObj = this.location.address;
          this.user.full = GoogleMaps.fullAddress(this.location.address);
          this.confirmedAddress = this.location.address.full;
          this.latitude = this.location.latLng.lat();
          this.longitude = this.location.latLng.lng();
          this.city = this.location.address.city;
          this.loadSeller();
          this.location.modal.hide();
          return this.locationSet = true;
        } else {
          return CToast.show('Please wait, getting location details...');
        }
      },
      onTapToRetry: function() {
        return this.init();
      }
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      $scope.view.beforeInit();
      return App.scrollTop();
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return $scope.view.init();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('make-request', {
      url: '/make-request',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/make-request.html',
          controller: 'MakeRequestCtrl'
        }
      }
    });
  }
]);
